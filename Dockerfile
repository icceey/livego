FROM golang:latest as builder
WORKDIR /app
ENV GOPROXY https://goproxy.io
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o livego .

FROM alpine:latest
RUN mkdir -p /app/config
WORKDIR /app
ENV RTMP_PORT 1935
ENV HTTP_FLV_PORT 7001
ENV HLS_PORT 7002
ENV HTTP_OPERATION_PORT 8090
COPY --from=builder /app/livego .
COPY --from=builder /app/livego.yaml .
COPY --from=builder /app/healthcheck /usr/local/bin/
EXPOSE ${RTMP_PORT}
EXPOSE ${HTTP_FLV_PORT}
EXPOSE ${HLS_PORT}
EXPOSE ${HTTP_OPERATION_PORT}
HEALTHCHECK --start-period=32s --interval=32s --timeout=8s --retries=3 CMD healthcheck
ENTRYPOINT ["./livego"]
