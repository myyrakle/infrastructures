FROM rust as build
WORKDIR /usr/src/kube_test
COPY . .
RUN cargo build --release

FROM rust as deploy
WORKDIR /usr/bin
COPY --from=build /usr/src/kube_test/target/release/kube_test /usr/bin/kube_test
ENTRYPOINT [ "/usr/bin/kube_test" ]
