---
name: ai-mind-migrate-trae
slug: ai-mind-migrate-trae
description: "跨平台 AI 上下文迁移工具，专为 Trae 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Trae 格式（.trae/rules/project_rules.md + CLAUDE.md），也能将 Trae 规则反向导出到任意目标平台。支持多层规则优先级映射。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🌳"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for Trae

> 专为 Trae 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Trae 格式，
> 也能将 Trae 的 `.trae/rules/` / CLAUDE.md 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Trae**: 从其他平台迁入，生成 `.trae/rules/project_rules.md`
- **从 Trae 迁出**: 将 `.trae/rules/` / CLAUDE.md 导出到其他 14 个平台
- **初始化 Trae**: 基于已有的 CLAUDE.md / AGENTS.md 生成 Trae 规则
- **配置 Trae 多层规则**: 配置 project-level / user-level / global rules 优先级

关键词：trae, trae rules, .trae, trae migration, trae project rules,
import to trae, export from trae, bytedance,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, roo, aider, gemini, lingma, augment, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–11, 13–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 12. Trae Generator（主目标 — 最详细）

**要创建的文件：**

```
CLAUDE.md                           # 团队共享规则（可选，Claude Code 兼容）
.trae/
  rules/
    project_rules.md                # 项目级规则（团队共享）
    user_rules.md                   # 项目级个人规则（可选）
  settings.json                     # 行为配置（可选）
  mcp.json                          # MCP 服务（可选）
  tasks.json                        # 自定义任务自动化（可选）
  skills/                           # 可复用技能（可选）
    {name}/
      SKILL.md
  agents/                           # 子代理（可选）
    {name}.md
```

**project_rules.md 模板：**

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

**关键约束：**
- 两个规则层级，优先级：project_rules.md > user_rules.md（项目级）> user_rules.md（用户级 `~/.trae/`）> 默认值
- 也使用 `CLAUDE.md` 和 `CLAUDE.local.md` 作为规则（与 Claude Code 兼容）
- 用户规则可以同时存在于项目级（`.trae/rules/user_rules.md`）和用户级（`~/.trae/rules/user_rules.md`）
- 通过 `trae-memory-mcp` MCP 服务支持记忆系统
- 类似于 Claude Code，Trae 支持 skills（`.trae/skills/`）和 agents（`.trae/agents/`）

---

## 迁移命令

### `migrate to trae`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 询问用户规则层级（project_rules.md / user_rules.md）
6. 确认后生成 Trae 格式文件
7. 报告创建的文件和警告

---

## 特殊处理

### 从其他平台迁移到 Trae

| 源平台 | 映射方式 |
|--------|----------|
| CLAUDE.md | `##` headings → project_rules.md sections（Claude Code 兼容） |
| AGENTS.md | `## Commands` / `## Conventions` → project_rules.md |
| .cursor/rules/*.mdc | conventions → project_rules.md |
| CodeBuddy CODEBUDDY.md | 同上（CLAUDE.md 映射） |

### 从 Trae 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Claude Code | project_rules.md → CLAUDE.md（直接兼容） |
| Cursor | project_rules.md → AGENTS.md 或 `.mdc` |
| WorkBuddy | project_rules.md → MEMORY.md |

### 规则层级映射

Trae 有 4 层规则优先级。迁移时：从其他平台生成到 Trae → 默认 project_rules.md（用户可手动复制到其他层级）
从 Trae 生成到其他平台 → 按优先级读取，合并所有层级。

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
