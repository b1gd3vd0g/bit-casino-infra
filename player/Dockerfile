###############
# Build Stage #
###############
FROM rust:1.81-alpine AS builder
RUN apk add --no-cache musl-dev pkgconfig curl build-base git
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo install sqlx-cli \
    --version 0.7.4 \
    --locked \
    --no-default-features \
    --features rustls,postgres

#################
# Runtime stage #
#################
FROM alpine:3.20
RUN apk add --no-cache ca-certificates bash
WORKDIR /app
COPY --from=builder /usr/local/cargo/bin/sqlx /usr/local/bin/sqlx
COPY migrations/ ./migrations/
CMD ["bash", "-lc", "sqlx migrate run"]
