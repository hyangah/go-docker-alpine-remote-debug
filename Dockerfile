FROM golang:alpine3.17 AS build

WORKDIR /app

# Turning off Cgo is required to install Delve on Alpine.
ENV CGO_ENABLED=0

# Build and install patched delve (checked out in the delve directory)
COPY delve /tmp/delve
RUN go install -C /tmp/delve ./cmd/dlv

COPY go.mod .
COPY go.sum .

RUN go mod download

# You'll want to copy all your .go files here in a bigger project.
COPY main.go .

# Disable inlining and optimizations that can interfere with debugging.
#RUN go build -gcflags "all=-N -l" -o /main main.go
RUN go build -gcflags "all=-N -l" -o /main .

FROM alpine:3.17

WORKDIR /

COPY --from=build /go/bin/dlv /bin/dlv
COPY --from=build /main /bin/app
COPY run.sh /bin/run.sh

EXPOSE 8080

ENTRYPOINT ["/bin/run.sh"]
