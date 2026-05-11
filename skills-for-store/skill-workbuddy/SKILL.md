---
name: ai-mind-migrate-workbuddy
slug: ai-mind-migrate-workbuddy
description: "跨平台 AI 上下文迁移工具，专为 WorkBuddy 用户设计。一键将 Claude Code、Cursor、Codex、Copilot 等 14 个平台的记忆/规则迁移到 WorkBuddy 格式（.workbuddy/memory/MEMORY.md + daily logs），也能将 WorkBuddy 记忆反向导出到任意目标平台。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🦞"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for WorkBuddy

> 专为 WorkBuddy 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、Codex、Copilot 等 14 个平台的记忆/规则迁移到 WorkBuddy 格式，
> 也能将 WorkBuddy 的 `.workbuddy/memory/` 内容反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 WorkBuddy**: 从 Cursor/Claude Code/Codex 等平台迁入 WorkBuddy
- **从 WorkBuddy 迁出**: 将 `.workbuddy/memory/MEMORY.md` 导出到其他 14 个平台
- **同步 WorkBuddy 记忆**: 与其他 AI 助手保持项目规则一致
- **初始化 WorkBuddy**: 基于已有的 CLAUDE.md / AGENTS.md / `.cursor/rules` 生成 `.workbuddy/memory/` 结构
- **跨设备 WorkBuddy 同步**: 将一台机器上的 WorkBuddy 记忆迁移到另一台机器

关键词：workbuddy, memory migration, .workbuddy, MEMORY.md, 记忆迁移, 工作记忆,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
codebuddy, windsurf, cline, roo, aider, gemini, trae, lingma, augment, qoder

---

## 支持的平台（15 个）

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
| 10 | **WorkBuddy** | **`.workbuddy/memory/MEMORY.md`** (主目标) | `~/.workbuddy/memory/` (daily logs) | `~/.workbuddy/` (global: SOUL.md, IDENTITY.md, USER.md) | Project memory in `.workbuddy/memory/`. Daily logs: `YYYY-MM-DD.md`. User-level identity files at `~/.workbuddy/`. |
| 11 | **CodeBuddy** | `CODEBUDDY.md`, `.codebuddy/CODEBUDDY.md` | `.codebuddy/rules/{name}/RULE.mdc` | `~/.codebuddy/CODEBUDDY.md` | Also `CODEBUDDY.local.md`. `@path` imports, auto-memory at `~/.codebuddy/memories/`. 3 loading types: always/agentic/manual |
| 12 | **Trae** | `CLAUDE.md` (for rules), `.trae/rules/project_rules.md` | `.trae/rules/*.md` + `.trae/skills/` + `.trae/agents/` | `.trae/rules/user_rules.md` + `~/.trae/rules/user_rules.md` | Also has `settings.json`, `mcp.json`, `tasks.json`. Priority: user input > project_rules.md > project user_rules.md > global user_rules.md > defaults |
| 13 | **TONGYI Lingma** | — | `.lingma/rules/*.md` | — | 4 types via IDE UI (Manual, Model Decision, Always, Specific Files). 10K char limit |
| 14 | **Augment Code** | `.augment/guidelines.md` | `.augment/rules/*.md` | `~/.augment/rules/` | Also reads `AGENTS.md`, `CLAUDE.md`. `.augment-guidelines` is still valid as another option. |
| 15 | **Qoder/QCode** | `AGENTS.md` | `.qoder/rules/*.md` (Qoder rules) | — | Qoder uses same 4 rule types as Lingma. 100K char limit total across active rules. AGENTS.md also supported; `.qoder/rules/` takes precedence on conflict. |

---

## 架构：Canonical → 平台格式

迁移使用 **Canonical 中间格式** 作为唯一真相源。

```
┌─────────────────┐      Parse       ┌──────────────────┐     Generate     ┌──────────────────┐
│  Source Platform │  ──────────────> │  Canonical Format │  ──────────────> │  Target Platform  │
│  (e.g., CLAUDE.md)│                 │  (Internal Model) │                  │  (e.g., .workbuddy/)│
└─────────────────┘                   └──────────────────┘                   └──────────────────┘
```

