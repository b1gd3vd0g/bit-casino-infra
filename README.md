# Bit Casino -- Infrastructure

> [!NOTE]
> This service currently provides the functionality to run all bit casino services together in order to test locally using **Docker Compose**.\
> Soon, the functionality will be added to this repository to **deploy the app to a live production environment**.

## Test locally with Docker Compose

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

REDIS_PASSWORD=password3
```

I have provided 4 bash scripts in the project root which provide easy control over a working environment (including databases) where you can test all **Bit Casino** services together locally.

- `create` - Build all the containers, and perform database migrations (essential for first-time deployments, or after running `wipe`)
- `refresh` - Build all the containers. Rebuilds the database from the volumes.
  - **Note**: This will not work unless `create` has been run at least once.
- `stop` - Stop all containers running. This will stop taking up CPU resources, but it will maintain the database state in a persistent volume.
- `wipe` - Stop all containers running, and erase all persistent volumes, permanently deleting any data the app was using.

### Testing

Running docker compose will expose the following ports on localhost which can be used to access any of the containers:

| **container** | **localhost port** |
| ------------- | ------------------ |
| player-db     | `54_320`           |
| currency-db   | `54_321`           |
| redis         | `63_790`           |
| player-ms     | `60_600`           |
| currency-ms   | `60_601`           |
| reward-ms     | `60_602`           |
| slots-ms      | `60_603`           |
| frontend      | `60_000`           |

The easiest way to interact with the application is through the frontend, by visiting `localhost:60000` in your browser.

You could also test the microservices by themselves. For example, if you wanted to create a new player account:

```bash
curl -X POST http://localhost:60600 \
-H "Content-Type: application/json" \
-d '{"username":"testuser", "password": "p455W0rd#", "email": "user@mail.com"}'
```

If the output looks anything like this:

```json
{ "token": "abc.def.ghi" }
```

Then you have successfully created a new player account.
