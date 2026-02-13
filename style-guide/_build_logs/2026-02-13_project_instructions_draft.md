# Draft: Claude Project Instructions — HA Master Style Guide

**Purpose:** This text goes into the Claude Project "Set project instructions" field.
It loads every conversation before any style guide files, providing session-level constants.

**Status:** DRAFT — awaiting user review before pasting.

---

## Proposed Text (copy everything below this line into project instructions)

```
## Project Paths

- PROJECT_DIR: /Users/madalone/_Claude Projects/HA Master Style Guide/
- HA_CONFIG: /Users/madalone/Library/Containers/nz.co.pixeleyes.AutoMounter/Data/Mounts/Home Assistant/SMB/config/
- GIT_REPO: /Users/madalone/_Claude Projects/HA Master Repo/

All style guide references to "the project directory," "the HA config path," or "the git repo" resolve to these paths. If any path changes, update it here — the style guide does not hardcode them.

---

## File Transfer Rules

1. **NEVER** chunk files over SSH. NEVER use base64 encoding over SSH.
2. For ALL file writes to Home Assistant, use Desktop Commander `write_file` directly to the SMB mount path (`HA_CONFIG` above).
3. For files over 30KB, use append mode — write the first section with `mode: rewrite`, then continue with `mode: append`. Do NOT attempt a single monolithic write.
4. **Always verify** the file after writing with a Desktop Commander `read_file` operation. No exceptions.
5. For style guide and build log writes, use Desktop Commander `write_file` to `PROJECT_DIR`.

---

## Filesystem Rules — Claude's Computer vs User's Computer

Claude has access to TWO filesystems. Confusing them wastes time and breaks things.

| Filesystem | Access via | Use for |
|---|---|---|
| **User's machine** (macOS) | Desktop Commander / Filesystem MCP tools (`read_file`, `write_file`, `list_directory`, `edit_block`, etc.) | ALL reads/writes to HA config, project files, build logs, style guide docs. This is where real work happens. |
| **Claude's container** (`/home/claude/`, `/mnt/`) | Claude's internal tools (`bash_tool`, `create_file`, `view`, `present_files`) | Temporary scratch work, generating artifacts for download, running scripts. Files here reset between sessions. |

**Rules:**
- **Default to the user's filesystem** for everything. If the task involves reading, writing, or editing any project file, HA config, or build log — use Desktop Commander / Filesystem MCP.
- **Never use Claude's internal computer** (`bash_tool`, `create_file`) for files destined for the user's system. Those tools operate on a separate, ephemeral container.
- **Only use Claude's computer** for: temporary computation, generating downloadable artifacts, running validation scripts, or tasks that explicitly don't touch the user's files.
- When the user says "read this file" or "check this path" — assume they mean THEIR filesystem unless the path starts with `/home/claude/` or `/mnt/`.
- If a tool call fails on one filesystem, check whether you're targeting the wrong one before retrying.

---

## Git Workflow

- Source of truth: style guide files live in `PROJECT_DIR`. Blueprints live on `HA_CONFIG`.
- Git repo (`GIT_REPO`) is synced via `sync.sh pull` after edits. Commits happen in the repo.
- For HA config changes tracked by the HA MCP git tools: use `ha_create_checkpoint` / `ha_git_commit` / `ha_git_rollback` as documented in the style guide §2.
- For style guide changes: edit in `PROJECT_DIR`, then the user syncs to `GIT_REPO` and commits.
```
