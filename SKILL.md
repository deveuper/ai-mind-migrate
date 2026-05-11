# AI Mind Migrate

> Seamlessly migrate your project context, rules, and memory between AI coding assistants.
> From Claude Code to Cursor, from WorkBuddy to Codex — one command to carry your mind everywhere.

## When to Use

Trigger this skill when the user wants to:

- **Migrate** project context/rules from one AI coding assistant to another
- **Export** their current project's AI memory to a different platform's format
- **Sync** or **port** their coding rules, conventions, and project knowledge across tools
- **Initialize** a project for a new AI assistant based on existing context from another
- **Convert** between any supported AI assistant memory format (e.g., "convert my CLAUDE.md to Cursor rules")
- **Detect** which AI assistant memory files exist in the current project
- **Generate** a universal canonical format from any existing project memory

Keywords: migrate, transfer, port, convert, export, sync, move, switch, cross-tool, memory, rules, context, CLAUDE.md, AGENTS.md, cursorrules, copilot, workbuddy, codebuddy, trae, lingma, augment, cline, roo, windsurf, gemini, aider

---

## Supported Platforms (15)

| # | Platform | Primary File(s) | Rules Directory | Global Location | Notes |
|---|----------|----------------|-----------------|-----------------|-------|
| 1 | **Claude Code** | `CLAUDE.md`, `.claude/CLAUDE.md` | `.claude/rules/*.md` | `~/.claude/CLAUDE.md` | Also has `skills/`, `agents/`, `commands/`, `agent-memory/`, `output-styles/`, `settings.json`, `.mcp.json` |
| 2 | **OpenAI Codex** | `AGENTS.md` | — | `~/.codex/AGENTS.md` | Also `AGENTS.override.md`, `~/.codex/config.toml` |
| 3 | **GitHub Copilot** | `.github/copilot-instructions.md` | `.github/instructions/*.instructions.md` | — | Also reads `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` |
| 4 | **Cursor** | `AGENTS.md` (simple) | `.cursor/rules/*.mdc` | Cursor Settings → Rules UI | `.cursorrules` is legacy/deprecated (Mar 2026+). `.mdc` supports `description`, `globs`, `alwaysApply` |
| 5 | **Windsurf** | `.windsurfrules` (legacy) | `.windsurf/rules/*.md` | Windsurf Settings UI (not a file) | Also reads `AGENTS.md`. 6K chars per rule file, 12K total across all active rules |
| 6 | **Gemini CLI** | `GEMINI.md` | — | `~/.gemini/GEMINI.md` | `@file.md` imports, settings.json `context.fileName` |
| 7 | **Aider** | `CONVENTIONS.md` (⚠️ use `--read`) | — | `~/.aider.conf.yml` | NOT auto-loaded — must be explicitly referenced |
| 8 | **Cline** | `.clinerules` | `.clinerules/*.md` | `~/Documents/Cline/Rules/` or `~/.cline/rules/` | Only `paths` frontmatter (official docs). Also auto-detects `.cursorrules`, `.windsurfrules`, `AGENTS.md` |
| 9 | **Roo Code** | `.roorules` (legacy) | `.roo/rules/*.md`, `.roo/rules-{mode}/*.md` | `~/.roo/rules/` | Also reads `AGENTS.md`. Supports `.md` and `.txt` files |
| 10 | **WorkBuddy** | `.workbuddy/memory/MEMORY.md` | `~/.workbuddy/memory/` (daily logs) | `~/.workbuddy/` (global: SOUL.md, IDENTITY.md, USER.md) | Project memory in `.workbuddy/memory/`. Daily logs: `YYYY-MM-DD.md`. User-level identity files at `~/.workbuddy/`. |
| 11 | **CodeBuddy** | `CODEBUDDY.md`, `.codebuddy/CODEBUDDY.md` | `.codebuddy/rules/{name}/RULE.mdc` | `~/.codebuddy/CODEBUDDY.md` | Also `CODEBUDDY.local.md`. `@path` imports, auto-memory at `~/.codebuddy/memories/`. 3 loading types: always/agentic/manual |
| 12 | **Trae** | `CLAUDE.md` (for rules), `.trae/rules/project_rules.md` | `.trae/rules/*.md` + `.trae/skills/` + `.trae/agents/` | `.trae/rules/user_rules.md` + `~/.trae/rules/user_rules.md` | Also has `settings.json`, `mcp.json`, `tasks.json`. Priority: user input > project_rules.md > project user_rules.md > global user_rules.md > defaults |
| 13 | **TONGYI Lingma** | — | `.lingma/rules/*.md` | — | 4 types via IDE UI (Manual, Model Decision, Always, Specific Files). 10K char limit |
| 14 | **Augment Code** | `.augment/guidelines.md` | `.augment/rules/*.md` | `~/.augment/rules/` | Also reads `AGENTS.md`, `CLAUDE.md`. `.augment-guidelines` is still valid as another option. |
| 15 | **Qoder/QCode** | `AGENTS.md` | `.qoder/rules/*.md` (Qoder rules) | — | Qoder uses same 4 rule types as Lingma (Manual, Model Decision, Always, Specific Files). 100K char limit total across active rules. AGENTS.md also supported; `.qoder/rules/` takes precedence on conflict. |

