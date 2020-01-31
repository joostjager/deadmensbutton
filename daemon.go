package main

import (
	"context"
	"fmt"
	"time"

	"github.com/lightningnetwork/lnd/lnrpc"
	"github.com/lightningnetwork/lnd/lntypes"
	"github.com/urfave/cli/v2"
)

const SecretRecord uint64 = 80000

type daemon struct {
	client lnrpc.LightningClient
}

func startDaemon(c *cli.Context) error {
	fmt.Printf("Lightning Dead Men's Button\n\n")
	conn, err := getClientConn(c)
	if err != nil {
		return err
	}
	defer conn.Close()

	client := lnrpc.NewLightningClient(conn)

	infoResp, err := client.GetInfo(
		context.Background(), &lnrpc.GetInfoRequest{},
	)
	if err != nil {
		return err
	}

	fmt.Printf("Connected to: %v\n", infoResp.IdentityPubkey)

	d := daemon{
		client: client,
	}

	return d.run()

}

func (d *daemon) run() error {
	invoicesStream, err := d.client.SubscribeInvoices(
		context.Background(), &lnrpc.InvoiceSubscription{},
	)
	if err != nil {
		return err
	}

	errChan := make(chan error)
	secretChan := make(chan lntypes.Preimage)
	go func() {
		for {
			invoice, err := invoicesStream.Recv()
			if err != nil {
				errChan <- err
				return
			}

			if !invoice.IsKeysend {
				continue
			}

			if len(invoice.Htlcs) == 0 {
				continue
			}

			htlc := invoice.Htlcs[0]
			if htlc.State != lnrpc.InvoiceHTLCState_SETTLED {
				continue
			}

			secretBytes, ok := htlc.CustomRecords[SecretRecord]
			if !ok {
				continue
			}

			secret, err := lntypes.MakePreimage(secretBytes)
			if err != nil {
				continue
			}

			secretChan <- secret
		}
	}()

	secrets := make(map[lntypes.Preimage]time.Time)
	for {
		select {
		case err := <-errChan:
			return err
		case secret := <-secretChan:
			expiry := time.Now().Add(10 * time.Second)
			secrets[secret] = expiry

			fmt.Printf("Received secret: hash=%v, expiry=%v\n",
				secret.Hash(), expiry)

		case now := <-time.After(time.Second):
			for secret, releaseTime := range secrets {
				if now.After(releaseTime) {
					err := d.reveal(secret)
					if err != nil {
						return err
					}
					delete(secrets, secret)
				}
			}
		}
	}
}

func (d *daemon) reveal(secret lntypes.Preimage) error {
	fmt.Printf("Revealing secret: hash=%v\n", secret.Hash())

	_, err := d.client.AddInvoice(
		context.Background(),
		&lnrpc.Invoice{
			RPreimage: secret[:],
			Value:     1000,
		},
	)

	return err
}
