FROM public.ecr.aws/docker/library/golang:1.18 as builder

WORKDIR /opt/

COPY go.mod go.sum ./
RUN go mod download

COPY . ./

ENV GOOS linux
ENV CGO_ENABLED=0

ARG VERSION
RUN go build -v -ldflags "-X main.version=$VERSION" -o yace cmd/yace/main.go

FROM arm64v8/alpine:latest

EXPOSE 5000
ENTRYPOINT ["yace"]
CMD ["--config.file=/tmp/config.yml"]

WORKDIR /exporter/


RUN apk update && \
    apk add ca-certificates && \
    update-ca-certificates

COPY --from=builder /opt/yace /usr/local/bin/yace
USER exporter