---

## Architecture: Canonical → Platform Format

The migration uses a **canonical intermediate format** as the single source of truth.

```
┌─────────────────┐      Parse       ┌──────────────────┐     Generate     ┌──────────────────┐
│  Source Platform │  ──────────────> │  Canonical Format │  ──────────────> │  Target Platform  │
│  (e.g., CLAUDE.md)│                 │  (Internal Model) │                  │  (e.g., .cursor/) │
└─────────────────┘                   └──────────────────┘                   └──────────────────┘
```

### Canonical Format Schema

```yaml
# This is the internal representation — never written to disk directly
project:
  name: string
  description: string
  tech_stack: [string]

commands:
  build: string
  test: string
  lint: string
  dev: string
  install: string

structure:
  - path: string
    description: string

conventions:
  - category: string          # e.g., "code-style", "naming", "architecture"
    rules: [string]

boundaries:
  - description: string

preferences:
  language: string
  response_style: string
  framework_preferences: [string]

decisions:
  - date: string
    decision: string
    reasoning: string

scope_rules:                   # Platform-specific scoped rules
  - name: string
    paths: [string]            # Glob patterns
    rules: [string]

memory:                        # Auto-memory / daily log style content
  - type: string               # "user", "feedback", "project", "reference"
    content: string
    date: string               # ISO date
```

---

## Step-by-Step Migration Workflow

### Phase 1: Detect Source

Scan the project root for ALL known AI assistant memory files:

```
Files to check (in order):
  CLAUDE.md                    → Claude Code
  .claude/CLAUDE.md            → Claude Code (alt location)
  CLAUDE.local.md              → Claude Code (local/personal)
  .claude/rules/*.md           → Claude Code (modular rules)
  .claude/settings.json        → Claude Code (settings)
  AGENTS.md                    → Codex / Multi-tool standard / Cursor / QCode
  AGENTS.override.md           → Codex (override)
  .github/copilot-instructions.md → GitHub Copilot
  .github/instructions/*.instructions.md → GitHub Copilot (scoped)
  .cursor/rules/*.mdc          → Cursor (modern rules)
  .cursor/rules/*.md           → Cursor (simple rules)
  .windsurfrules               → Windsurf (legacy)
  .windsurf/rules/*.md         → Windsurf (modern)
  GEMINI.md                    → Gemini CLI
  CONVENTIONS.md               → Aider (⚠️ use --read, not auto-loaded)
  .clinerules                  → Cline (single file)
  .clinerules/*.md             → Cline (directory mode)
  .clinerules/*.txt            → Cline (directory mode, text)
  .roorules                    → Roo Code (legacy)
  .roo/rules/*.md              → Roo Code (modern, general)
  .roo/rules-code/*.md         → Roo Code (modern, code mode)
  .roo/rules-{mode}/*.md       → Roo Code (modern, any mode)
  .workbuddy/memory/MEMORY.md  → WorkBuddy
  .workbuddy/memory/*.md       → WorkBuddy (daily logs)
  ~/.workbuddy/SOUL.md         → WorkBuddy (soul, user-level)
  CODEBUDDY.md                 → CodeBuddy
  .codebuddy/CODEBUDDY.md      → CodeBuddy (alt location)
  CODEBUDDY.local.md           → CodeBuddy (local/personal)
  .codebuddy/rules/*.md        → CodeBuddy (modular rules)
  .trae/rules/project_rules.md → Trae
  .trae/rules/*.md             → Trae (project rules)
  .lingma/rules/*.md           → TONGYI Lingma
  .augment-guidelines          → Augment Code
  .augment/rules/*.md          → Augment Code (rules dir)
  .augment/guidelines.md       → Augment Code (guidelines alt)
```

**Output**: A list of detected platforms and their files, with content loaded.

### Phase 2: Parse to Canonical

For each detected source file, parse its content into the canonical format using platform-specific parsers.

#### Parser Rules Per Platform

**CLAUDE.md Parser:**
- Extract `##` headings as convention categories
- Parse `@path` imports and inline them
- Extract `---\npaths: [...]` frontmatter from `.claude/rules/*.md` as scope_rules
- Code blocks with commands → commands section
- Bulleted lists under headings → conventions rules

**AGENTS.md Parser:**
- `## Commands` → commands section
- `## Project Structure` → structure section
- `## Conventions` → conventions section
- `## Boundaries` → boundaries section
- `## Project` → project description

**Cursor Parser:**
- `AGENTS.md` (for Cursor): plain Markdown → conventions and commands
- `.cursor/rules/*.mdc`: parse YAML frontmatter
  - `alwaysApply: true` → scope_rules (always)
  - `alwaysApply: false` + `globs: [...]` → scope_rules with paths (auto-attached)
  - `alwaysApply: false` + `description` only (no globs) → scope_rules with description (agent-decided)
  - `alwaysApply: false` + no description + no globs → skip (manual-only rules)
- `.cursor/rules/*.md` (no frontmatter): plain Markdown → conventions

**Windsurf Parser:**
- `.windsurfrules`: plain text → conventions
- `.windsurf/rules/*.md`: parse YAML frontmatter
  - `trigger: always_on` → scope_rules (always)
  - `trigger: glob` + `globs: [...]` → scope_rules with paths
  - `trigger: manual` → note as manual-only rule
  - `description: ...` → rule name
