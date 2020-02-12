FROM ubuntu:18.04

RUN apt-get -yqq update \
  && apt-get install -qfy \
    curl \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /wd

ENV SHA256SUM_BITCOINCORE=732cc96ae2e5e25603edf76b8c8af976fe518dd925f7e674710c6c8ee5189204
RUN curl -sL -o bitcoin.tar.gz https://bitcoincore.org/bin/bitcoin-core-0.19.0.1/bitcoin-0.19.0.1-x86_64-linux-gnu.tar.gz \
 && echo "${SHA256SUM_BITCOINCORE}  bitcoin.tar.gz" | sha256sum --check \
 && tar xzf bitcoin.tar.gz -C /wd \
 && rm /wd/bitcoin-0.19.0.1/README.md \
 && rm /wd/bitcoin-0.19.0.1/bin/bitcoin-cli \
 && rm /wd/bitcoin-0.19.0.1/bin/bitcoin-qt \
 && rm /wd/bitcoin-0.19.0.1/bin/bitcoin-tx \
 && rm /wd/bitcoin-0.19.0.1/bin/bitcoin-wallet \
 && rm /wd/bitcoin-0.19.0.1/bin/test_bitcoin \
 && rm /wd/bitcoin-0.19.0.1/include/bitcoinconsensus.h \
 && rm /wd/bitcoin-0.19.0.1/lib/libbitcoinconsensus.so \
 && rm /wd/bitcoin-0.19.0.1/lib/libbitcoinconsensus.so.0 \
 && rm /wd/bitcoin-0.19.0.1/lib/libbitcoinconsensus.so.0.0.0 \
 && rm /wd/bitcoin-0.19.0.1/share/man/man1/bitcoin-cli.1 \
 && rm /wd/bitcoin-0.19.0.1/share/man/man1/bitcoin-qt.1 \
 && rm /wd/bitcoin-0.19.0.1/share/man/man1/bitcoin-tx.1 \
 && rm /wd/bitcoin-0.19.0.1/share/man/man1/bitcoin-wallet.1 \
 && rm /wd/bitcoin-0.19.0.1/share/man/man1/bitcoind.1 \
 && rm bitcoin.tar.gz
ENV PATH="/wd/bitcoin-0.19.0.1/bin:${PATH}"

COPY conf/bitcoind.conf /wd/conf/bitcoind.conf
