# agenda

Family meeting agenda generator + viewer. Source: https://github.com/jordanrounds/family-meeting-agenda

## Layout
- `docker-compose.yaml` — service definition (image built from `./source`).
- `source/` — git clone of the source repo (read-only deploy via `git pull`).
- `.env` — per-service env vars (`AGENDA_NOTION_TOKEN`).
- `.schedule.json` — bind-mounted into the container; persists the cron schedule across restarts.

## Initial setup (after cloning this dir)

1. **Notion token** (optional): edit `.env`, set `AGENDA_NOTION_TOKEN=secret_...` from https://www.notion.so/my-integrations.

2. **Google OAuth** (required for calendar generation):
   - On your laptop, in `~/projects/family-meeting-agenda/gcal-agenda`, run `npx tsx src/cli.ts auth`. This opens a browser, completes OAuth, writes `~/.config/gcal-agenda/{credentials,token}.json`.
   - Copy both files to VM 100 secrets:
     ```
     scp ~/.config/gcal-agenda/credentials.json docker:/home/docker/.secrets/agenda.google.credentials.json
     scp ~/.config/gcal-agenda/token.json       docker:/home/docker/.secrets/agenda.google.token.json
     ```
   - Restart container: `docker compose restart agenda`.

3. **First start**:
   ```
   cd /home/docker/agenda && docker compose up -d
   ```
   Wait ~25s for healthcheck. Then https://agenda.in.rounds.house should load.

## Updating the source

```
cd /home/docker/agenda/source && git pull
cd .. && docker compose build && docker compose up -d
```

## Re-auth (when Google returns invalid_grant)

Same as initial OAuth: run `npx tsx src/cli.ts auth` on the laptop, scp both files to `${SECRETS}/`, `docker compose restart agenda`.
