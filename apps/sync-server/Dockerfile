# Build stage
FROM rust:1.85-slim-bookworm AS builder

# Install protobuf compiler
RUN apt-get update && apt-get install -y \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy sync-server source
COPY . /app/sync-server

WORKDIR /app/sync-server

# Build release binary
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the built binary
COPY --from=builder /app/sync-server/target/release/sync-server /app/sync-server

# Expose WebTransport port
EXPOSE 4433/udp

CMD ["./sync-server"]
