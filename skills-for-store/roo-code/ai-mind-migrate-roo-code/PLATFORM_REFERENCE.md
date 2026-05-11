# AI Mind Migrate — Platform Format Reference Card

> Quick reference for all 15 supported AI coding assistant memory formats.

## File Location Cheat Sheet

```
Project Root/
├── CLAUDE.md                          # Claude Code (main)
├── CLAUDE.local.md                    # Claude Code (local/personal)
├── AGENTS.md                          # Codex / Multi-tool standard / Cursor / QCode / Windsurf / Cline
├── AGENTS.override.md                 # Codex (override)
├── GEMINI.md                          # Gemini CLI
├── CONVENTIONS.md                     # Aider (⚠️ must use --read)
├── CODEBUDDY.md                       # CodeBuddy (main)
├── CODEBUDDY.local.md                 # CodeBuddy (local/personal)
├── .cursorrules                       # (auto-detected by Cline, not Cursor!)
├── .windsurfrules                     # Windsurf (legacy, deprecated)
├── .roorules                          # Roo Code (legacy)
├── .clinerules                        # Cline (single file)
├── .augment-guidelines                # Augment Code
├── .claude/
│   ├── CLAUDE.md                      # Claude Code (alt location)
│   └── rules/
│       ├── code-style.md              # Claude Code (scoped rules)
│       └── testing.md
├── .cursor/
│   └── rules/
│       ├── general.mdc                # Cursor (modern rules)
│       └── api.mdc
├── .windsurf/
│   └── rules/
│       ├── coding-standards.md        # Windsurf (modern rules)
│       └── react.md
├── .github/
│   ├── copilot-instructions.md        # GitHub Copilot
│   └── instructions/
│       └── react.instructions.md      # GitHub Copilot (scoped)
├── .clinerules/
│   ├── 01-stack.md                    # Cline (directory mode)
│   └── 02-patterns.md
├── .roo/
│   ├── rules/
│   │   └── general.md                 # Roo Code (general rules)
│   └── rules-code/
│       └── typescript.md              # Roo Code (mode-specific)
├── .workbuddy/
│   └── memory/
│       ├── MEMORY.md                  # WorkBuddy (long-term)
│       └── 2026-04-29.md             # WorkBuddy (daily log)
├── .codebuddy/
│   ├── CODEBUDDY.md                   # CodeBuddy (alt location)
│   └── rules/
│       ├── code-style.md              # CodeBuddy (scoped rules)
│       └── security.md
├── .trae/
│   └── rules/
│       └── project_rules.md           # Trae (project rules)
├── .lingma/
│   └── rules/
│       ├── coding-standards.md        # TONGYI Lingma
│       └── react-rules.md
├── .augment/
│   ├── guidelines.md                  # Augment Code (guidelines)
│   └── rules/
│       ├── typescript.md              # Augment Code (rules)
│       └── react.md
└── .ai-mind-migrate/
    ├── canonical.json                 # Migration tool (canonical)
    └── migration-report.md            # Migration tool (report)
```

## Frontmatter Quick Reference

### Claude Code (`.claude/rules/*.md`)
```yaml
---
paths:
  - "src/api/**/*.ts"
  - "src/services/**/*.ts"
---
```

### Cursor (`.cursor/rules/*.mdc`)
```yaml
---
description: "API development rules"
globs: src/api/**/*.ts, src/services/**/*.ts   # comma-separated
alwaysApply: false
---
```

### Windsurf (`.windsurf/rules/*.md`)
```yaml
---
trigger: glob          # always_on | glob | manual | model_decision
description: "API rules"
globs:
  - "src/api/**/*.ts"  # can be single glob or list
---
```

### GitHub Copilot (`.github/instructions/*.instructions.md`)
```yaml
---
applyTo: "src/api/**/*.ts"
---
```

### Cline (`.clinerules/*.md`)
> ⚠️ Cline official docs support ONLY `paths` frontmatter. No `description`, no `alwaysApply`.

```yaml
---
paths:
  - "src/api/**/*.ts"
---
```
- **No frontmatter** → always active (default)
- **`paths: [...]`** → conditional (loads when matching files in context)
- **`paths: []`** → never loads (temporarily disabled)
- **Empty `paths: []`** → never activates (temporarily disabled)

### CodeBuddy (`.codebuddy/rules/{name}/RULE.mdc`)
> CodeBuddy uses folder-per-rule format with `RULE.mdc` files

```yaml
---
description: "API routing patterns"
globs: src/api/**/*.ts
alwaysApply: false
enabled: true
---
```

### Augment (`.augment/rules/*.md`)
```yaml
---
type: agent_requested    # always_apply | agent_requested
description: "React component patterns"
---
```

### TONGYI Lingma (`.lingma/rules/*.md`)
```markdown
<!-- Rule Type: Always | Description: API rules | Files: src/api/**/*.ts -->
No YAML frontmatter — type set via IDE UI
```

### Qoder (`.qoder/rules/`)
Same 4 rule types as Lingma, set via IDE UI. No frontmatter. 100K char total limit.
- `AGENTS.md` also compatible; `.qoder/rules/` takes precedence on conflict.

## Activation Mode Mapping

| Mode | Claude | Cursor | Windsurf | Copilot | Cline | CodeBuddy | Augment | Lingma |
|------|--------|--------|----------|---------|-------|-----------|---------|--------|
| **Always** | default | alwaysApply:true | trigger:always_on | default | no FM(paths only) | alwaysApply:true | type:always_apply | Always(IDE) |
| **Scoped-Auto** | paths: | globs: | trigger:glob + globs: | applyTo: | paths: | paths: | — | Specific Files(IDE) |
| **Agent-decided** | — | alwaysApply:false + description only | model_decision | — | — | — | type:agent_requested | Model Decision(IDE) |
| **Manual** | — | alwaysApply:false + no desc, no globs | manual | — | paths:[] | alwaysApply:false + paths | manual(IDE only) | Manual(IDE) |

## Character Limits

| Platform | Per-File Limit | Notes |
|----------|---------------|-------|
| Claude Code | ~200 lines recommended | None |
| Codex (AGENTS.md) | None | 32KB total combined (configurable) |
| Windsurf | 6,000 chars per rule file | 12,000 chars total across all active rules |
| TONGYI Lingma | 10,000 chars | Excess truncated |
| Qoder | None (per file) | 100,000 chars total across active rules |
| Others | No specific limit | Context window dependent |
