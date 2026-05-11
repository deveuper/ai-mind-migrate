---
name: ai-mind-migrate-augment
slug: ai-mind-migrate-augment
description: "跨平台 AI 上下文迁移工具，专为 Augment Code 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Augment Code 格式（.augment/guidelines.md + .augment/rules/*.md），也能将 Augment 规则反向导出到任意目标平台。支持 always_apply / agent_requested 类型映射。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "➕"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for Augment Code

> 专为 Augment Code 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Augment Code 格式，
> 也能将 Augment 的 `.augment/guidelines.md` / `.augment/rules/*.md` 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Augment**: 从其他平台迁入，生成 `.augment/guidelines.md` + `.augment/rules/*.md`
- **从 Augment 迁出**: 将 `.augment/` 导出到其他 14 个平台
- **初始化 Augment**: 基于已有的 CLAUDE.md / AGENTS.md 生成 Augment 规则
- **配置规则类型**: 设置 always_apply / agent_requested 类型

关键词：augment, augment code, .augment, augment guidelines, augment rules,
import to augment, export from augment,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, roo, aider, gemini, trae, lingma, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–13, 15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 14. Augment Code Generator（主目标 — 最详细）

**要创建的文件：**

```
.augment/
  guidelines.md                     # 主要工作空间准则
  rules/                            # 模块化规则（如果有 scope_rules）
    {name}.md
.augment-guidelines                 # 替代准则文件（仍然有效）
```

**guidelines.md 模板：**

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

**规则文件模板：**

```markdown
---
type: {always_apply|agent_requested}
description: "{rule_description}"
---

# {rule_name}

{rules}
```

> ⚠️ `type: manual` 仅存在于 IDE（非 CLI）— 通过 @ 提及附加。

**关键约束：**
- 也支持 AGENTS.md 和 CLAUDE.md（作为后备加载，优先级更高）
- `.augment/rules/` 仅从工作空间根目录加载（非子目录）
- `~/.augment/rules/` 用于用户全局规则（始终 `always_apply`，不支持 frontmatter）
- `type: agent_requested` 优化上下文使用 — AI 决定何时应用
- 加载优先级：AGENTS.md/CLAUDE.md > `.augment-guidelines` > `.augment/rules/` > `~/.augment/rules/`

---

## 迁移命令

### `migrate to augment`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 询问用户类型分配（always_apply / agent_requested）
6. 确认后生成 Augment Code 格式文件
7. 报告创建的文件和警告

### `migrate from augment` / `migrate to {platform}`

1. 读取 `.augment/guidelines.md` / `.augment/rules/*.md` 中的内容
2. 解析 `type` frontmatter 获得激活类型
3. 解析到 Canonical 格式
4. 生成目标平台的对应文件

---

## 特殊处理

### 从其他平台迁移到 Augment

| 源平台 | 映射方式 |
|--------|----------|
| Cursor `.mdc` | `alwaysApply: true` → `type: always_apply`；`description` preserved；`globs` unsupported → 用注释标记 |
| Claude Code `.claude/rules/*.md` | 无 FM → `type: always_apply`；`paths` FM → 用注释标记路径 |
| Windsurf `.md` | `trigger: always_on` → `type: always_apply`；`trigger: model_decision` → `type: agent_requested` |
| CodeBuddy RULE.mdc | `alwaysApply: true` → `type: always_apply`；`alwaysApply: false` + `description` → `type: agent_requested` |
| Cline `.clinerules/*.md` | 无 FM → `type: always_apply` |
| AGENTS.md | `type: always_apply`（guidelines.md） |
| WorkBuddy MEMORY.md | Sections → guidelines.md sections |

### 从 Augment 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Cursor | `type: always_apply` → `alwaysApply: true`；`agent_requested` → `alwaysApply: false` + `description` |
| Claude Code | `type: always_apply` → 无 FM；`agent_requested` → 可选路径 |
| CodeBuddy | always_apply → `alwaysApply: true`；agent_requested → `alwaysApply: false` + description |
| Windsurf | always_apply → `trigger: always_on`；agent_requested → `trigger: model_decision` |
| Cline | always_apply → 无 FM |

### 自动检测后备处理

Augment 自动检测 AGENTS.md 和 CLAUDE.md。迁移到 Augment 时：
- 如果已有 AGENTS.md，保留它（优先级高于 `.augment/`）
- 如果已有 CLAUDE.md，保留它（优先级高于 AGENTS.md）
- 生成 `.augment/` 作为补充而非替代

从 Augment 迁移时：
- 读取 AGENTS.md 和 CLAUDE.md（如果存在）以获得完整上下文
- 但优先使用 `.augment-guidelines` 和 `.augment/rules/` 中的显式规则

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
