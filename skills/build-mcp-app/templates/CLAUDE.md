# __PROJECT_NAME__

MCP server on Cloudflare Workers. See README.md for running/deploying,
CONTEXT.md for the domain language, and docs/adr/ for the key decisions.

## Shape

- `src/index.ts` -- the `McpAgent` + `McpServer`: thin CRUD tools + `open_view`.
- `client/widget.tsx` + `client/app.css` -- the React + Tailwind widget (MCP
  Apps), bundled by `scripts/build-ui.mjs` into `src/ui/widget-html.ts`
  (generated; gitignored).
- Auth is a secret in the URL path; the KV store is the source of truth.

## Conventions

- Keep the tool surface thin -- intelligence lives in Claude's reasoning over
  the data, not in coded features.
- The model only learns of widget writes by re-reading a tool; do not rely on
  `updateModelContext` reaching the model. See docs/adr/0002.
- Verify protocol changes locally over Streamable HTTP (`scripts/verify-ui.mjs`)
  before any device test.
