FROM golang:1.24-alpine

COPY . /app
WORKDIR /app
RUN go build -o main.app main.go
EXPOSE 8080
CMD ["/app/main.app"]