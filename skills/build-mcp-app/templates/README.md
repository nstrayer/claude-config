# __PROJECT_NAME__

An MCP server on Cloudflare Workers, usable from the Claude consumer app (web,
desktop, iOS/Android) as a custom connector added by URL. It exposes a thin set
of tools plus an interactive MCP Apps widget (React + Tailwind) that renders in
chat.

- Transport: Streamable HTTP MCP (via the Cloudflare `agents` `McpAgent`)
- Storage: Workers KV (binding `STORE`)
- Auth: an unguessable secret in the URL path -- `https://<host>/<MCP_SECRET>/mcp`.
  The consumer connector UI has no header field, so the URL is the secret.
  Treat the full URL like a password. (Swap to OAuth when productionizing.)

## Local dev

```sh
npm install
npm run dev                    # wrangler dev on http://127.0.0.1:8787
node scripts/verify-ui.mjs     # another shell: checks the MCP Apps widget wiring
node scripts/smoke.mjs         # exercises the CRUD tools
```

Local secret lives in `.dev.vars` (gitignored). Local endpoint:
`http://127.0.0.1:8787/devsecret/mcp`. `npm run dev` runs `build:ui` first to
generate the bundled widget HTML (`src/ui/widget-html.ts`, gitignored).

## Tools

| Tool | Purpose |
|---|---|
| `list_items` | Recall stored Items (filter by text, limit) |
| `save_item` | Append or upsert an Item by id |
| `delete_item` | Remove an Item by id |
| `open_view` | Render the interactive Items widget in chat |

Keep the tool surface thin: intelligence belongs in Claude's reasoning over the
data, not in coded features. See `docs/adr/`.

## Deploy

```sh
npx wrangler kv namespace create STORE      # paste the id into wrangler.jsonc
npm run deploy                              # -> https://__PROJECT_NAME__.<subdomain>.workers.dev
openssl rand -hex 24 | npx wrangler secret put MCP_SECRET
MCP_URL="https://__PROJECT_NAME__.<subdomain>.workers.dev/<MCP_SECRET>/mcp" node scripts/smoke.mjs
```

Then add the full `https://.../<MCP_SECRET>/mcp` URL as a custom connector on
claude.ai (Settings -> Connectors -> Add custom connector; leave the OAuth
fields blank). Needs Claude Pro/Max. It syncs to the iOS/Android app
automatically -- no Connectors Directory submission is needed for a personal
connector to render.
