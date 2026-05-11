---
name: ai-mind-migrate-claude-code
slug: ai-mind-migrate-claude-code
description: "跨平台 AI 上下文迁移工具，专为 Claude Code 用户设计。一键将 Cursor、Codex、WorkBuddy 等 15 个平台的记忆/规则迁移到 Claude Code 格式（CLAUDE.md + .claude/rules/），也能反向导出。当用户提到跨工具迁移、同步规则、初始化 CLAUDE.md 时使用此 Skill。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
disable-model-invocation: true
when_to_use: "当用户需要从 Cursor、Codex、WorkBuddy、Copilot 等平台迁移到 Claude Code，或从 Claude Code 导出到其他平台时使用。关键词：claude code migration, import to claude, export from claude, sync rules, convert CLAUDE.md"
allowed-tools: Read Write Bash WebFetch WebSearch
metadata:
  openclaw:
    emoji: "🤖"
    os: [linux, darwin, win32]
---

# AI Mind Migrate for Claude Code

> 将 Cursor、Codex、WorkBuddy 等平台的记忆/规则迁移到 Claude Code 格式，或反向导出。

---

## 支持的 15 个平台

| # | Platform | 主文件 | 规则目录 |
|---|----------|--------|---------|
| 1 | **Claude Code** (主目标) | CLAUDE.md, .claude/CLAUDE.md | .claude/rules/*.md |
| 2 | **OpenAI Codex** | AGENTS.md | — |
| 3 | **GitHub Copilot** | .github/copilot-instructions.md | .github/instructions/ |
| 4 | **Cursor** | AGENTS.md, .cursor/rules/*.mdc | .cursor/rules/ |
| 5 | **Windsurf** | .windsurfrules (旧) | .windsurf/rules/*.md |
| 6 | **Gemini CLI** | GEMINI.md | — |
| 7 | **Aider** | CONVENTIONS.md (需 `--read`) | — |
| 8 | **Cline** | .clinerules | .clinerules/*.md |
| 9 | **Roo Code** | .roorules (旧) | .roo/rules/*.md |
| 10 | **WorkBuddy** | .workbuddy/memory/MEMORY.md | ~/.workbuddy/memory/ |
| 11 | **CodeBuddy** | CODEBUDDY.md | .codebuddy/rules/{name}/RULE.mdc |
| 12 | **Trae** | CLAUDE.md, .trae/rules/project_rules.md | .trae/rules/ |
| 13 | **TONGYI Lingma** | — | .lingma/rules/*.md |
| 14 | **Augment Code** | .augment/guidelines.md | .augment/rules/*.md |
| 15 | **Qoder/QCode** | AGENTS.md | .qoder/rules/* |

---

## 迁移流程

### Phase 1: 检测源文件

在项目根目录扫描所有已知 AI 记忆文件（CLAUDE.md, AGENTS.md, .cursor/rules/*.mdc, .windsurfrules, GEMINI.md, CONVENTIONS.md, .clinerules, .roorules, .workbuddy/memory/MEMORY.md, CODEBUDDY.md, .trae/rules/, .lingma/rules/, .augment/rules/, .qoder/rules/ 等）。

### Phase 2: 解析为 Canonical 格式

**CLAUDE.md**: `##` headings → convention categories; `@path` imports → inline; paths frontmatter → scope_rules; 代码块 → commands.

**AGENTS.md**: `## Commands` → commands; `## Conventions` → conventions; `## Boundaries` → boundaries.

**Cursor (.mdc)**: `alwaysApply:true` → scope_rules(always); `alwaysApply:false`+globs → scope_rules(paths); `alwaysApply:false`+description only → agent-decided.

**Windsurf**: `trigger:always_on` → always; `trigger:glob`+globs → scoped; `trigger:model_decision` → agent-decided.

**Copilot**: 纯 Markdown → conventions; `applyTo` frontmatter → scope_rules.

**Gemini CLI**: 同 CLAUDE.md; 支持 `@file.md` 导入.

**Aider**: 纯 Markdown → conventions.

**Cline**: 纯文本 → conventions; paths frontmatter → scope_rules.

**Roo Code**: 纯 Markdown, 按目录/模式分组.

**WorkBuddy**: MEMORY.md → conventions+decisions; daily logs → memory entries.

**CodeBuddy**: 同 CLAUDE.md; RULE.mdc frontmatter → scope_rules.

**Trae/Lingma/Qoder**: 纯 Markdown → conventions.

**Augment**: `type:always_apply` → always; `type:agent_requested` → agent-decided.

### Phase 3: 合并

去重、优先平台特定规则、保留 scope 信息、标记冲突。

---

## 生成器

### 1. Claude Code Generator（主目标）

**输出文件：**
```
CLAUDE.md                          # 主项目指令
.claude/rules/{category}.md        # 模块化规则（paths frontmatter）
CLAUDE.local.md                    # 个人偏好（.gitignore）
```

**CLAUDE.md 模板：**
```markdown
# {project.name}

{project.description}

## Tech Stack
{tech_stack}

## Commands
{formatted commands}

## Project Structure
{formatted structure}

## Conventions
{conventions by category}

## Boundaries
{boundaries}

## Preferences
{preferences}
```

**规则文件模板（`.claude/rules/{name}.md`）：**
```markdown
---
paths:
  - "{glob_pattern}"
---

# {rule_name}

{rules}
```

**约束：**
- CLAUDE.md ≤ 200 行
- 如 AGENTS.md 已存在，用 `@AGENTS.md` 导入
- `.claude/rules/` 文件按字母序加载

### 2–15. 其他平台生成器

参考通用 SKILL.md 的 Generator #2–#15。

---

## 迁移命令

| 命令 | 用法 |
|------|------|
| `migrate to claude-code` | 检测→解析→生成 CLAUDE.md + .claude/rules/ |
| `migrate from claude-code` / `migrate to {p}` | 读取 CLAUDE.md → 解析 → 生成目标格式 |
| `detect` | 扫描并报告项目中已有的 AI 记忆文件 |
| `sync-all` | 为所有 15 个平台生成规则文件 |
| `export-canonical` | 导出 Canonical YAML 快照 |

---

## 特殊处理

### → Claude Code

| 源 | 映射 |
|----|------|
| AGENTS.md | Commands/Conventions → CLAUDE.md 对应章节 |
| .cursor/rules/*.mdc | `alwaysApply:true` → 无 FM; `globs` → `paths` FM |
| .clinerules | 纯 Markdown → CLAUDE.md conventions |
| WorkBuddy MEMORY.md | 章节标题 → convention categories |
| CodeBuddy RULE.mdc | `globs` → `paths` FM |

### ← Claude Code

| 目标 | 映射 |
|------|------|
| Cursor | paths FM → `globs`; 无 FM → `alwaysApply:true` |
| CodeBuddy | paths FM → `globs` |
| Windsurf | paths FM → trigger:glob + globs |
| Cline | paths FM → `paths` FM; 无 FM → 默认 |

### 字符限制

| 平台 | 限制 |
|------|------|
| Windsurf | 6K/文件，12K 总计 |
| Lingma | 10K/文件 |
| Codex | 32KB 总计 |
| Claude Code | ~200 行/文件 |

---

## 错误处理

1. 无源文件 → 建议手动创建或使用项目分析
2. 文件不可读 → 跳过并警告
3. Frontmatter 解析失败 → 视为纯文本
4. 目标文件已存在 → 询问覆盖/合并/取消
5. 字符超限 → 拆分或截断 + 警告
