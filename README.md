# Deploy Bit Casino Infrastructure

This repository contains a way for users to deploy this application on their own devices using Docker compose. In the future, it may demonstrate other methods of deployment, including terraform -> AWS, Kubernetes, etc.

## Test locally with Docker compose

### Requires:
- Docker is installed.

### Set up the containers:

Clone the repository onto your device:

```bash
git clone https://github.com/b1gd3vd0g/bit-casino-infra.git bit-casino-infra
cd bit-casino-infra
```

Now create a `.env` file at the root with the following variables defined (ideally with better secrets):

```
PLAYER_JWT_SECRET=secret

DB_USER=postgres

PLAYER_DB_PASSWORD=password1
PLAYER_DB_NAME=bit_casino_player_db

CURRENCY_DB_PASSWORD=password2
CURRENCY_DB_NAME=bit_casino_currency_db
```

The **first time** this is done on your machine, it is important that you run the database migrations in order to set up the tables, so that the APIs can interact with the databases.

If a migration has already been completed, ignore this step.

```bash
# Start the databases
docker compose up -d player-db currency-db
# Run the migration containers, which will stop after completion.
COMPOSE_PROFILES=migrate docker compose run --rm player-migration
COMPOSE_PROFILES=migrate docker compose run --rm currency-migration
```

Finally, run docker compose in order to start the containers and network.

```bash
docker compose up --build
```

This creates and starts all the necessary containers, which can interact with each other seamlessly.

### Testing

Running docker compose will expose the following ports on localhost which can be used to access any of the containers:

container   | localhost port 
----------- | --------------
player-db   | 54320
currency-db | 54321
player-ms   | 60600
currency-ms | 60601

So you could test making a call to the player microservice to create a new account:

```bash
curl -X POST http://localhost:60600 \
-H "Content-Type: application/json" \
-d '{"username":"testuser", "password": "p455W0rd#", "email": "user@mail.com"}'
```

If the previous request prints something like

```json
{"token":"abc.def.ghi"}
``` 

then you have created a new user "testuser" in your database, which will
persist even when your containers are stopped.

