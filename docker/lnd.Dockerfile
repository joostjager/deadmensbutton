FROM ubuntu:18.04

RUN apt-get -yqq update \
  && apt-get install -qfy \
    git \
    make \
    wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /wd

ENV SHA256SUM_GOLANG=68a2297eb099d1a76097905a2ce334e3155004ec08cdea85f24527be3c48e856
RUN cd /tmp \
    && wget -q https://dl.google.com/go/go1.13.linux-amd64.tar.gz \
    && echo "${SHA256SUM_GOLANG}  go1.13.linux-amd64.tar.gz" | sha256sum --check \
    && tar -xf go1.13.linux-amd64.tar.gz \
    && mv go /usr/local \
    && rm go1.13.linux-amd64.tar.gz \
    && ln -s /usr/local/go/bin/go /usr/bin/
ENV GOROOT=/usr/local/go
ENV GOPATH=/usr/local/bin/go
ENV PATH=$PATH:$GOPATH/bin

RUN go get -d github.com/lightningnetwork/lnd \
    && cd $GOPATH/src/github.com/lightningnetwork/lnd \
    && make && make install

COPY go.mod /wd/go.mod
COPY go.mod /wd/go.sum
COPY go.mod /wd/main.go
