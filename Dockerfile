FROM golang:1.21-bullseye AS build

# ghostblaster
RUN mkdir -p /go/src/github.com/timvaillancourt/ghostbuster
COPY . /go/src/github.com/timvaillancourt/ghostbuster
WORKDIR /go/src/github.com/timvaillancourt/ghostbuster

RUN go build -o /ghostblaster ./go/cmd/ghostblaster/main.go

# gh-ost (from slackhq)
ARG GHOST_GIT_TAG
ARG GHOST_GITHUB_ORG

RUN git clone -b ${GHOST_GIT_TAG} https://github.com/${GHOST_GITHUB_ORG}/gh-ost /go/src/github.com/${GHOST_GITHUB_ORG}/gh-ost
WORKDIR /go/src/github.com/${GHOST_GITHUB_ORG}/gh-ost

RUN go build -ldflags "-X main.AppVersion=${GHOST_GIT_TAG}" -o /gh-ost ./go/cmd/gh-ost/main.go


# runtime container
FROM debian:bullseye

RUN apt-get update && apt-get install -y curl default-mysql-client

COPY --from=build /ghostblaster /usr/local/bin/ghostblaster
COPY --from=build /gh-ost /usr/local/bin/gh-ost

ADD entrypoint.sh /entrypoint.sh

USER nobody
ENTRYPOINT ["/entrypoint.sh"]
