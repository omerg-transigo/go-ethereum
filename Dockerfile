# Build Geth in a stock Go builder container
FROM golang:1.11-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers

ADD . /go-ethereum
RUN cd /go-ethereum && make geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp

ADD gethDataDir /gethDataDir
RUN geth --datadir /gethDataDir init /gethDataDir/genesis.json
ENTRYPOINT ["geth","--datadir","/gethDataDir","--etherbase","0x111469778bDaBDA6712c0C8ECa7Bde33eFB0A0a1","--mine","--minerthreads=1","--networkid","93","--rpc","--rpcaddr","0.0.0.0","--rpcapi","eth,web3,personal","--rpccorsdomain","*","--rpcvhosts","*","--verbosity","3"]


