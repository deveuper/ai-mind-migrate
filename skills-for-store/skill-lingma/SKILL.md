---
name: ai-mind-migrate-lingma
slug: ai-mind-migrate-lingma
description: "跨平台 AI 上下文迁移工具，专为 TONGYI Lingma（通义灵码）用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Lingma 格式（.lingma/rules/*.md），也能将 Lingma 规则反向导出到任意目标平台。支持规则类型映射（Always/Model Decision/Manual/Specific Files）。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🐉"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for TONGYI Lingma

> 专为 TONGYI Lingma（通义灵码）用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Lingma 格式，
> 也能将 Lingma 的 `.lingma/rules/*.md` 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Lingma**: 从其他平台迁入，生成 `.lingma/rules/*.md`
- **从 Lingma 迁出**: 将 `.lingma/rules/` 导出到其他 14 个平台
- **初始化 Lingma**: 基于已有的 CLAUDE.md / `.cursor/rules` 生成 Lingma 规则
- **配置规则类型**: 在 IDE UI 中设置 Always / Model Decision / Manual / Specific Files

关键词：lingma, tongyi lingma, 通义灵码, .lingma, lingma rules, lingma migration,
import to lingma, export from lingma, alibaba,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, roo, aider, gemini, trae, augment, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–12, 14–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 13. TONGYI Lingma Generator（主目标 — 最详细）

**要创建的文件：**

```
.lingma/
  rules/
    {name}.md                       # 每规则一个文件
```

**规则文件模板：**

```markdown
{rules in natural language — no images or links}

Examples:
- 命名规范：变量使用驼峰命名法(camelCase)，类名使用帕斯卡命名法(PascalCase)
- 错误处理：始终使用 try-catch 包裹可能出错的代码
```

**关键约束：**
- **每个规则文件最多 10,000 字符**（超出部分截断）
- 仅自然语言 — 不支持图片或链接解析
- 4 种规则类型（通过 IDE UI 设置，非 frontmatter）：
  - Manual：通过 `#rule` / `@rule` 调用
  - Model Decision：AI 基于描述决定
  - Always：应用于所有请求
  - Specific Files：通过 glob 模式匹配
- 由于规则类型通过 IDE UI 设置，生成的文件应包含注释头标明意图类型
- 文件通过版本控制共享（个人规则添加到 .gitignore）

**类型提示头：**

```markdown
<!-- Rule Type: Always | Description: {description} | Files: {glob_patterns} -->
{rules content}
```

---

## 迁移命令

### `migrate to lingma`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 询问用户规则类型分配方案
6. 确认后生成 `.lingma/rules/*.md`，包含类型提示头
7. 检查字符限制（10K/文件）
8. 报告创建的文件和警告

### `migrate from lingma` / `migrate to {platform}`

1. 读取 `.lingma/rules/*.md` 中的内容
2. 解析类型提示头以确定规则类型
3. 解析到 Canonical 格式
4. 生成目标平台的对应文件

---

## 特殊处理

### 从其他平台迁移到 Lingma

| 源平台 | 映射方式 |
|--------|----------|
| Cursor `.mdc` | `alwaysApply: true` → `<!-- Rule Type: Always -->`；`globs` → `Files: {globs}` |
| Claude Code `.claude/rules/*.md` | `paths` FM → `Files: {paths}` |
| Windsurf `.md` | `trigger: always_on` → Always；`trigger: glob` → Specific Files |
| CodeBuddy RULE.mdc | `alwaysApply` → Always/Agentic 映射 |
| Augment `.augment/rules/*.md` | `type: always_apply` → Always；`agent_requested` → Model Decision |
| Cline `.clinerules/*.md` | 无 FM → Always；`paths` FM → Specific Files |

### 从 Lingma 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Cursor | `Always` → `alwaysApply: true`；`Specific Files` → `alwaysApply: false` + `globs` |
| Claude Code | `Always` → 无 frontmatter；`Specific Files` → `paths` FM |
| CodeBuddy | Always → `alwaysApply: true`；Agentic → `alwaysApply: false` |
| Windsurf | Always → `trigger: always_on`；Model Decision → `trigger: model_decision` |

### 映射规则类型

| Lingma 类型 | Cursor 模式 | Claude Code | CodeBuddy | Windsurf |
|-------------|-------------|-------------|-----------|----------|
| Always | alwaysApply:true | 默认 | alwaysApply:true | trigger:always_on |
| Model Decision | Apply Intelligently | — | alwaysApply:false + desc | model_decision |
| Manual | Manual | — | — | manual |
| Specific Files | Specific Files | paths: | globs | glob |

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
