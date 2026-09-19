---
name: agent-config-maintenance
description: Use when adding, changing, reviewing, or documenting reusable Claude Code or Codex configuration assets in this repository.
---

# Agent Configuration Maintenance

Maintain this repository as a portable configuration source, rather than as a machine-specific home directory.

## Workflow

1. Identify whether an asset is Claude Code-specific, Codex-specific, or portable.
2. Preserve compatible assets for the other runtime; add a parallel asset when the formats differ.
3. Update `README.md` whenever a consumer-facing path, installation step, or compatibility statement changes.
4. Check relative Markdown links, YAML frontmatter, and secret-exclusion rules before finishing.

## Codex Placement

- Put repository instructions in `AGENTS.md`.
- Put reusable repository skills in `.agents/skills/<name>/SKILL.md`.
- Do not commit personal `~/.codex/config.toml`, session data, credentials, or workspace-specific state.

## Quality Bar

Keep instructions concrete, concise, and scoped. Do not claim Claude Code commands, agents, hooks, or settings work in Codex without verifying the equivalent feature and its file format.
