-- Add up migration script here
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS transactions(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT now(),
    amount NUMERIC(20, 0) NOT NULL,
    reason TEXT NOT NULL,
    success BOOLEAN NOT NULL,
    error_message TEXT
);