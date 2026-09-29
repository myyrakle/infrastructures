FROM ghcr.io/actions/actions-runner:latest

USER root

# Install system deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        make \
        gcc \
        curl \
        xz-utils \
        unzip \
        git \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.27.1
ARG GO_VERSION=1.27.1
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz" \
    | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:/home/runner/go/bin:${PATH}"
ENV GOPATH="/home/runner/go"
ENV GOMODCACHE="/home/runner/go/pkg/mod"
ENV GOCACHE="/home/runner/.cache/go-build"

# Install Node.js 20.20.2
USER root
RUN curl -fsSL "https://nodejs.org/dist/v20.20.2/node-v20.20.2-linux-arm64.tar.xz" -o /tmp/node.tar.xz \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && ln -sf /usr/local/bin/node /usr/bin/node \
    && ln -sf /usr/local/bin/npm /usr/bin/npm \
    && ln -sf /usr/local/bin/npx /usr/bin/npx

# Install pnpm 10
RUN npm install -g pnpm@10

# Install fsam CLI
ARG FSAM_URL=https://github.com/myyrakle/fast-sam-cli/releases/download/fsam-v0.1.10/fsam-linux-arm64.zip
RUN FSAM_TMP_DIR="/tmp/fsam-installation" \
    && curl -fsSL "$FSAM_URL" -o "/tmp/fsam-linux-arm64.zip" \
    && unzip -q "/tmp/fsam-linux-arm64.zip" -d "$FSAM_TMP_DIR" \
    && "$FSAM_TMP_DIR/install" \
        --install-dir "/opt/fsam-cli" \
        --bin-dir "/usr/local/bin" \
    && /usr/local/bin/fsam --version \
    && rm -rf "$FSAM_TMP_DIR" "/tmp/fsam-linux-arm64.zip"

# Install Go CLIs in /usr/local/bin so they remain executable even if GOPATH/bin is missing from PATH
RUN GOBIN=/usr/local/bin go install github.com/vektra/mockery/v3@v3.8.0 \
    && GOBIN=/usr/local/bin go install go.uber.org/mock/mockgen@v0.6.0 \
    && GOBIN=/usr/local/bin go install github.com/swaggo/swag/cmd/swag@v1.16.4 \
    && /usr/local/bin/swag --version

USER root
RUN chown -R runner:runner /home/runner/go /home/runner/.cache

USER runner
