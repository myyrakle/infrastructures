FROM rust:1.70 as builder
RUN mkdir /home/app
WORKDIR /home/app
COPY . .
RUN cargo build --release
RUN mv /home/app/target/release/app /home/app.bin

FROM debian:bullseye-slim
RUN mkdir /app
WORKDIR /app
COPY --from=builder /home/app.bin /app/app.bin
COPY run.sh /app/run.sh
CMD ["sh", "/app/run.sh"]