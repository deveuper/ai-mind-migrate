---
name: ai-mind-migrate-gemini-cli
slug: ai-mind-migrate-gemini-cli
description: "跨平台 AI 上下文迁移工具，专为 Gemini CLI 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Gemini CLI 格式（GEMINI.md），也能将 Gemini CLI 配置反向导出到任意目标平台。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "✨"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for Gemini CLI

> 专为 Gemini CLI (Google) 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Gemini CLI 格式，
> 也能将 Gemini 的 GEMINI.md 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Gemini CLI**: 从其他平台迁入，生成 GEMINI.md
- **从 Gemini CLI 迁出**: 将 GEMINI.md 导出到其他 14 个平台
- **初始化 Gemini CLI**: 基于已有的 CLAUDE.md / AGENTS.md / `.cursor/rules` 生成 GEMINI.md
- **配置 Gemini CLI**: 基于迁移内容更新 settings.json

关键词：gemini, gemini cli, GEMINI.md, google ai, gemini migration,
import to gemini, export from gemini,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, roo, aider, trae, lingma, augment, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–5, 7–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 6. Gemini CLI Generator（主目标 — 最详细）

**要创建的文件：**

```
GEMINI.md                           # 项目指令
```

**GEMINI.md 模板：**

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

**关键约束：**
- 支持 `@file.md` 导入实现模块化
- 文件名可通过 `settings.json` → `context.fileName` 配置
- 可以设置为 `["AGENTS.md", "GEMINI.md"]` 实现与 Codex 互通
- 层级发现：全局 → 项目 → 子目录

---

## 迁移命令

### `migrate to gemini`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 确认后生成 GEMINI.md
6. 报告创建的文件和警告

---

## 特殊处理

### 从其他平台迁移到 Gemini CLI

| 源平台 | 映射方式 |
|--------|----------|
| CLAUDE.md | `##` headings → GEMINI.md sections |
| AGENTS.md | `## Commands` → `## Commands` |
| .cursor/rules/*.mdc | 合并 conventions → GEMINI.md |
| WorkBuddy MEMORY.md | Sections → 对应 GEMINI.md 章节 |

### 处理 @file.md 导入

如果源平台（Claude Code、CodeBuddy）有 `@path` 导入：
- 将导入文件内容内联到 GEMINI.md，添加注释标记源
- 如果目标也是 Gemini CLI，保留 `@file.md` 导入语法

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
