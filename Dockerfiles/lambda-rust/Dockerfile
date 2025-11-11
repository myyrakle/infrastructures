FROM rust
RUN apt update
RUN apt-get install -y pip
RUN pip install ziglang
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo install --locked cargo-lambda