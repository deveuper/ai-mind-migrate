---
name: ai-mind-migrate-codebuddy
slug: ai-mind-migrate-codebuddy
description: "跨平台 AI 上下文迁移工具，专为 CodeBuddy 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 CodeBuddy 格式（CODEBUDDY.md + .codebuddy/rules/），也能将 CodeBuddy 规则反向导出到任意目标平台。"
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

# AI Mind Migrate for CodeBuddy

> 专为 CodeBuddy 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy、Copilot 等 14 个平台的记忆/规则迁移到 CodeBuddy 格式，
> 也能将 CodeBuddy 的 CODEBUDDY.md / `.codebuddy/rules/` 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 CodeBuddy**: 从 Cursor/Claude Code/WorkBuddy 等平台迁入 CodeBuddy
- **从 CodeBuddy 迁出**: 将 CODEBUDDY.md / `.codebuddy/rules/` 导出到其他 14 个平台
- **同步 CodeBuddy 配置**: 与其他 AI 助手保持项目规则一致
- **初始化 CodeBuddy**: 基于已有的 AGENTS.md / CLAUDE.md 生成 CODEBUDDY.md
- **跨项目迁移**: 在不同项目间拷贝 CODEBUDDY.md 时调整规则

关键词：codebuddy, CODEBUDDY.md, codebuddy rules, .codebuddy, codebuddy migration,
import to codebuddy, export from codebuddy,
migrate, transfer, port, convert, export, sync, cursor, claude code, codex, copilot,
workbuddy, windsurf, cline, roo, aider, gemini, trae, lingma, augment, qoder

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
| 10 | **WorkBuddy** | `.workbuddy/memory/MEMORY.md` | `~/.workbuddy/memory/` (daily logs) | `~/.workbuddy/` (global: SOUL.md, IDENTITY.md, USER.md) | Project memory in `.workbuddy/memory/`. Daily logs: `YYYY-MM-DD.md`. User-level identity files at `~/.workbuddy/`. |
| 11 | **CodeBuddy** | **`CODEBUDDY.md`**, **`.codebuddy/CODEBUDDY.md`** (主目标) | **`.codebuddy/rules/{name}/RULE.mdc`** | `~/.codebuddy/CODEBUDDY.md` | Also `CODEBUDDY.local.md`. `@path` imports, auto-memory at `~/.codebuddy/memories/`. 3 loading types: always/agentic/manual |
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
│  (e.g., CLAUDE.md)│                 │  (Internal Model) │                  │  (e.g., CODEBUDDY.md)│
└─────────────────┘                   └──────────────────┘                   └──────────────────┘
```

### Canonical Format Schema

同通用 SKILL.md 的 Canonical Format Schema（见 skill-workbuddy/SKILL.md）。

---

## 分步迁移工作流

### Phase 1: Detect Source

扫描项目根目录中所有已知的 AI 助手记忆文件（完整检测列表同通用 SKILL.md）。

### Phase 2: Parse to Canonical

对每个检测到的源文件，使用平台特定的 Parser 解析为 Canonical 格式。

**完整解析规则（15 个平台）：**

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
- `.cursor/rules/*.md` (no frontmatter): plain Markdown → conventions

**Windsurf Parser:**
- `.windsurfrules`: plain text → conventions
- `.windsurf/rules/*.md`: parse YAML frontmatter with `trigger` field

**Copilot Parser:**
- `.github/copilot-instructions.md`: plain Markdown → conventions
- `.github/instructions/*.instructions.md`: parse `applyTo` frontmatter → scope_rules

**GEMINI.md Parser:** (same as CLAUDE.md for GEMINI.md)
- Parse `@file.md` imports

**Aider Parser:**
- `CONVENTIONS.md`: plain Markdown → conventions

**Cline Parser:**
- `.clinerules`: plain text → conventions
- `.clinerules/*.md`: parse YAML frontmatter, only `paths` supported

**Roo Code Parser:**
- `.roorules`: plain text → conventions
- `.roo/rules/*.md`: plain Markdown grouped by directory/mode

**WorkBuddy Parser:**
- `.workbuddy/memory/MEMORY.md`: long-term conventions and decisions
- `.workbuddy/memory/YYYY-MM-DD.md`: recent daily logs → memory entries with dates

**CodeBuddy Parser:**
- `CODEBUDDY.md` / `.codebuddy/CODEBUDDY.md`: same as CLAUDE.md
- `.codebuddy/rules/{name}/RULE.mdc`: parse YAML frontmatter
  - `alwaysApply` + `paths` → scope_rules
  - `enabled: false` → skip
- `@path` imports resolved
- Auto-memory typed format: extract `type` frontmatter

**Trae Parser:**
- `.trae/rules/project_rules.md`: plain Markdown → conventions

**TONGYI Lingma Parser:**
- `.lingma/rules/*.md`: natural language → conventions
- 10,000 char limit per file

**Augment Parser:**
- `.augment-guidelines`: plain Markdown → conventions
- `.augment/rules/*.md`: parse `type` frontmatter (always_apply / agent_requested)

**Qoder Parser:**
- `AGENTS.md`: plain Markdown → conventions and commands
- `.qoder/rules/*`: natural language → conventions

### Phase 3: Merge Canonical Sources

同通用 SKILL.md。

### Phase 4: Generate Target Format

---

## 平台生成器

### 1–10, 12–15. 其他平台生成器

其他平台生成器见通用 SKILL.md 对应章节，此处省略详细内容（功能与通用版一致）。

---

### 11. CodeBuddy Generator（主目标 — 最详细）

**要创建的文件：**

```
CODEBUDDY.md                        # 主项目指令
.codebuddy/
  rules/
    {name}/                         # 每规则一个文件夹
      RULE.mdc                      # 规则文件（带 frontmatter）
CODEBUDDY.local.md                  # 个人偏好（添加到 .gitignore）
```

**CODEBUDDY.md 模板：**

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

**RULE.mdc 格式（每规则独立文件夹）：**

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

> ⚠️ CodeBuddy 使用 `.codebuddy/rules/{name}/RULE.mdc` 格式（每规则独立文件夹），而非扁平 `.md` 文件。

**关键约束：**
- `CODEBUDDY.md` 优先级高于 `AGENTS.md`（后者也作为后备支持）
- 支持 `@path` 导入（递归最多 5 层）
- `CODEBUDDY.local.md` 用于个人偏好（自动添加到 .gitignore）
- 自动记忆存储在 `~/.codebuddy/memories/{project-id}/MEMORY.md`
- 分类记忆模式：user, feedback, project, reference
- **3 种规则加载类型**（由 frontmatter 控制）：
  - `alwaysApply: true` → **always**：每次会话加载完整内容
  - `alwaysApply: false` + `description` → **agentic**：仅加载名称/描述，AI 需要时展开
  - `alwaysApply: false` + 无 description + 无 globs → **manual**：仅当 @-mention 时加载
- `CODEBUDDY.md` 建议 ≤ 200 行

---

## 迁移命令

### `migrate to codebuddy`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 确认后生成 CodeBuddy 格式文件
6. 报告创建的文件和警告

### `migrate from codebuddy` / `migrate to {platform}`

1. 读取 CODEBUDDY.md 和 `.codebuddy/rules/` 中的内容
2. 解析到 Canonical 格式
3. 生成目标平台的对应文件

### `detect` / `sync-all` / `export-canonical`

功能同通用 SKILL.md。

---

## 平台兼容性矩阵

同通用 SKILL.md 的兼容性矩阵表。

---

## 特殊处理

### 从其他平台迁移到 CodeBuddy

| 源平台 | 映射方式 |
|--------|----------|
| AGENTS.md | `## Commands` → commands, `## Conventions` → conventions |
| CLAUDE.md | `##` headings → CODEBUDDY.md sections, `.claude/rules/*.md` → `.codebuddy/rules/*/RULE.mdc` |
| .cursor/rules/*.mdc | `mdc` frontmatter → `RULE.mdc` frontmatter (`alwaysApply` preserved), `globs` → `globs` |
| WorkBuddy MEMORY.md | Sections → CODEBUDDY.md conventions, memory entries preserved |
| Cline .clinerules/ | `paths` frontmatter → codebuddy `globs` frontmatter |
| Windsurf .windsurf/rules/*.md | `trigger` field → `alwaysApply` mapping, `globs` preserved |
| Augment .augment/rules/*.md | `type: always_apply` → `alwaysApply: true`, `type: agent_requested` → `alwaysApply: false` + `description` |

### 从 CodeBuddy 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Claude Code | RULE.mdc → `.claude/rules/*.md`（`paths` frontmatter form, stripped `enabled` field） |
| Cursor | RULE.mdc `globs` → `.cursor/rules/*.mdc` `globs` |
| Windsurf | RULE.mdc `alwaysApply` → `trigger: always_on` / `trigger: glob` |
| Cline | RULE.mdc `globs` → `.clinerules/*.md` `paths` frontmatter |
| Augment | RULE.mdc `alwaysApply` → `type: always_apply` / `type: agent_requested` |

### 处理 @path 导入

当源平台有 `@path` 导入（Claude Code、CodeBuddy）：
- 将导入内容内联到目标文件（如果目标平台不支持导入语法）
- 在内联处添加注释标记源路径
- 如果目标平台也有导入语法（如 Gemini CLI 的 `@file.md`），保留导入并转换语法

---

## 错误处理

1. **没有找到源文件**: 告知用户，建议手动创建 Canonical 格式或使用项目分析
2. **文件不可读**: 跳过并警告，继续处理其他文件
3. **YAML frontmatter 解析失败**: 当作纯文本处理，在报告中注明
4. **目标文件已存在**: 询问用户（覆盖/合并/取消）
5. **字符限制超限**: 拆分或截断并警告
6. **循环引用 (@path)**: 检测并中断，在报告中注明
7. **编码问题**: 尝试 UTF-8 然后 Latin-1，在报告中注明

---

## 最佳实践

1. **始终备份** 目标文件再覆盖
2. **保留作用域信息** 即使目标平台不支持（使用注释）
3. **测试迁移** 读取生成的文件并验证内容
4. **保留 Canonical 快照** 到 `.ai-mind-migrate/canonical.yaml`
5. **更新 .gitignore** 针对本地/个人文件
6. **生成平台兼容内容** — 不要在目标文件中包含源平台的特定语法
7. **尊重每个平台的约定** — `CODEBUDDY.md` 应保持 ≤ 200 行
8. **在生成的文件中包含迁移注释**，注明源平台和日期