- Body content → conventions rules

**Copilot Parser:**
- `.github/copilot-instructions.md`: plain Markdown → conventions
- `.github/instructions/*.instructions.md`: parse `applyTo` frontmatter → scope_rules

**GEMINI.md Parser:**
- Same as CLAUDE.md but for GEMINI.md
- Parse `@file.md` imports

**Aider Parser:**
- `CONVENTIONS.md`: plain Markdown → conventions

**Cline Parser:**
- `.clinerules`: plain text → conventions
- `.clinerules/*.md`: parse YAML frontmatter
  - `paths: [...]` → scope_rules with paths (conditional)
  - No frontmatter → scope_rules (always active, default behavior)
  - `paths: []` → rule is disabled (never matches)
  - ⚠️ Cline only supports `paths` frontmatter. No `description` or `alwaysApply`.

**Roo Code Parser:**
- `.roorules`: plain text → conventions
- `.roo/rules/*.md`: plain Markdown grouped by directory/mode
- `.roo/rules-{mode}/*.md`: conventions tagged with mode name

**WorkBuddy Parser:**
- `.workbuddy/memory/MEMORY.md`: long-term conventions and decisions
- `.workbuddy/memory/YYYY-MM-DD.md`: recent daily logs → memory entries with dates
- Section headings in MEMORY.md → convention categories

**CodeBuddy Parser:**
- `CODEBUDDY.md` / `.codebuddy/CODEBUDDY.md`: same as CLAUDE.md
- `.codebuddy/rules/*.md`: parse frontmatter
  - `alwaysApply` + `paths` → scope_rules
  - `enabled: false` → skip
- `@path` imports resolved
- Auto-memory typed format: extract `type` frontmatter

**Trae Parser:**
- `.trae/rules/project_rules.md`: plain Markdown → conventions

**TONGYI Lingma Parser:**
- `.lingma/rules/*.md`: natural language → conventions
- No frontmatter — treat all as "Always" type rules
- Respect 10,000 char limit per file

**Augment Parser:**
- `.augment-guidelines`: plain Markdown → conventions
- `.augment/rules/*.md`: parse frontmatter
  - `type: always_apply` → scope_rules (always)
  - `type: agent_requested` + `description` → scope_rules with description
- Also check AGENTS.md and CLAUDE.md as fallbacks

### Phase 3: Merge Canonical Sources

If multiple platforms are detected (e.g., both CLAUDE.md and AGENTS.md exist), **merge** them:

1. **Deduplicate** rules that appear in multiple sources
2. **Prioritize** platform-specific rules over generic ones
3. **Preserve** scope/path information from each source
4. **Mark** conflicts for user review

### Phase 4: Generate Target Format

For each target platform, generate the correct file structure and format.

---

## Platform-Specific Generators

### 1. Claude Code Generator

**Files to create:**

```
CLAUDE.md                          # Main project instructions
.claude/rules/                     # Modular rules (if scope_rules exist)
  ├── code-style.md                # Code style rules
  ├── testing.md                   # Testing rules
  └── {category}.md                # Any other scoped rules
```

**CLAUDE.md template:**

```markdown
# {project.name}

{project.description}

## Tech Stack
{formatted tech_stack list}

## Commands
{formatted commands}

## Project Structure
{formatted structure}

## Conventions
{formatted conventions by category}

## Boundaries
{formatted boundaries}

## Preferences
{formatted preferences}
```

**Rules file template (for `.claude/rules/{name}.md`):**

```markdown
---
paths:
  - "{glob_pattern}"
---

# {rule_name}

{rules}
```

**Key constraints:**
- Target ≤ 200 lines per CLAUDE.md
- Use `@AGENTS.md` import if AGENTS.md also exists
- `CLAUDE.local.md` for personal preferences (add to .gitignore)
- Subdirectory CLAUDE.md files for deep scoping

---

### 2. OpenAI Codex (AGENTS.md) Generator

**Files to create:**

```
AGENTS.md                           # Single project instructions file
```

**AGENTS.md template:**

```markdown
# AGENTS.md

## Project
{project.description}

## Commands
- Install: {commands.install}
- Build: {commands.build}
- Test: {commands.test}
- Lint: {commands.lint}
- Start: {commands.dev}

## Project Structure
{formatted structure}

## Conventions
{formatted conventions as bullet list}

## Boundaries
{formatted boundaries as bullet list}
```

**Key constraints:**
- Keep global `~/.codex/AGENTS.md` under 2–3 KB
- Total project docs under 32 KiB (default `project_doc_max_bytes`)
- No YAML frontmatter
- Support `AGENTS.override.md` for temporary overrides
- Use `project_doc_fallback_filenames` in config.toml if needed

---

### 3. GitHub Copilot Generator

**Files to create:**

```
.github/
  copilot-instructions.md           # Project-wide instructions
  instructions/                      # Scoped instructions (if scope_rules exist)
    {name}.instructions.md
```

**copilot-instructions.md template:**

```markdown
# Project Instructions

## Tech Stack
{formatted tech_stack}

## Commands
{formatted commands}

## Code Conventions
{formatted conventions}

## Architecture
{formatted structure}
```

