FROM golang:1.21-bullseye AS build

# ghostbuster
RUN mkdir -p /go/src/github.com/timvaillancourt/ghostbuster
COPY . /go/src/github.com/timvaillancourt/ghostbuster
WORKDIR /go/src/github.com/timvaillancourt/ghostbuster

RUN go build -o /ghostbuster ./go/cmd/ghostbuster/main.go

# gh-ost (from slackhq)
ARG GHOST_GIT_TAG

RUN git clone -b ${GHOST_GIT_TAG} https://github.com/slackhq/gh-ost /go/src/github.com/slackhq/gh-ost
WORKDIR /go/src/github.com/slackhq/gh-ost

RUN go build -ldflags "-X main.AppVersion=${GHOST_GIT_TAG}" -o /gh-ost ./go/cmd/gh-ost/main.go


# runtime container
FROM debian:bullseye

RUN apt-get update && apt-get install -y curl default-mysql-client

COPY --from=build /ghostbuster /usr/local/bin/ghostbuster
COPY --from=build /gh-ost /usr/local/bin/gh-ost

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
