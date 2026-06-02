#!/usr/bin/env node
// Scaffolds a new MCP-app-on-Cloudflare-Worker project from the bundled
// templates/ tree. Copies every file, substituting __PROJECT_NAME__ (kebab) and
// __CLASS_NAME__ (PascalCase), and renames the dot-stripped template files
// (gitignore -> .gitignore, dev.vars -> .dev.vars). Domain customization
// happens afterward, by hand. See SKILL.md.
import { readdir, readFile, writeFile, mkdir } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const [, , targetArg, nameArg] = process.argv;
if (!targetArg || !nameArg) {
  console.error("usage: node scaffold.mjs <target-dir> <project-name>");
  process.exit(1);
}

const projectName = nameArg.trim();
if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(projectName)) {
  console.error(`project name must be kebab-case (got "${projectName}")`);
  process.exit(1);
}
const className = projectName
  .split(/[^a-z0-9]+/)
  .filter(Boolean)
  .map((s) => s[0].toUpperCase() + s.slice(1))
  .join("");

const here = path.dirname(fileURLToPath(import.meta.url));
const templatesDir = path.join(here, "..", "templates");
const targetDir = path.resolve(targetArg);

const RENAME = { gitignore: ".gitignore", "dev.vars": ".dev.vars" };
const subst = (s) =>
  s.replaceAll("__PROJECT_NAME__", projectName).replaceAll("__CLASS_NAME__", className);

async function walk(dir, rel = "") {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const srcPath = path.join(dir, entry.name);
    const relPath = path.join(rel, entry.name);
    if (entry.isDirectory()) {
      await walk(srcPath, relPath);
      continue;
    }
    const outName = RENAME[entry.name] ?? entry.name;
    const outPath = path.join(targetDir, path.dirname(relPath), outName);
    await mkdir(path.dirname(outPath), { recursive: true });
    await writeFile(outPath, subst(await readFile(srcPath, "utf8")));
    console.log("  " + path.relative(targetDir, outPath));
  }
}

console.log(`Scaffolding ${projectName} (class ${className}) into ${targetDir}:`);
await walk(templatesDir);
console.log("\nNext:");
console.log(`  cd ${targetDir} && git init`);
console.log("  npm install");
console.log("  npm run dev                  # http://127.0.0.1:8787/devsecret/mcp");
console.log("  node scripts/verify-ui.mjs   # in another shell");
