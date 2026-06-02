// Smoke test: connect over Streamable HTTP and exercise the CRUD tools.
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

const secret = process.env.MCP_SECRET ?? "devsecret";
const url = new URL(process.env.MCP_URL ?? `http://127.0.0.1:8787/${secret}/mcp`);

const client = new Client({ name: "smoke", version: "0.0.0" });
await client.connect(new StreamableHTTPClientTransport(url));

const call = async (name, args = {}) =>
  (await client.callTool({ name, arguments: args })).content?.[0]?.text ?? "";
const parse = (s) => {
  try {
    return JSON.parse(s);
  } catch {
    return s;
  }
};

console.log("TOOLS:", (await client.listTools()).tools.map((t) => t.name).sort().join(", "));

const a = parse(await call("save_item", { text: "first item" }));
console.log("saved:", a.id, a.text);
await call("save_item", { text: "second item" });
await call("save_item", { id: a.id, text: "first item (edited)" });
const items = parse(await call("list_items"));
console.log("items:", items.map((i) => i.text).join(" | "));
console.log(await call("delete_item", { id: a.id }));
console.log("after delete:", parse(await call("list_items")).length);

await client.close();
console.log("\ndone");
