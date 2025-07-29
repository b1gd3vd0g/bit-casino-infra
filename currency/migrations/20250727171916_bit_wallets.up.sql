-- Add up migration script here
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS bit_wallets(
    player_id UUID NOT NULL,
    balance NUMERIC(20, 0) NOT NULL DEFAULT 1024
);