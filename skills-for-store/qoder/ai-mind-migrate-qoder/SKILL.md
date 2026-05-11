---
name: ai-mind-migrate-qoder
slug: ai-mind-migrate-qoder
description: "跨平台 AI 上下文迁移工具，专为 Qoder/QCode 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Qoder 格式（.qoder/rules/* + AGENTS.md），也能将 Qoder 规则反向导出到任意目标平台。支持规则类型映射（Always/Model Decision/Manual/Specific Files），100K 字符总限制。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "⚡"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for Qoder / QCode

> 专为 Qoder/QCode 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Qoder 格式，
> 也能将 Qoder 的 `.qoder/rules/` / AGENTS.md 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Qoder**: 从其他平台迁入，生成 `.qoder/rules/*` + AGENTS.md
- **从 Qoder 迁出**: 将 `.qoder/rules/` 导出到其他 14 个平台
- **初始化 Qoder**: 基于已有的 CLAUDE.md / `.cursor/rules` 生成 Qoder 规则
- **配置规则类型**: 在 IDE UI 中设置 Always / Model Decision / Manual / Specific Files

关键词：qoder, qcode, qoder rules, .qoder, qcoder, qoder migration,
import to qoder, export from qoder,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, roo, aider, gemini, trae, lingma, augment

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–14. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 15. Qoder/QCode Generator（主目标 — 最详细）

**要创建的文件：**

```
AGENTS.md                           # 跨工具标准（AGENTS.md 格式）
.qoder/
  rules/
    {name}                          # 每规则一个文件（无需扩展名）
```

**AGENTS.md**（参见通用 SKILL.md 的 Generator #2 格式）— Qoder 完全支持 AGENTS.md。

**Qoder 规则文件模板（`.qoder/rules/{name}`）：**

```markdown
{rules in natural language — no images or links}

Examples:
- 编码规范：变量使用驼峰命名法(camelCase)
- 错误处理：始终使用 try-catch 包裹
```

**关键约束：**
- Qoder 有自己的 `.qoder/rules/` 目录
- 与 Lingma 相同的 4 种规则类型（通过 IDE UI 设置）：Manual, Model Decision, Always, Specific Files
- **所有活跃规则总共最多 100,000 字符**（超出部分截断）
- AGENTS.md 也完全支持；`.qoder/rules/` 在冲突时优先级更高
- 规则文件中无 YAML frontmatter — 类型通过 IDE UI 设置
- 规则通过版本控制共享（将 `.qoder/rules` 添加到 `.gitignore` 以表示本地规则）

**类型提示头（同 Lingma）：**

```markdown
<!-- Rule Type: Always | Description: {description} | Files: {glob_patterns} -->
{rules content}
```

---

## 迁移命令

### `migrate to qoder`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 询问用户规则类型分配方案
6. 确认后生成 `.qoder/rules/*` + AGENTS.md（可选）
7. 检查字符限制（100K 总限制）
8. 报告创建的文件和警告

### `migrate from qoder` / `migrate to {platform}`

1. 读取 `.qoder/rules/` 和 AGENTS.md 中的内容
2. 解析类型提示头以确定规则类型
3. 解析到 Canonical 格式
4. 生成目标平台的对应文件

---

## 特殊处理

### 从其他平台迁移到 Qoder

| 源平台 | 映射方式 |
|--------|----------|
| Cursor `.mdc` | `alwaysApply: true` → `<!-- Rule Type: Always -->`；`globs` → `Files:` |
| Claude Code `.claude/rules/*.md` | `paths` FM → `Files:` |
| Windsurf `.md` | `trigger: always_on` → Always；`trigger: glob` → Specific Files |
| Lingma `.lingma/rules/*.md` | 直接映射（相同架构） |
| CodeBuddy RULE.mdc | `alwaysApply` → Always/Agentic 映射 |
| Augment `.augment/rules/*.md` | `type: always_apply` → Always；`agent_requested` → Model Decision |
| AGENTS.md | AGENTS.md（直接复用） |

### 从 Qoder 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Cursor | `Always` → `alwaysApply: true`；`Specific Files` → `alwaysApply: false` + `globs` |
| Claude Code | `Always` → 无 frontmatter；`Specific Files` → `paths` FM |
| CodeBuddy | Always → `alwaysApply: true` |
| Lingma | 直接映射（相同架构） |
| Windsurf | Always → `trigger: always_on`；Model Decision → `trigger: model_decision` |

### AGENTS.md 与 `.qoder/rules/` 冲突处理

Qoder 同时支持 AGENTS.md 和 `.qoder/rules/`。迁移时：
- **迁移到 Qoder**：
  - conventions/commands → AGENTS.md
  - scoped rules → `.qoder/rules/`
  - AGENTS.md 中命名相同的约定 → 在 `.qoder/rules/` 中覆盖
- **从 Qoder 迁移**：
  - 读取 `.qoder/rules/` 获得约定范围和类型
  - 读取 AGENTS.md 获得命令和项目信息
  - `.qoder/rules/` 在冲突时优先

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
