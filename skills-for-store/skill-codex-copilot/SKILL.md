---
name: ai-mind-migrate-codex-copilot
slug: ai-mind-migrate-codex-copilot
description: "跨平台 AI 上下文迁移工具，专为 OpenAI Codex 和 GitHub Copilot 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 13 个平台的记忆/规则迁移到 AGENTS.md 或 copilot-instructions.md 格式，也能反向导出。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🤖"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for OpenAI Codex & GitHub Copilot

> 专为 OpenAI Codex 和 GitHub Copilot 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 13 个平台的记忆/规则迁移到 Codex/Copilot 格式，
> 也能将 AGENTS.md / `.github/copilot-instructions.md` 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Codex**: 从其他平台迁入，生成 AGENTS.md
- **迁移到 Copilot**: 从其他平台迁入，生成 `.github/copilot-instructions.md`
- **从 Codex/Copilot 迁出**: 将 AGENTS.md 或 copilot-instructions.md 导出到其他平台
- **同步 Codex 与 Copilot**: 同时生成两个平台的规则文件
- **初始化 Codex/Copilot**: 基于已有的 CLAUDE.md / `.cursor/rules` 生成对应格式

关键词：codex, openai codex, AGENTS.md, copilot, github copilot, copilot instructions,
codex migration, copilot migration, import to codex, export from codex,
migrate, transfer, port, convert, export, sync, claude code, cursor, workbuddy,
codebuddy, windsurf, cline, roo, aider, gemini, trae, lingma, augment, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## 架构：Canonical → 平台格式

同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 3, 5–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 2. OpenAI Codex Generator（主目标之一）

**要创建的文件：**

```
AGENTS.md                           # 单一项目指令文件
```

**AGENTS.md 模板：**

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

**关键约束：**
- 全局 `~/.codex/AGENTS.md` 保持在 2–3 KB 以下
- 所有项目文档总计不超过 32 KiB（默认 `project_doc_max_bytes`）
- 无 YAML frontmatter
- 支持 `AGENTS.override.md` 用于临时覆盖
- 可通过 `project_doc_fallback_filenames` 在 config.toml 中配置

---

### 3. GitHub Copilot Generator（主目标之一）

**要创建的文件：**

```
.github/
  copilot-instructions.md           # 项目级指令
  instructions/                      # 作用域指令（如果有 scope_rules）
    {name}.instructions.md
```

**copilot-instructions.md 模板：**

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

**Scoped instructions 模板：**

```markdown
---
applyTo: "{glob_pattern}"
---

# {rule_name}

{rules}
```

**关键约束：**
- 文件合并时没有保证的排序
- `applyTo` 使用 glob 模式进行文件匹配
- 保持指令简洁可操作
- Copilot 也自动读取 `AGENTS.md`、`CLAUDE.md`、`GEMINI.md`

---

## 迁移命令

### `migrate to codex` / `migrate to copilot`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 确认后生成对应的格式文件
6. 报告创建的文件和警告

### `migrate from codex` / `migrate from copilot` / `migrate to {platform}`

1. 读取源平台的规则文件
2. 解析到 Canonical 格式
3. 生成目标平台的对应文件

---

## 特殊处理

### 从其他平台迁移到 Codex

| 源平台 | 映射方式 |
|--------|----------|
| CLAUDE.md | `##` headings → `##` sections in AGENTS.md |
| .cursor/rules/*.mdc | 合并所有规则的 conventions 到 AGENTS.md（scope 信息用注释保留） |
| WorkBuddy MEMORY.md | Sections → AGENTS.md sections |

### 从其他平台迁移到 Copilot

| 源平台 | 映射方式 |
|--------|----------|
| CLAUDE.md `.claude/rules/*.md` | `paths` FM → `applyTo` FM 在 `.instructions.md` |
| Cursor `.mdc` | `globs` → `applyTo`, `alwaysApply: true` → main copilot-instructions.md |
| Windsurf `.md` | `trigger: always_on` → copilot-instructions.md, `trigger: glob` → scoped `.instructions.md` |

### 从 Codex/Copilot 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Claude Code | AGENTS.md `## Commands` → `## Commands`, conventions preserved |
| Cursor | main content → AGENTS.md, scope info from comments → `.mdc` |

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
