---
name: build-mcp-app
description: Scaffold a new MCP server on a Cloudflare Worker -- thin CRUD tools over KV plus an optional interactive MCP Apps widget that renders in the Claude consumer app (web/desktop/iOS). Use when the user wants to build an MCP server, a Claude custom connector, an "MCP app", or a Cloudflare Worker MCP, especially one with an in-chat UI widget.
argument-hint: [project-name]
---

# Build an MCP app (Cloudflare Worker)

Scaffolds the pattern proven in workout-mcp: a `McpAgent` + `McpServer` served
over Streamable HTTP, secret-in-path auth, KV storage, a thin CRUD tool surface,
and (by default) an interactive MCP Apps widget that renders in the Claude
consumer app. The hard-won bits -- the `_meta.ui` contract, the esbuild
zod-locale fix, the verify scripts -- are baked into the templates so they are
never rediscovered. Read [REFERENCE.md](REFERENCE.md) for the full rationale and
the gotchas you must preserve.

## 1. Intake (ask briefly, then build)

Ask only what you need, one or two questions at a time:

1. **Project name** (kebab-case, e.g. `recipe-mcp`) and **target directory**
   (default: `../<name>` relative to the cwd).
2. **Include the MCP Apps UI widget?** (default yes -- it is the point of this
   pattern). If no, run the "Strip the UI" checklist in REFERENCE.md after
   scaffolding.

Default storage is Workers KV. Only switch to Durable Object SQL if the user
asks -- see REFERENCE.md "Storage".

## 2. Scaffold

Run the bundled scaffolder. It copies `templates/`, substitutes the project name
and the PascalCase Durable Object class name, and writes `.gitignore` /
`.dev.vars`:

```sh
node ${CLAUDE_SKILL_DIR}/scripts/scaffold.mjs <target-dir> <project-name>
```

Then `cd <target-dir> && git init` (it is a fresh project).

## 3. Customize to the domain

The scaffold ships a generic `Item` store as a worked example. Replace it with
the user's real domain, editing these in lockstep so the contract stays intact:

- `src/index.ts` -- the store shape, the CRUD tools, and the `open_view` seed.
- `client/widget.ts` -- what the widget shows and which tools it calls.
- `scripts/build-ui.mjs` -- the widget's HTML/CSS shell. **Keep the esbuild call
  and the `oneZodLocale` plugin EXACTLY as-is.**
- `scripts/verify-ui.mjs`, `scripts/smoke.mjs` -- the tool/view names.
- `CONTEXT.md`, `README.md`, `docs/adr/` -- the domain language and decisions.

Keep the tool surface thin: intelligence belongs in Claude's reasoning over the
data, not in coded features.

## 4. Verify locally (before any device test)

```sh
npm install
npm run typecheck           # runs build:ui then tsc --noEmit
npm run dev                 # wrangler dev on http://127.0.0.1:8787
node scripts/verify-ui.mjs  # another shell: checks the _meta.ui + ui:// wiring
node scripts/smoke.mjs      # exercises the CRUD tools
```

Verifying the protocol locally over Streamable HTTP saves many device
round-trips. Only after this passes, deploy and add the URL connector (steps are
in the generated README.md).

## Gotchas you must preserve

The full list is in REFERENCE.md. The critical ones: bundle the client (no CDN),
keep the zod-locale esbuild alias, the `ui://` resource mimeType is exactly
`text/html;profile=mcp-app`, and the model only learns of widget writes by
re-reading a tool (not via pushed `updateModelContext`).
