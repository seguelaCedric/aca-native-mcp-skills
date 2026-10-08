#!/usr/bin/env node
// Builds commands.json (the command reference shown at
// automatedclientacquisition.com/mcp/commands) from the skills themselves:
// groups and one-line summaries come from skills/aca/SKILL.md, details from
// each skill's frontmatter description and its "ACA tools used" / "ACA app
// pages" sections. Usage: node scripts/export-commands.mjs [outFile]
import { readFileSync, writeFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const APP = "https://www.automatedclientacquisition.com";
const v1 = new Set(JSON.parse(readFileSync(join(root, "scripts/v1-tools.json"), "utf8")).tools);

export function commandGroups() {
  const overview = readFileSync(join(root, "skills/aca/SKILL.md"), "utf8");
  const start = overview.indexOf("### 4. The commands");
  const end = overview.indexOf("\n### ", start + 1);
  const groups = [];
  for (const line of overview.slice(start, end).split("\n")) {
    const heading = line.match(/^\*\*(.+)\*\*$/);
    if (heading) {
      groups.push({ group: heading[1], commands: [] });
      continue;
    }
    const item = line.match(/^- (.+?): (.+)$/);
    if (!item || !groups.length) continue;
    for (const [, name] of item[1].matchAll(/`\/([a-z0-9-]+)`/g)) {
      groups.at(-1).commands.push({ name, summary: item[2].trim() });
    }
  }
  return groups;
}

function section(text, title) {
  const at = text.indexOf(`\n## ${title}`);
  if (at === -1) return "";
  const next = text.indexOf("\n## ", at + 1);
  return text.slice(at, next === -1 ? undefined : next);
}

function describe(name) {
  const file = join(root, "skills", name, "SKILL.md");
  if (!existsSync(file)) throw new Error(`skills/aca/SKILL.md lists /${name}, but skills/${name}/SKILL.md does not exist`);
  const text = readFileSync(file, "utf8");
  const front = text.match(/^---\n([\s\S]*?)\n---/)?.[1] || "";
  const raw = front.match(/^description:\s*(>-?\n(?:\s+.+\n?)+|.+)$/m)?.[1] || "";
  const description = raw.replace(/^>-?\n/, "").replace(/\s+/g, " ").trim().replace(/^["']|["']$/g, "");
  const firstSentence = description.split(/(?<=\.)\s/)[0];
  const tools = [...new Set([...section(text, "ACA tools used").matchAll(/`([a-z_]+)`/g)].map((m) => m[1]))]
    .filter((tool) => v1.has(tool));
  const pages = new Set();
  for (const [, url] of section(text, "ACA app pages").matchAll(/`?(https:\/\/www\.automatedclientacquisition\.com\/[^\s`,)]*|\/[a-z][a-z0-9/?=&{}_-]*)`?/g)) {
    pages.add(url.startsWith("http") ? url : `${APP}${url}`);
  }
  return { description: firstSentence, tools, appPages: [...pages] };
}

const groups = commandGroups().map(({ group, commands }) => ({
  group,
  commands: commands.map(({ name, summary }) => ({ command: `/${name}`, summary, ...describe(name) })),
}));
const out = process.argv[2] || join(root, "commands.json");
writeFileSync(out, JSON.stringify({ generatedFrom: "seguelaCedric/aca-native-mcp-skills", groups }, null, 2) + "\n");
console.log(`Wrote ${groups.reduce((n, g) => n + g.commands.length, 0)} commands to ${out}`);
