# Interactive MCP Apps widgets for in-flow capture and recall

The server may return MCP Apps UI resources so Claude renders interactive
widgets in the chat. Widgets are in-flow capture and recall surfaces: they
display stored data and call the existing CRUD tools; they do not derive new
logic that belongs in Claude's reasoning.

## The contract (verified end to end on Claude iOS, 2026-06)

- A tool carries `_meta.ui.resourceUri` (a `ui://` URI) plus
  `visibility: ["model", "app"]`; the server registers that `ui://` as a
  resource served with mimeType exactly `text/html;profile=mcp-app`. The host
  advertises the UI capability, not the server.
- The Cloudflare `agents` `McpAgent` forwards `_meta` and serves `ui://`
  resources correctly.
- MCP Apps render in the consumer Claude app on web, desktop, AND iOS/Android
  for a custom connector added by URL -- no Connectors Directory submission is
  needed (submission governs the "Interactive" badge / listing, not whether a
  personal connector renders).
- The host appends a note to the tool result ("...do not repeat it in
  text...") so Claude suppresses redundant prose when a widget renders.

## Verified gotchas (do not rediscover)

- **Bundle the client into the served HTML** (esbuild, inlined string). Do NOT
  load the ext-apps bridge from a CDN -- a runtime CDN dependency is a load-time
  failure point and a CSP entry to avoid. (`esm.sh ?bundle` failed; jsdelivr
  `/+esm` worked but is still fragile.)
- **zod-locale bloat**: zod v4 (pulled in by ext-apps) bundles ~40 locale files
  (~190 KB). Alias every non-`en` locale to `en` in esbuild (see
  `scripts/build-ui.mjs`) -- roughly halves the bundle. The `App` ctor sets zod
  `jitless` (CSP-safe, no eval).
- **`updateModelContext` does NOT surface to the model** on the consumer app
  (tested across model tiers). The store is the source of truth; the model only
  learns of widget activity by calling a tool (e.g. `list_items`). Don't depend
  on pushed context for awareness.
- **Auto-resize fires only after the bridge connects** -- pre-connect the inline
  card is clipped. Keep critical content visible early and connect fast. A
  self-diagnosing status line is invaluable for device testing.
- The widget gets seed data via `ontoolresult` (the initiating tool's
  `CallToolResult`) and/or `ontoolinput` (the args); include a `callServerTool`
  fallback in case the seed never arrives.
- **Verify locally over Streamable HTTP** with the MCP SDK client
  (`scripts/verify-ui.mjs`) before any device test -- it saves round-trips.

## Tradeoffs

- One generic `open_view(view, ...)` dispatcher keeps the tool surface flat as
  widgets multiply. If its polymorphic per-view schema starts to strain
  tool-selection reliability, split into per-widget tools with specific schemas.
- Widgets do raw recall/capture only; any derived suggestion is Claude's, passed
  in as seed data. Keeps the capture/intelligence line clean.
- Existing consumer-surface caps still apply (tool result ~150k chars, ~5 min
  per call).