**Scoped instructions template:**

```markdown
---
applyTo: "{glob_pattern}"
---

# {rule_name}

{rules}
```

**Key constraints:**
- Files merged without guaranteed ordering
- `applyTo` uses glob patterns for file matching
- Keep instructions concise and actionable

---

### 4. Cursor Generator

**Files to create:**

```
.cursor/
  rules/
    {name}.mdc                      # Modern format (with frontmatter)
    {name}.md                       # Simple format (no frontmatter, always active)
AGENTS.md                           # Alternative: simpler project-wide instructions
```

> NOTE: `.cursorrules` (single file) is NOT supported by Cursor's official documentation. Use `.cursor/rules/*.mdc` (with frontmatter) or `AGENTS.md` (simple global instructions) instead.

**User Rules**: Configured in Cursor Settings → Rules UI (not a file) — global to all projects.

**MDC file template (Always Apply):**

```markdown
---
description: "General coding standards"
alwaysApply: true
---

# General Coding Standards

{all non-scoped conventions}
```

**MDC file template (Auto Attached by globs):**

```markdown
---
description: "API development rules"
globs: src/api/**/*.ts, src/services/**/*.ts
alwaysApply: false
---

# API Development Rules

{scoped rules}
```

**MDC file template (Agent Decides):**

```markdown
---
description: "React component patterns and best practices"
alwaysApply: false
---

# React Component Guidelines

{rules for agent to decide when to apply}
```

**MDC file template (Manual only):**

```markdown
---
description: ""
alwaysApply: false
---

# Security Audit Rules

{rules only applied when user explicitly references them}
```

