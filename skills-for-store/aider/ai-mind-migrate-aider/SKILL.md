---
name: ai-mind-migrate-aider
slug: ai-mind-migrate-aider
description: "跨平台 AI 上下文迁移工具，专为 Aider 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Aider 格式（CONVENTIONS.md），也能将 Aider 约定反向导出到任意目标平台。注意：Aider 不自动加载 CONVENTIONS.md，需使用 --read 参数。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🧑‍💻"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for Aider

> 专为 Aider 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Aider 格式，
> 也能将 Aider 的 CONVENTIONS.md 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Aider**: 从其他平台迁入，生成 CONVENTIONS.md
- **从 Aider 迁出**: 将 CONVENTIONS.md 导出到其他 14 个平台
- **初始化 Aider**: 基于已有的 CLAUDE.md / AGENTS.md 生成 CONVENTIONS.md
- **配置 .aider.conf.yml**: 添加 `read: CONVENTIONS.md` 配置

> ⚠️ **Aider 的特殊性**：不同于其他平台，Aider 不会自动加载 CONVENTIONS.md。
> 迁移生成的 CONVENTIONS.md 需要使用 `aider --read CONVENTIONS.md` 或在 `.aider.conf.yml` 中配置后才能生效。

关键词：aider, CONVENTIONS.md, aider conventions, aider migration, aider config,
import to aider, export from aider, aider --read,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, roo, gemini, trae, lingma, augment, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–6, 8–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 7. Aider Generator（主目标 — 最详细）

**⚠️ CRITICAL**: 与其他平台不同，Aider 不会自动加载 `CONVENTIONS.md`。您必须明确使用：

```bash
aider --read CONVENTIONS.md        # 启动时加载
# 或 chat 内：
/read CONVENTIONS.md
# 或在 .aider.conf.yml 中：
read: CONVENTIONS.md
```

**要创建的文件：**

```
CONVENTIONS.md                      # 编码约定（必须显式加载）
```

**CONVENTIONS.md 模板：**

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

**关键约束：**
- 简单的 Markdown 格式
- `CONVENTIONS.md` 是标准约定文件
- `.aider.conf.yml` 用于工具配置（非规则）
- 社区约定文件：github.com/Aider-AI/conventions

---

## 迁移命令

### `migrate to aider`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 确认后生成 CONVENTIONS.md
6. **添加警告**：告知用户需要使用 `--read` 加载

---

## 特殊处理

### 从其他平台迁移到 Aider

由于 Aider 不自动加载 CONVENTIONS.md，迁移时需注意：

| 源平台 | 映射方式 |
|--------|----------|
| CRITICAL | 不导入作用域规则（Aider 不支持 scope）— 用注释标记来源 |
| CLAUDE.md | `##` headings → `##` sections 在 CONVENTIONS.md |
| AGENTS.md | 直接映射 conventions |
| .cursor/rules/*.mdc | 合并所有规则的 conventions 到 CONVENTIONS.md |
| WorkBuddy MEMORY.md | Sections → CONVENTIONS.md sections |

### 从 Aider 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Claude Code | CONVENTIONS.md conventions → CLAUDE.md `## Conventions` |
| Cursor | 内容 → AGENTS.md 或 `.mdc` |
| WorkBuddy | 内容 → MEMORY.md conventions |

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
