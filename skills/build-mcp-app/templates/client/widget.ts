// Items View widget (browser, runs in the MCP Apps iframe). Bundled by
// scripts/build-ui.mjs into a self-contained HTML string the Worker serves as a
// ui:// resource. Raw recall + capture only (see docs/adr/0002): shows recent
// Items and adds new ones via the existing CRUD tools. No derived logic.
import { App } from "@modelcontextprotocol/ext-apps";

type Item = { id: string; at: string; text: string };
type Seed = { view: string; items: Item[] };

const $ = (id: string) => document.getElementById(id) as HTMLElement;
const input = (id: string) => document.getElementById(id) as HTMLInputElement;
const el = (tag: string, cls?: string, txt?: string) => {
  const n = document.createElement(tag);
  if (cls) n.className = cls;
  if (txt != null) n.textContent = txt;
  return n;
};
const setStatus = (s: string) => {
  $("status").textContent = s;
};

let app: App;

const fmtDate = (iso: string) =>
  new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric" });

function renderItems(items: Item[]) {
  const wrap = $("items");
  wrap.innerHTML = "";
  if (!items.length) {
    wrap.appendChild(el("div", "muted", "No items yet."));
    return;
  }
  for (const it of items) {
    const row = el("div", "row");
    row.appendChild(el("span", "row-date", fmtDate(it.at)));
    row.appendChild(el("span", "row-text", it.text));
    wrap.appendChild(row);
  }
}

function applySeed(seed: Seed) {
  renderItems(seed.items ?? []);
  setStatus("ready");
}

async function refresh() {
  const res = await app.callServerTool({ name: "list_items", arguments: { limit: 10 } });
  const txt = (res.content?.[0] as { text?: string })?.text;
  renderItems(txt ? JSON.parse(txt) : []);
}

async function addItem() {
  const t = input("text").value.trim();
  if (!t) {
    setStatus("enter some text");
    return;
  }
  setStatus("saving...");
  try {
    await app.callServerTool({ name: "save_item", arguments: { text: t } });
    input("text").value = "";
    await refresh();
    setStatus("saved");
    // The model learns of widget writes by re-reading via list_items; the host
    // does not surface updateModelContext to the model. See docs/adr/0002.
  } catch (e) {
    setStatus("save failed: " + ((e as Error)?.message ?? String(e)));
  }
}

async function main() {
  app = new App({ name: "__PROJECT_NAME__-view", version: "0.1.0" });
  let seeded = false;

  // Seed from the initiating open_view result (preferred) ...
  app.ontoolresult = (p) => {
    for (const b of (p.content ?? []) as Array<{ type?: string; text?: string }>) {
      if (b?.type === "text" && typeof b.text === "string") {
        try {
          const seed = JSON.parse(b.text);
          if (seed && seed.view) {
            applySeed(seed);
            seeded = true;
            return;
          }
        } catch {
          /* not our seed block */
        }
      }
    }
  };

  $("addbtn").addEventListener("click", addItem);
  renderItems([]);

  await app.connect();
  if (seeded) return;
  setStatus("connected");

  // ... else give the host a moment to deliver the result, then fall back to
  // fetching items ourselves if the seed never arrived (auto-resize fires only
  // after connect, so keep content small and load fast).
  await new Promise((r) => setTimeout(r, 350));
  if (seeded) return;
  setStatus("loading (fallback)...");
  try {
    await refresh();
    setStatus("ready (fallback)");
  } catch (e) {
    setStatus("load failed: " + ((e as Error)?.message ?? String(e)));
  }
}

main().catch((e) => setStatus("widget error: " + ((e as Error)?.message ?? String(e))));
