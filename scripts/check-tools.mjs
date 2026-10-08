#!/usr/bin/env node
// Fails when a skill names a tool the ACA OAuth connector does not serve, or
// when a root-level skill copy drifts from skills/. Refresh scripts/v1-tools.json
// from the server's tools/list whenever the connector catalog changes.
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const v1 = new Set(JSON.parse(readFileSync(join(root, "scripts/v1-tools.json"), "utf8")).tools);
const legacy = new Set(JSON.parse(readFileSync(join(root, "scripts/legacy-tools.json"), "utf8")).tools);
const problems = [];

const skillsDir = join(root, "skills");
for (const name of readdirSync(skillsDir).sort()) {
  const file = join(skillsDir, name, "SKILL.md");
  if (!existsSync(file)) continue;
  const text = readFileSync(file, "utf8");
  text.split("\n").forEach((line, i) => {
    for (const [token] of line.matchAll(/\b[a-z]+(?:_[a-z0-9]+)+\b/g)) {
      if (legacy.has(token) && !v1.has(token)) {
        problems.push(`skills/${name}/SKILL.md:${i + 1}: \`${token}\` is not served by the ACA connector`);
      }
    }
  });
  const copy = join(root, name, "SKILL.md");
  if (existsSync(copy) && readFileSync(copy, "utf8") !== text) {
    problems.push(`${name}/SKILL.md differs from skills/${name}/SKILL.md (run scripts/sync-root-skills.sh)`);
  }
}

// Every skill must appear in the /aca command list (and so on the docs page).
const overview = readFileSync(join(skillsDir, "aca/SKILL.md"), "utf8");
for (const name of readdirSync(skillsDir)) {
  if (name === "aca" || !existsSync(join(skillsDir, name, "SKILL.md"))) continue;
  if (!overview.includes(`\`/${name}\``)) {
    problems.push(`skills/aca/SKILL.md does not list /${name}`);
  }
}

if (problems.length) {
  console.error(problems.join("\n"));
  console.error(`\n${problems.length} problem(s).`);
  process.exit(1);
}
console.log(`All skills reference only the ${v1.size} connector tools, and root copies match.`);
