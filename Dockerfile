# 构建阶段
FROM golang:1.22.3-alpine AS builder
WORKDIR /app
# 设置代理 否则很慢
ENV GOPROXY=https://goproxy.cn,direct
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# 运行阶段
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 9000
CMD ["./main"]