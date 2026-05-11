---
name: ai-mind-migrate-cline
slug: ai-mind-migrate-cline
description: "跨平台 AI 上下文迁移工具，专为 Cline 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Cline 格式（.clinerules / .clinerules/*.md），也能将 Cline 规则反向导出到任意目标平台。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🧩"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for Cline

> 专为 Cline 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Cline 格式，
> 也能将 Cline 的 `.clinerules` / `.clinerules/*.md` 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Cline**: 从其他平台迁入，生成 `.clinerules` 或 `.clinerules/*.md`
- **从 Cline 迁出**: 将 `.clinerules` / `.clinerules/` 导出到其他 14 个平台
- **初始化 Cline**: 基于已有的 CLAUDE.md / `.cursor/rules` 生成 Cline 规则
- **从单文件升级到目录模式**: 将 `.clinerules` 拆分为 `.clinerules/` 目录

> ⚠️ Cline 的 frontmatter 官方支持 **仅有 `paths`**。不支持 `description` 或 `alwaysApply`。

关键词：cline, clinerules, .clinerules, cline rules, cline migration,
import to cline, export from cline,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, roo, aider, gemini, trae, lingma, augment, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–7, 9–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 8. Cline Generator（主目标 — 最详细）

**⚠️ Frontmatter**: Cline 官方文档只支持 `paths` frontmatter。没有 `description`，没有 `alwaysApply`。

**要创建的文件（按复杂度选择）：**

简单项目（无作用域规则需求）：
```
.clinerules                         # 单一文件
```

复杂项目（需要作用域规则）：
```
.clinerules/
  01-stack.md
  02-conventions.md
  03-testing.md
  04-api-patterns.md                # 如果有 paths frontmatter 则带作用域
```

全局规则位置（用户可手动复制）：
- **macOS/Linux**: `~/Documents/Cline/Rules/`
- **Windows**: `Documents\Cline\Rules`

Cline 还自动检测：`.cursorrules`、`.windsurfrules`、`AGENTS.md`

**单文件模板：**

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

**目录文件模板（带 frontmatter）：**

```markdown
---
paths:
  - "{glob_pattern}"
---

# {rule_name}

{rules}
```

**关键约束：**
- 文件按字母顺序加载 — 使用数字前缀控制顺序
- **无 frontmatter** = 始终加载（默认行为）
- **有 `paths` 的 frontmatter** = 条件加载（仅当匹配文件在上下文中时）
- `paths: []` = 从不加载（临时禁用规则）
- 工作空间规则（`.clinerules/`）覆盖全局规则（`~/Documents/Cline/Rules/`）
- 也自动检测 `.cursorrules`、`.windsurfrules`、`AGENTS.md`

---

## 迁移命令

### `migrate to cline`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 确认后根据复杂度选择单文件或目录模式
6. 生成 Cline 格式文件
7. 报告创建的文件和警告

### `migrate from cline` / `migrate to {platform}`

1. 读取 `.clinerules` / `.clinerules/` 中的内容
2. 解析到 Canonical 格式
3. 生成目标平台的对应文件

---

## 特殊处理

### 从其他平台迁移到 Cline

| 源平台 | 映射方式 |
|--------|----------|
| Cursor `.mdc` | `alwaysApply: true` → 无 FM（始终加载）；`globs` → `paths` FM |
| Claude Code `.claude/rules/*.md` | `paths` FM → `paths` FM（直接映射） |
| Windsurf `.md` | `trigger: always_on` → 无 FM；`trigger: glob` + `globs` → `paths` FM |
| CodeBuddy RULE.mdc | `alwaysApply: true` → 无 FM；`globs` → `paths` FM |
| Augment `.augment/rules/*.md` | `type: always_apply` → 无 FM；`agent_requested` → `paths: []`（暂不映射） |
| AGENTS.md | 纯 Markdown → 无 FM |

### 从 Cline 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Cursor | 无 FM → `alwaysApply: true`；`paths` FM → `globs` |
| Claude Code | 无 FM → `.claude/rules/` 无 FM；`paths` → `paths` FM |
| CodeBuddy | paths → globs mapping |
| Windsurf | paths → trigger: glob + globs |
| Augment | 无 FM → type: always_apply |

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