### Canonical Format Schema

```yaml
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

## 分步迁移工作流

### Phase 1: Detect Source

扫描项目根目录中所有已知的 AI 助手记忆文件：

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

对每个检测到的源文件，使用平台特定的 Parser 解析为 Canonical 格式。

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
  - `trigger: model_decision` → scope_rules with description
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
- Also check `CLAUDE.md` if present (Trae can read both)

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

**Qoder Parser:**
- `AGENTS.md`: plain Markdown → conventions and commands
- `.qoder/rules/*`: natural language → conventions

### Phase 3: Merge Canonical Sources

If multiple platforms are detected, **merge** them:

1. **Deduplicate** rules that appear in multiple sources
2. **Prioritize** platform-specific rules over generic ones
3. **Preserve** scope/path information from each source
4. **Mark** conflicts for user review

### Phase 4: Generate Target Format

For each target platform, generate the correct file structure and format.

---

## 平台生成器

### 1–9, 11–15. 其他平台生成器

其他平台的生成器见通用 SKILL.md 对应章节，此处省略详细内容（功能与通用版一致）。

---

### 10. WorkBuddy Generator（主目标 — 最详细）

**要创建的文件：**

```
.workbuddy/
  memory/
    MEMORY.md                       # 长期稳定记忆
    YYYY-MM-DD.md                   # 今日日志（如果有 memory 条目）
```

**MEMORY.md 模板：**

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

**Daily log 模板：**

```markdown
# {YYYY-MM-DD}

## Completed
- Migrated project context from {source_platform} to WorkBuddy format

## Key Decisions
- {decisions from today}

## Code Changes
- Created .workbuddy/memory/ directory structure
```

**关键约束：**
- MEMORY.md 必须保持简洁 — 避免信息膨胀
- 每日日志 30 天后自动清理（蒸馏到 MEMORY.md 中）
- 每个项目有自己的 `.workbuddy/memory/` 目录
- 每日日志 append-only（从不覆写）
- 可以添加项目特定的记忆文件（如 `project-a.md`）
- **WorkBuddy 用户级身份文件**（非项目级）：
  - `~/.workbuddy/SOUL.md` — 代理个性和价值观
  - `~/.workbuddy/IDENTITY.md` — 代理名称和角色
  - `~/.workbuddy/USER.md` — 用户资料
- **从 WorkBuddy 迁出时**：
  - 解析 MEMORY.md 获取 conventions 和 decisions
  - 解析最近 2 天的 daily logs 获取当前上下文
  - 更早的日志通常已被蒸馏 — 仅在用户要求时解析

---

## 迁移命令

### `migrate to workbuddy`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 确认后生成 WorkBuddy 格式文件（`.workbuddy/memory/MEMORY.md` + daily log）
6. 报告创建的文件和警告

### `migrate from workbuddy` / `migrate to {platform}`

1. 读取 `.workbuddy/memory/MEMORY.md` 中的内容
2. 解析到 Canonical 格式
3. 生成目标平台的对应文件

### `detect` / `sync-all` / `export-canonical`

功能同通用 SKILL.md。

---

## 平台兼容性矩阵

| Feature | Claude Code | Codex | Copilot | Cursor | Windsurf | Gemini | Aider | Cline | Roo | WorkBuddy | CodeBuddy | Trae | Lingma | Augment | Qoder |
|---------|------------|-------|---------|--------|----------|--------|-------|-------|-----|-----------|-----------|------|--------|---------|-------|
| **Main file** | CLAUDE.md | AGENTS.md | copilot-instructions.md | AGENTS.md / .mdc | .windsurfrules | GEMINI.md | CONVENTIONS.md | .clinerules | .roorules | MEMORY.md | CODEBUDDY.md | project_rules.md | rules/*.md | guidelines.md | AGENTS.md |
| **Rules directory** | .claude/rules/ | — | .github/instructions/ | .cursor/rules/ | .windsurf/rules/ | — | — | .clinerules/ | .roo/rules/ | — | .codebuddy/rules/ | .trae/rules/ | .lingma/rules/ | .augment/rules/ | .qoder/rules/ |
| **Scoped rules** | paths FM | — | applyTo FM | globs FM | globs FM | — | — | paths FM | — | — | paths FM | — | glob UI | — | — |
| **Always rules** | default | default | default | alwaysApply:true | trigger:always_on | default | default | no FM | default | default | alwaysApply:true | default | Always type | type:always_apply | IDE |
| **Agent-decided** | — | — | — | Apply Intelligently | model_decision | — | — | — | — | — | — | — | Model Decision | type:agent_requested | IDE |
| **Manual rules** | — | — | — | Manual | manual | — | — | paths:[] | — | — | — | Manual | Manual | manual(IDE) | IDE |
| **File imports** | @path | — | — | — | — | @file.md | — | — | — | — | @path | — | — | — | — |
| **Local/personal** | .local.md | override.md | — | — | — | — | — | — | — | — | .local.md | user_rules.md | .gitignore | — | — |
| **Auto-memory** | MEMORY.md | — | — | — | — | — | — | — | — | daily logs | MEMORY.md | Memory | — | — | — |
| **Char limit** | ~200 lines | 32KB total | — | — | 6K/file, 12K total | — | — | — | — | concise | 200 lines | — | 10K/file | — | 100K total |
| **Format** | MD | MD | MD | MDC/MD | MD | MD | MD | MD | MD | MD | MD | MD | NL | MD | NL |
| **Auto-detects** | — | — | AGENTS/MD | AGENTS.md | AGENTS.md | — | — | .cursorrules | AGENTS.md | — | AGENTS.md | — | — | AGENTS/CLAUDE.md | AGENTS.md |

---

## 特殊处理

### 从其他平台迁移到 WorkBuddy

| 源平台 | 映射方式 |
|--------|----------|
| CLAUDE.md | `##` heading categories → MEMORY.md `#` sections |
| AGENTS.md | `## Conventions` → MEMORY.md conventions |
| .cursor/rules/*.mdc | `alwaysApply` rules → MEMORY.md conventions, scoped rules → noted in comments |
| WorkBuddy daily logs | `YYYY-MM-DD.md` → memory entries with dates preserved |
| CodeBuddy CODEBUDDY.md | Same as CLAUDE.md mapping |

### 从 WorkBuddy 迁移到其他平台

- 项目信息 → 目标平台的文件头
- Conventions → 按类别分组到目标平台的对应章节
- Decisions → 嵌入到 conventions 或单独章节
- Daily logs → 最近 2 天的上下文保留，更早的蒸馏到 conventions
- Memory entries → 如果目标平台支持（CodeBuddy MEMORY.md），保留类型和日期

### 处理 Auto-Memory 格式

当目标平台支持 auto-memory（CodeBuddy、WorkBuddy 等）：
- `memory` 条目写入对应位置
- 类型（user/feedback/project/reference）映射到目标平台的格式
- 日期 IS0 8601 保留

---

## 错误处理

1. **没有找到源文件**: 告知用户，建议手动创建 Canonical 格式或使用项目分析
2. **文件不可读**: 跳过并警告，继续处理其他文件
3. **YAML frontmatter 解析失败**: 当作纯文本处理，在报告中注明
4. **目标文件已存在**: 询问用户（覆盖/合并/取消）
5. **字符限制超限**: 拆分或截断并警告
6. **循环引用**: 检测并中断，在报告中注明
7. **编码问题**: 尝试 UTF-8 然后 Latin-1，在报告中注明

---

## 最佳实践

1. **始终备份** 目标文件再覆盖
2. **保留作用域信息** 即使目标平台不支持（使用注释）
3. **测试迁移** 读取生成的文件并验证内容
4. **保留 Canonical 快照** 到 `.ai-mind-migrate/canonical.yaml`
5. **更新 .gitignore** 针对本地/个人文件
6. **生成平台兼容内容** — 不要在目标文件中包含源平台的特定语法
7. **尊重每个平台的约定** — 例如 AGENTS.md 应把 Commands section 放在前面
8. **在生成的文件中包含迁移注释**，注明源平台和日期
