#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const args = process.argv.slice(2);
const targetIndex = args.indexOf('--target');
const target = path.resolve(targetIndex >= 0 ? args[targetIndex + 1] : process.cwd());

const required = [
  'AGENTS.md',
  'HEARTBEAT.md',
  path.join('docs', 'vibe-workflow.md'),
  path.join('skills', 'vibe-builder', 'SKILL.md'),
  path.join('skills', 'vibe-builder', 'references', 'mode-heuristics.md'),
  path.join('skills', 'vibe-builder', 'references', 'feature-add.md'),
  path.join('skills', 'vibe-builder', 'references', 'bug-fix-loop.md'),
  path.join('skills', 'vibe-builder', 'references', 'crawbot-integration.md')
];

const missing = required.filter((file) => !fs.existsSync(path.join(target, file)));
const result = {
  ok: missing.length === 0,
  target,
  required,
  missing,
  node: process.version,
  platform: process.platform
};

console.log(JSON.stringify(result, null, 2));
process.exit(result.ok ? 0 : 1);
