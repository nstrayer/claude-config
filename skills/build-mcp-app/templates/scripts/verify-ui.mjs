// Verify the open_view widget wiring over Streamable HTTP: the tool carries
// _meta.ui, the ui:// resource serves the bundled HTML, and open_view returns a
// seed payload. Run against local dev (`npm run dev`) in another shell.
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

const secret = process.env.MCP_SECRET ?? "devsecret";
const url = new URL(process.env.MCP_URL ?? `http://127.0.0.1:8787/${secret}/mcp`);

const client = new Client({ name: "verify-ui", version: "0.0.0" });
await client.connect(new StreamableHTTPClientTransport(url));

const tools = (await client.listTools()).tools;
console.log("tools:", tools.map((t) => t.name).sort().join(", "));
const ov = tools.find((t) => t.name === "open_view");
console.log("open_view present:", !!ov);
console.log("open_view _meta:", JSON.stringify(ov?._meta));

const uri = ov?._meta?.ui?.resourceUri;
const read = await client.readResource({ uri });
const c = read.contents?.[0];
console.log("resource mimeType:", c?.mimeType);
console.log("resource html length:", typeof c?.text === "string" ? c.text.length : "(none)");

const res = await client.callTool({ name: "open_view", arguments: { view: "items" } });
const seed = JSON.parse(res.content?.[0]?.text ?? "{}");
console.log("seed keys:", Object.keys(seed).join(", "));
console.log("seed view:", seed.view, "| items:", seed.items?.length);

await client.close();
console.log("\ndone");
