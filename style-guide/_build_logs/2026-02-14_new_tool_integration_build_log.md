# Build Log — §1.13 new tool integration (git MCP + Context7)

## Session
- **Date started:** 2026-02-14
- **Status:** COMPLETE
- **Scope:** Add mcp-server-git and Context7 to §1.13 routing tables; verify both tools connect
- **Style guide sections to load:** §1 (editing §1.13), §2.3 (pre-flight)
- **Style guide version:** 3.10 → 3.11
- **Files in scope:** 2
- **Predecessor:** `2026-02-14_tool_assignment_rewrite_build_log.md` (§1.13 rewrite to operation-based routing — COMPLETE)

## Context from prior session
- §1.13 was rewritten from tool-identity routing to operation-based routing (v3.10)
- ripgrep added as primary search tool, Filesystem MCP rehabilitated for reads
- Four subsections: §1.13.1 (file ops), §1.13.2 (HA ops), §1.13.3 (known quirks), §1.13.4 (decision rules)
- `claude_desktop_config.json` updated with git and context7 entries — verified valid JSON
- `uvx` confirmed at `/Users/madalone/.local/bin/uvx` (v0.10.0)
- Context7 API key configured (ctx7sk-c5c16a93-...)
- git MCP pointed at `GIT_REPO` (/Users/madalone/_Claude Projects/HA-Master-Repo)

## File Queue
- [x] DONE — 00_core_philosophy.md | Add git MCP + Context7 to §1.13 routing tables + update §2.6
- [x] DONE — ha_style_guide_project_instructions.md | Version bump 3.10 → 3.11, changelog

## Planned Changes

### 00_core_philosophy.md
1. §1.13.1 — Add row for git operations (status, diff, log, commit) → git MCP
2. §1.13.2 — Add row for Context7 documentation lookups (HA Jinja2, ESPHome, Music Assistant)
3. §1.13.3 — Add known quirks for both tools (git MCP --repository lock, Context7 coverage gaps)
4. §1.13.4 — Add decision rules #9 (git operations on style guide repo) and #10 (need current library docs)

### ha_style_guide_project_instructions.md
5. Version bump 3.10 → 3.11
6. Changelog entry

## Pre-session checklist
- [x] Restart Claude Desktop
- [x] Verify git MCP connects (12 tools loaded, git_status returned clean tree on main)
- [x] Verify context7 connects (resolve-library-id returned 5 HA doc libraries, 7101+ snippets)
- [x] If git MCP fails: replace `"command": "uvx"` with `"command": "/Users/madalone/.local/bin/uvx"` in claude_desktop_config.json — NOT NEEDED
- [x] Run test: use git MCP to check `git status` on HA-Master-Repo — clean, up to date with origin/main
- [x] Run test: use Context7 to look up HA Jinja2 template docs — resolved /home-assistant/home-assistant.io (High reputation, 7101 snippets)

## Issues Found
| # | File | AP-ID | Severity | Line | Description | Status |
|---|------|-------|----------|------|-------------|--------|

## Fixes Applied
| # | File | Description | Issue ref |
|---|------|-------------|-----------|
| 1 | 00_core_philosophy.md | §1.13.1: Added git operations row → git MCP for GIT_REPO | — |
| 2 | 00_core_philosophy.md | §1.13.2: Added Context7 documentation lookups row | — |
| 3 | 00_core_philosophy.md | §1.13.3: Added 4 quirk entries (git MCP repo_path, Context7 gaps, Context7 multi-match) | — |
| 4 | 00_core_philosophy.md | §1.13.4: Added decision rules #9 (git → git MCP) and #10 (docs → Context7) | — |
| 5 | 00_core_philosophy.md | §1.13 cross-references: Added Post-Edit Publish Workflow reference | — |
| 6 | 00_core_philosophy.md | §2.6: Replaced sync-to-repo.sh reference with Post-Edit Publish Workflow | — |
| 7 | 00_core_philosophy.md | §2.6 decision table: Updated PROJECT_DIR and mixed-scope rows | — |
| 8 | ha_style_guide_project_instructions.md | Version bump 3.10 → 3.11 | — |
| 9 | ha_style_guide_project_instructions.md | Changelog entry for v3.11 | — |

## Current State
Build complete. Both tools (git MCP, Context7) verified operational and integrated into §1.13 routing tables. §2.6 updated to reference the new Post-Edit Publish Workflow (Claude-native rsync + git MCP) instead of the obsoleted sync-to-repo.sh script. Style guide version bumped to 3.11.
