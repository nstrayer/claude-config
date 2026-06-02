// Items View widget (React, runs in the MCP Apps iframe). Bundled with its
// Tailwind CSS by scripts/build-ui.mjs into a self-contained HTML string the
// Worker serves as a ui:// resource. Raw recall + capture only (docs/adr/0002):
// shows recent Items and adds new ones via the existing CRUD tools.
import { useEffect, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import { useApp, useHostStyleVariables } from "@modelcontextprotocol/ext-apps/react";

type Item = { id: string; at: string; text: string };
type Seed = { view: string; items: Item[] };

const fmtDate = (iso: string) =>
  new Date(iso).toLocaleDateString(undefined, { month: "short", day: "numeric" });

function Widget() {
  const [items, setItems] = useState<Item[]>([]);
  const [status, setStatus] = useState("loading...");
  const [text, setText] = useState("");
  const seeded = useRef(false);

  const { app, isConnected, error } = useApp({
    appInfo: { name: "__PROJECT_NAME__-view", version: "0.1.0" },
    capabilities: {},
    onAppCreated: (a) => {
      // Seed from the initiating open_view result (preferred).
      a.ontoolresult = (p) => {
        for (const b of (p.content ?? []) as Array<{ type?: string; text?: string }>) {
          if (b?.type === "text" && typeof b.text === "string") {
            try {
              const seed = JSON.parse(b.text) as Seed;
              if (seed && seed.view) {
                setItems(seed.items ?? []);
                seeded.current = true;
                setStatus("ready");
                return;
              }
            } catch {
              /* not our seed block */
            }
          }
        }
      };
    },
  });

  // Match the host's palette + light/dark via its CSS variables.
  useHostStyleVariables(app, app?.getHostContext());

  const refresh = async (a = app) => {
    if (!a) return;
    const res = await a.callServerTool({ name: "list_items", arguments: { limit: 10 } });
    const txt = (res.content?.[0] as { text?: string })?.text;
    setItems(txt ? JSON.parse(txt) : []);
  };

  // Fallback: if the seed never arrived, fetch items ourselves once connected.
  useEffect(() => {
    if (!isConnected || !app || seeded.current) return;
    let cancelled = false;
    const t = setTimeout(async () => {
      if (seeded.current) return;
      try {
        await refresh(app);
        if (!cancelled) setStatus("ready");
      } catch (e) {
        if (!cancelled) setStatus("load failed: " + ((e as Error)?.message ?? String(e)));
      }
    }, 350);
    return () => {
      cancelled = true;
      clearTimeout(t);
    };
  }, [isConnected, app]);

  async function addItem() {
    const t = text.trim();
    if (!t || !app) {
      setStatus("enter some text");
      return;
    }
    setStatus("saving...");
    try {
      await app.callServerTool({ name: "save_item", arguments: { text: t } });
      setText("");
      await refresh();
      setStatus("saved");
      // The model learns of widget writes by re-reading via list_items; the host
      // does not surface updateModelContext to the model. See docs/adr/0002.
    } catch (e) {
      setStatus("save failed: " + ((e as Error)?.message ?? String(e)));
    }
  }

  if (error) return <div className="p-4 text-fg">Error: {error.message}</div>;

  return (
    <div className="mx-auto max-w-[520px] p-3.5 text-fg">
      <h1 className="mb-3 text-xl font-semibold">Items</h1>
      <div className="mb-1 text-[11px] uppercase tracking-wide text-muted">Recent</div>
      <div>
        {items.length === 0 ? (
          <div className="text-sm text-muted">No items yet.</div>
        ) : (
          items.map((it) => (
            <div key={it.id} className="flex gap-3 border-b border-border py-1.5 text-sm">
              <span className="whitespace-nowrap text-muted">{fmtDate(it.at)}</span>
              <span className="flex-1">{it.text}</span>
            </div>
          ))
        )}
      </div>
      <div className="mt-3 flex gap-2">
        <input
          className="flex-1 rounded-lg border border-border px-3 py-2.5 text-base outline-none"
          value={text}
          onChange={(e) => setText(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") addItem();
          }}
          placeholder="Add an item..."
        />
        <button
          className="rounded-lg bg-accent px-4 py-2.5 text-base font-semibold text-white active:opacity-80"
          onClick={addItem}
        >
          Add
        </button>
      </div>
      <div className="mt-2.5 min-h-[18px] text-sm text-muted">
        {isConnected ? status : "connecting..."}
      </div>
    </div>
  );
}

createRoot(document.getElementById("root")!).render(<Widget />);