**AGENTS.md alternative (for when user doesn't want scoped rules):**

```markdown
# AGENTS.md

## Commands
...

## Project Structure
...

## Conventions
...
```

**Key constraints:**
- Use `.mdc` extension (Markdown+) for rules with frontmatter
- Use `.md` extension for simple always-active rules (no frontmatter)
- **4 activation modes** determined by frontmatter fields:
  | Mode | `alwaysApply` | `globs` | `description` |
  |------|:---:|:---:|:---:|
  | Always Apply | `true` | ignored | ignored |
  | Apply Intelligently | `false` | omitted | provided |
  | Apply to Specific Files | `false` | provided | optional |
  | Manual | `false` | omitted/empty | omitted/empty |
- AGENTS.md is also officially supported as a simple alternative

---

### 5. Windsurf Generator

**Files to create:**

```
.windsurf/
  rules/
    {name}.md                       # Modern format
```

> NOTE: Do NOT generate legacy `.windsurfrules`. Use `.windsurf/rules/*.md` format.
> Global rules are configured via Windsurf Settings UI (not a file). No `global_rules.md` exists on disk.

**Rule file template:**

```markdown
---
trigger: {always_on|glob|manual|model_decision}
description: "{rule_description}"
globs:
  - "{glob_pattern}"
---

{rules_content}
```

**Key constraints:**
- **6,000 characters max per workspace rule file** (markdown body only; frontmatter excluded)
- **12,000 characters total across ALL active rules** (global + workspace combined)
- When limit exceeded: global rules loaded first, then workspace rules. Within each scope, `always_on` takes priority.
- `trigger` values: `always_on`, `glob`, `manual`, `model_decision`
- Global rules are configured via Windsurf Settings UI (not a file on disk)

---

### 6. Gemini CLI Generator

**Files to create:**

```
GEMINI.md                           # Project instructions
```

**GEMINI.md template:**

```markdown
# Project: {project.name}

{project.description}

## General Instructions
{general conventions}

## Coding Style
{code style conventions}

## Commands
{formatted commands}

## Project Structure
{formatted structure}
```

**Key constraints:**
- Supports `@file.md` imports for modularization
- Filename configurable via `settings.json` → `context.fileName`
- Can set `["AGENTS.md", "GEMINI.md"]` for interop with Codex
- Hierarchical discovery: global → project → subdirectory

---

### 7. Aider Generator

**⚠️ CRITICAL**: Unlike other platforms, Aider does NOT auto-load `CONVENTIONS.md`. You must explicitly tell Aider to use it via:

```bash
aider --read CONVENTIONS.md        # Load at startup
# Or in-chat:
/read CONVENTIONS.md
# Or in .aider.conf.yml:
read: CONVENTIONS.md
```

**Files to create:**

```
CONVENTIONS.md                      # Coding conventions (must be loaded explicitly)
```

**CONVENTIONS.md template:**

```markdown
# Conventions

## Code Style
{code style conventions}

## Architecture
{architecture conventions}

## Testing
{testing conventions}

## Commands
{formatted commands}
```

**Key constraints:**
- Simple Markdown format
- `CONVENTIONS.md` is the standard convention file
- `.aider.conf.yml` for tool configuration (not rules)
- Community convention files available at github.com/Aider-AI/conventions

---

### 8. Cline Generator

**⚠️ Frontmatter**: Cline's official docs support ONLY `paths` frontmatter. No `description`, no `alwaysApply`.

**Files to create (choose based on complexity):**

Simple project (no scoped rules needed):
```
.clinerules                         # Single file
```

Complex project (scoped rules needed):
```
.clinerules/
  01-stack.md
  02-conventions.md
  03-testing.md
  04-api-patterns.md                # With paths frontmatter if scoped
```

Global rules location (user can copy there manually):
- **macOS/Linux**: `~/Documents/Cline/Rules/`
- **Windows**: `Documents\Cline\Rules`

Also auto-detected by Cline: `.cursorrules`, `.windsurfrules`, `AGENTS.md`

**Single file template:**

```markdown
# Project Rules

## Stack
{formatted tech_stack}

## Code Style
{code style conventions}

## Testing
{testing conventions}

## What Not to Do
{boundaries}
```

**Directory file template (with frontmatter):**

```markdown
---
paths:
  - "{glob_pattern}"
---

# {rule_name}

{rules}
```

**Key constraints:**
- Files loaded alphabetically — use numeric prefixes for ordering
- **No frontmatter** = always loads (default behavior)
- Frontmatter with `paths` = conditional (only loads when matching files are in context)
- `paths: []` = never loads (temporarily disable a rule)
- Workspace rules (`.clinerules/`) override global rules (`~/Documents/Cline/Rules/`)
- Also auto-detects `.cursorrules`, `.windsurfrules`, `AGENTS.md`

---

### 9. Roo Code Generator

**Files to create:**

```
.roo/
  rules/
    {name}.md                       # General rules
  rules-code/
    {name}.md                       # Code mode specific rules
```

**Legacy fallback (only if directory is too complex):**
```
.roorules                           # Single file (legacy)
```

**Rule file template:**

```markdown
# {rule_name}

{rules as numbered or bulleted list}
```

**Key constraints:**
- No YAML frontmatter — rules are plain Markdown
- Mode-specific rules go in `.roo/rules-{modeSlug}/`
- Supports AGENTS.md as cross-tool standard
- Files sorted alphabetically by basename
- Recursive reading, auto-excludes temp files

---

### 10. WorkBuddy Generator

**Files to create:**

```
.workbuddy/
  memory/
    MEMORY.md                       # Long-term stable memory
    YYYY-MM-DD.md                   # Today's daily log (if memory entries exist)
```

**MEMORY.md template:**

```markdown
# Project Conventions
{conventions by category}

# User Preferences
{preferences}

# Technical Decisions
{formatted decisions}

# Project Info
- Name: {project.name}
- Description: {project.description}
- Tech Stack: {formatted tech_stack}

# Commands
{formatted commands}

# Project Structure
{formatted structure}

# Boundaries
{formatted boundaries}
```

**Daily log template:**

```markdown
# {YYYY-MM-DD}

## Completed
- Migrated project context from {source_platform} to WorkBuddy format

## Key Decisions
- {decisions from today}

## Code Changes
- Created .workbuddy/memory/ directory structure
```

**Key constraints:**
- MEMORY.md must stay concise — avoid info bloat
- Daily logs auto-purged after 30 days (distilled into MEMORY.md)
- Each project has its own `.workbuddy/memory/` directory
- Append-only for daily logs (never overwrite)
- Project-specific memory files can be added (e.g., `project-a.md`)
- **Other WorkBuddy identity files** (user-level, NOT project-level):
  - `~/.workbuddy/SOUL.md` — agent personality and values
  - `~/.workbuddy/IDENTITY.md` — agent name and role
  - `~/.workbuddy/USER.md` — user profile

---

### 11. CodeBuddy Generator

**Files to create:**

```
CODEBUDDY.md                        # Main project instructions
.codebuddy/
  rules/
    {name}/                         # One folder per rule
      RULE.mdc                      # Rule file with frontmatter
CODEBUDDY.local.md                  # Personal/local preferences (add to .gitignore)
```

**RULE.mDC format (per-rule, folder-based):**

```markdown
---
description: "{rule_description}"
globs: "{glob_patterns}"
alwaysApply: false
enabled: true
---

# {rule_name}

{rules}
```

> ⚠️ CodeBuddy now uses `.codebuddy/rules/{name}/RULE.mdc` format (folder per rule), not flat `.md` files.

**CODEBUDDY.md template:**

```markdown
# {project.name}

{project.description}

## Tech Stack
{formatted tech_stack}

## Commands
{formatted commands}

## Project Structure
{formatted structure}

## Conventions
{formatted conventions by category}

## Boundaries
{formatted boundaries}

## Preferences
{formatted preferences}
```

**Key constraints:**
- `CODEBUDDY.md` takes priority over `AGENTS.md` (which is also supported as fallback)
- Supports `@path` imports (recursive up to 5 levels)
- `CODEBUDDY.local.md` for personal preferences (auto-added to .gitignore)
- Auto-memory stored at `~/.codebuddy/memories/{project-id}/MEMORY.md`
- Typed memory mode: user, feedback, project, reference
- **3 rule loading types** (controlled by frontmatter):
  - `alwaysApply: true` → **always**: full content loaded every session
  - `alwaysApply: false` + `description` → **agentic**: only name/desc loaded, AI expands when needed
  - `alwaysApply: false` + no description + no globs → **manual**: only when @-mentioned

---

### 12. Trae Generator

**Files to create:**

```
CLAUDE.md                           # Team-shared rules (optional, Claude Code compatible)
.trae/
  rules/
    project_rules.md                # Project-level rules (team-shared)
    user_rules.md                   # Project-level personal rules (optional)
  settings.json                     # Behavior configuration (optional)
  mcp.json                          # MCP servers (optional)
  tasks.json                        # Custom task automation (optional)
  skills/                           # Reusable skills (optional)
    {name}/
      SKILL.md
  agents/                           # Sub-agents (optional)
    {name}.md
```

**project_rules.md template:**

```markdown
# Project Rules

## Tech Stack
{formatted tech_stack}

## Commands
{formatted commands}

## Code Conventions
{formatted conventions}

## Architecture
{formatted structure}

## Boundaries
{formatted boundaries}
```

**Key constraints:**
- Two rule levels with priority: project_rules.md > user_rules.md (project-level) > user_rules.md (user-level `~/.trae/`) > defaults
- Also uses `CLAUDE.md` and `CLAUDE.local.md` for rules (Claude Code compatible)
- User rules can exist at BOTH project level (`.trae/rules/user_rules.md`) and user level (`~/.trae/rules/user_rules.md`)
- Memory system available via `trae-memory-mcp` MCP server
- Supports skills (`.trae/skills/`) and agents (`.trae/agents/`) similar to Claude Code

---

### 13. TONGYI Lingma Generator

**Files to create:**

```
.lingma/
  rules/
    {name}.md                       # One file per rule
```

**Rule file template:**

```markdown
{rules in natural language — no images or links}

Examples:
- 命名规范：变量使用驼峰命名法(camelCase)，类名使用帕斯卡命名法(PascalCase)
- 错误处理：始终使用 try-catch 包裹可能出错的代码
```

**Key constraints:**
- **10,000 characters max per rule file** (excess truncated)
- Natural language only — no image or link parsing
- 4 rule types (set via IDE UI, not frontmatter):
  - Manual: invoked via `#rule` / `@rule`
  - Model Decision: AI decides based on description
  - Always: applied to all requests
  - Specific Files: matched by glob patterns
- Since rule type is set via IDE UI, generated files should include a comment header noting the intended type
- Files shared via version control (add to .gitignore for personal rules)

**Type hint header:**

```markdown
<!-- Rule Type: Always | Description: {description} | Files: {glob_patterns} -->
{rules content}
```

---

### 14. Augment Code Generator

**Files to create:**

```
.augment/
  guidelines.md                     # Primary workspace guidelines
  rules/                            # Modular rules (if scope_rules exist)
    {name}.md
.augment-guidelines                 # Alternative workspace guidelines (still valid)
```

**guidelines.md template:**

```markdown
# Project Guidelines

## Code Style
{code style conventions}

## Architecture
{architecture conventions and structure}

## Testing
{testing conventions}

## Commands
{formatted commands}

## Dependencies
{dependency conventions}
```

**Rules file template:**

```markdown
---
type: {always_apply|agent_requested}
description: "{rule_description}"
---

# {rule_name}

{rules}
```

**Key constraints:**
- Also supports AGENTS.md and CLAUDE.md (loaded as fallbacks with higher priority)
- `.augment/rules/` only loaded from workspace root (not subdirectories)
- `~/.augment/rules/` for user-global (always `always_apply`, no frontmatter supported)
- `type: agent_requested` optimizes context usage — AI decides when to apply
- `type: manual` exists in IDE only (not CLI) — attached via @ mention
- Loading priority: AGENTS.md/CLAUDE.md > `.augment-guidelines` > `.augment/rules/` > `~/.augment/rules/`

---

### 15. Qoder/QCode Generator

**Files to create:**

```
AGENTS.md                           # Cross-tool standard (AGENTS.md format)
.qoder/
  rules/
    {name}                          # One file per rule (no extension needed)
```

**AGENTS.md** (see Generator #2 for Codex/AGENTS.md format) — Qoder fully supports AGENTS.md.

**Qoder rule file template** (`.qoder/rules/{name}`):

```markdown
{rules in natural language — no images or links}

Examples:
- 编码规范：变量使用驼峰命名法(camelCase)
- 错误处理：始终使用 try-catch 包裹
```

**Key constraints:**
- Qoder has its own `.qoder/rules/` directory
- Same 4 rule types as Lingma (set via IDE UI): Manual, Model Decision, Always, Specific Files
- **100,000 character total limit** across all active rules (content beyond truncated)
- AGENTS.md also fully supported; `.qoder/rules/` takes precedence on conflict
- No YAML frontmatter in rule files — type is set via IDE UI
- Rules shared via version control (add `.qoder/rules` to `.gitignore` for local-only)

---

## Migration Commands

When the user invokes this skill, follow this interaction flow:

### Command: `migrate`

**Usage:** "migrate to {platform}" or "convert from {platformA} to {platformB}"

1. **Detect** all existing AI memory files in the project
2. **Report** what was found (which platforms, which files)
3. **Parse** all found files into the canonical format
4. **Show** a summary of extracted context (project info, conventions count, scope rules count)
5. **Confirm** target platform with the user
6. **Generate** target platform files
7. **Report** created files and any warnings (e.g., character limits, unsupported features)

### Command: `detect`

**Usage:** "detect" or "scan" or "what AI tools are configured"

1. Scan project root for all known AI memory files
2. Report which platforms have configuration present
3. Show file sizes and line counts

### Command: `sync-all`

**Usage:** "sync all" or "generate for all platforms"

1. Detect existing source files
2. Parse to canonical format
3. Generate files for ALL 15 supported platforms
4. Place each in correct directory structure

### Command: `export-canonical`

**Usage:** "export canonical" or "show canonical format"

1. Parse all detected files into canonical format
2. Display the canonical representation (YAML)
3. Save to `.ai-mind-migrate/canonical.yaml` for manual review

---

## Implementation Steps

When the user triggers a migration, execute these steps in order:

### Step 1: Scan and Detect

```bash
# Check for all known AI memory files
find . -maxdepth 4 -type f \( \
  -name "CLAUDE.md" -o \
  -name "CLAUDE.local.md" -o \
  -name "AGENTS.md" -o \
  -name "AGENTS.override.md" -o \
  -name "GEMINI.md" -o \
  -name "CONVENTIONS.md" -o \
  -name "CODEBUDDY.md" -o \
  -name "CODEBUDDY.local.md" -o \
  -name ".cursorrules" -o \
  -name ".windsurfrules" -o \
  -name ".roorules" -o \
  -name ".clinerules" -o \
  -name ".augment-guidelines" -o \
  -path "./.claude/rules/*.md" -o \
  -path "./.cursor/rules/*.mdc" -o \
  -path "./.cursor/rules/*.md" -o \
  -path "./.windsurf/rules/*.md" -o \
  -path "./.github/copilot-instructions.md" -o \
  -path "./.github/instructions/*.instructions.md" -o \
  -path "./.clinerules/*.md" -o \
  -path "./.clinerules/*.txt" -o \
  -path "./.roo/rules/*.md" -o \
  -path "./.roo/rules/*.txt" -o \
  -path "./.roo/rules-*/*.md" -o \
  -path "./.roo/rules-*/*.txt" -o \
  -path "./.workbuddy/memory/*.md" -o \
  -path "./.codebuddy/rules/*.md" -o \
  -path "./.trae/rules/*.md" -o \
  -path "./.lingma/rules/*.md" -o \
  -path "./.augment/rules/*.md" \
\) 2>/dev/null
```

### Step 2: Read and Parse

Read each detected file using the Read tool. Parse using the platform-specific parser rules defined above.

**Priority order for parsing when multiple sources exist:**
1. AGENTS.md (universal standard, most likely to be comprehensive)
2. CLAUDE.md / CODEBUDDY.md (detailed, well-structured)
3. .cursor/rules/*.mdc / .windsurf/rules/*.md (structured with frontmatter)
4. Other platform files (supplementary)

### Step 3: Merge and Deduplicate

```python
# Pseudocode for deduplication
for each rule in all_conventions:
    normalized = normalize_whitespace(rule)
    if normalized not in seen_rules:
        canonical.conventions.append(rule)
        seen_rules.add(normalized)
```

### Step 4: Generate Target Files

Use the Write tool to create each target file. Follow the platform-specific template and constraints exactly.

**Important**: Before writing, check if target files already exist. If they do:
- Ask the user whether to **overwrite** or **merge**
- If merge: append new content, preserving existing content that doesn't conflict
- If overwrite: backup existing file first (rename to `{filename}.backup.{timestamp}`)

### Step 5: Post-Generation Validation

After generating files, validate:

1. **File exists** at the correct path
2. **Format is correct** (frontmatter syntax, file extension)
3. **Character limits** are respected (especially Windsurf: 6K per rule file, 12K total across all active rules; Lingma: 10K)
4. **No syntax errors** in YAML frontmatter
5. **.gitignore updated** if needed (for .local files, memory directories)

### Step 6: Generate Report

Create a migration report at `.ai-mind-migrate/migration-report.md`:

```markdown
# AI Mind Migrate Report

**Date**: {timestamp}
**Source Platform(s)**: {detected_sources}
**Target Platform(s)**: {targets}

## Files Created
- {list of created files with paths}

## Files Backed Up
- {list of backed up files}

## Warnings
- {any warnings about truncated content, unsupported features}

## Content Summary
- Project: {name}
- Conventions extracted: {count}
- Scope rules extracted: {count}
- Commands extracted: {count}
- Decisions extracted: {count}

## Platform-Specific Notes
- {any notes about how content was adapted for each platform}
```

---

## Platform Compatibility Matrix

Features that map between platforms:

| Feature | Claude Code | Codex | Copilot | Cursor | Windsurf | Gemini | Aider | Cline | Roo | WorkBuddy | CodeBuddy | Trae | Lingma | Augment |
|---------|------------|-------|---------|--------|----------|--------|-------|-------|-----|-----------|-----------|------|--------|---------|
| **Main file** | CLAUDE.md | AGENTS.md | copilot-instructions.md | AGENTS.md / .mdc | .windsurfrules | GEMINI.md | CONVENTIONS.md | .clinerules | .roorules | MEMORY.md | CODEBUDDY.md | project_rules.md | rules/*.md | guidelines.md |
| **Rules directory** | .claude/rules/ | — | .github/instructions/ | .cursor/rules/ | .windsurf/rules/ | — | — | .clinerules/ | .roo/rules/ | — | .codebuddy/rules/ | .trae/rules/ | .lingma/rules/ | .augment/rules/ |
| **Scoped rules** | paths frontmatter | — | applyTo frontmatter | globs frontmatter | globs frontmatter | — | — | paths frontmatter | — | — | paths frontmatter | — | glob UI | — |
| **Always rules** | default | default | default | alwaysApply:true | trigger:always_on | default | default | no FM(default) | default | default | alwaysApply:true | default | Always type | type:always_apply |
| **Agent-decided** | — | — | — | Apply Intelligently | model_decision | — | — | — | — | — | — | — | Model Decision | type:agent_requested |
| **Manual rules** | — | — | — | Manual | manual | — | — | paths:[] | — | — | — | Manual | Manual | manual(IDE) |
| **File imports** | @path | — | — | — | — | @file.md | — | — | — | — | @path | — | — | — |
| **Local/personal** | .local.md | override.md | — | — | — | — | — | — | — | — | .local.md | user_rules.md | .gitignore | — |
| **Auto-memory** | MEMORY.md | — | — | — | — | — | — | — | — | daily logs | MEMORY.md | Memory | — | — |
| **Char limit** | ~200 lines | 32KB total | — | — | 6K/file, 12K total | — | — | — | — | concise | 200 lines | — | 10K/file | — |
| **Format** | MD | MD | MD | MDC/MD | MD | MD | MD | MD | MD | MD | MD | MD | NL | MD |
| **Auto-detects** | — | — | AGENTS/MD | AGENTS.md | AGENTS.md | — | — | .cursorrules | AGENTS.md | — | AGENTS.md | — | — | AGENTS/CLAUDE.md |

---

## Special Handling Notes

### Converting Scoped Rules Between Platforms

When a source platform has scoped rules (e.g., Claude Code's `paths` frontmatter) and the target platform doesn't support scoping (e.g., AGENTS.md):

- **Merge** all scoped rules into the main file, grouped under headings
- **Add comments** noting which files each section applies to
- **Preserve** the scope information in a comment block for future re-conversion

Example:
```markdown
## API Development Rules
<!-- Originally scoped to: src/api/**/*.ts, src/services/**/*.ts -->
- All API endpoints must include input validation
- Use standard error response format
```

### Converting Import Syntax

| Source | Target | Conversion |
|--------|--------|------------|
| CLAUDE.md `@path` | GEMINI.md | Keep `@path` syntax (compatible) |
| CLAUDE.md `@path` | Cursor | Inline the imported content (Cursor has no imports) |
| GEMINI.md `@file.md` | CLAUDE.md | Change to `@path` syntax |
| CodeBuddy `@path` | Others | Inline the imported content |

### Converting Rule Activation Types

| Source Type | → Always | → Scoped | → Agent-Decided | → Manual |
|-------------|----------|----------|-----------------|----------|
| Always | Direct | Add glob paths | Change type | Change type |
| Scoped | Remove paths, set alwaysApply | Direct | Keep paths, change type | Keep paths, change type |
| Agent-Decided | Set alwaysApply, add description | Set alwaysApply:false, add paths | Direct | Remove description, add comment |
| Manual | Set alwaysApply | Set alwaysApply:false, add paths | Add description | Direct |

### Handling Character Limits

When target platform has character limits (Windsurf: 6K per rule file, 12K total across all active rules; Lingma: 10K/file):

1. **Calculate** character count of generated content
2. **If exceeds per-file limit**: split into multiple files
3. **If exceeds total limit**: prioritize always-applied rules, then scoped rules by importance
4. **Add a warning** in the migration report noting what was truncated

### Handling WorkBuddy Daily Logs

When migrating TO WorkBuddy:
- Create today's daily log with a migration entry
- Long-term conventions go into MEMORY.md
- Decisions with dates go into MEMORY.md

When migrating FROM WorkBuddy:
- Parse MEMORY.md for conventions and decisions
- Parse recent daily logs (last 2 days) for current context
- Older logs are likely already distilled — only parse if user requests

---

## Error Handling

1. **No source files found**: Inform user, suggest creating a canonical format manually or using project analysis
2. **Unreadable file**: Skip with warning, continue with other files
3. **YAML frontmatter parse error**: Treat file as plain Markdown, note in report
4. **Target file already exists**: Ask user (overwrite/merge/cancel)
5. **Character limit exceeded**: Split or truncate with warning
6. **Circular imports**: Detect and break, note in report
7. **Encoding issues**: Try UTF-8, then Latin-1, note in report

---

## Best Practices

1. **Always backup** existing target files before overwriting
2. **Preserve scope information** even when target platform doesn't support it (use comments)
3. **Test migration** by reading back the generated files and verifying content
4. **Keep a canonical snapshot** in `.ai-mind-migrate/canonical.yaml` for future migrations
5. **Update .gitignore** appropriately for local/personal files
6. **Generate platform-compatible content** — don't include source-specific syntax in target files
7. **Respect each platform's conventions** — e.g., AGENTS.md should have Commands section first
8. **Include a migration comment** in generated files noting the source platform and date
