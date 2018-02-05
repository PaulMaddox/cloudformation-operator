# builder image
FROM golang:1.9-alpine as builder

RUN apk -U add git
RUN go get github.com/golang/dep/cmd/dep
WORKDIR /go/src/github.com/linki/cloudformation-operator
COPY . .
RUN dep ensure
RUN go test -v ./...
RUN go build -o /bin/cloudformation-operator -v \
  -ldflags "-X main.version=$(git describe --tags --always --dirty) -w -s"

# final image
FROM alpine:3.7
MAINTAINER Linki <linki+docker.com@posteo.de>

RUN apk --no-cache add ca-certificates

RUN addgroup -S app && adduser -S -g app app
COPY --from=builder /bin/cloudformation-operator /bin/cloudformation-operator

USER app
ENTRYPOINT ["/bin/cloudformation-operator"]
