# Auth via an unguessable secret in the URL path, not OAuth or a bearer header

The server authenticates by an unguessable secret in the URL path
(`https://<host>/<MCP_SECRET>/mcp`), validated against a Worker secret;
everything else 404s.

## Why

The target client is the consumer claude.ai custom-connector UI, which accepts
only a URL plus optional OAuth client id/secret -- there is no field for a
static `Authorization` header, so a bearer token cannot be supplied from the
phone. For a single-user personal tool, full OAuth 2.1 is disproportionate. A
high-entropy path secret works with the URL-only UI and is reasonable protection
for personal data.

## Tradeoffs / consequences

- The URL is the credential -- treat it like a password.
- It can appear in request logs (Worker observability is on) and has no
  rotation/revocation beyond changing the secret.
- Replace with OAuth 2.1 (Cloudflare `workers-oauth-provider`) when
  productionizing or going multi-user.

Easily reversible; recorded only because a reader will otherwise wonder why a
secret is in the URL.
