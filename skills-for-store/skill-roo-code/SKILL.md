---
name: ai-mind-migrate-roo-code
slug: ai-mind-migrate-roo-code
description: "跨平台 AI 上下文迁移工具，专为 Roo Code 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Roo Code 格式（.roo/rules/*.md + .roorules），也能将 Roo Code 规则反向导出到任意目标平台。支持 mode-specific 规则（code/architect/ask）。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🦘"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for Roo Code

> 专为 Roo Code 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Roo Code 格式，
> 也能将 Roo Code 的 `.roo/rules/` / `.roorules` 反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 Roo Code**: 从其他平台迁入，生成 `.roo/rules/*.md`
- **从 Roo Code 迁出**: 将 `.roo/rules/` 导出到其他 14 个平台
- **初始化 Roo Code**: 基于已有的 CLAUDE.md / `.cursor/rules` 生成 Roo 规则
- **从旧版 `.roorules` 迁移**: 升级到 `.roo/rules/` 目录结构
- **配置模式特定规则**: 为不同模式（code, architect, ask 等）生成规则

关键词：roo, roo code, roo rules, .roo, .roorules, roo migration, roo code rules,
import to roo, export from roo, roo mode rules,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, aider, gemini, trae, lingma, augment, qoder

---

## 支持的平台（15 个）

完整 15 平台表格同通用 SKILL.md。

---

## Parser 规则（15 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节。

---

## 平台生成器

### 1–8, 10–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 9. Roo Code Generator（主目标 — 最详细）

**要创建的文件：**

```
.roo/
  rules/
    {name}.md                       # 通用规则
  rules-code/
    {name}.md                       # Code 模式特定规则
  rules-architect/
    {name}.md                       # Architect 模式特定规则
```

**旧版后备（如果目录太复杂）：**
```
.roorules                           # 单文件（旧版）
```

**规则文件模板：**

```markdown
# {rule_name}

{rules as numbered or bulleted list}
```

**关键约束：**
- 无 YAML frontmatter — 规则是纯 Markdown
- 模式特定规则放在 `.roo/rules-{modeSlug}/` 目录下
- 支持 AGENTS.md 作为跨工具标准
- 文件按基本名称字母顺序排序
- 递归读取，自动排除临时文件
- 常见 mode slugs：code, architect, ask, debug, custom

---

## 迁移命令

### `migrate to roo-code`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 询问用户目标模式（code / architect / ask / 通用）
6. 确认后生成 Roo Code 格式文件
7. 报告创建的文件和警告

### `migrate from roo-code` / `migrate to {platform}`

1. 读取 `.roo/rules/` / `.roorules` 中的内容
2. 解析到 Canonical 格式
3. 生成目标平台的对应文件

---

## 特殊处理

### 从其他平台迁移到 Roo Code

| 源平台 | 映射方式 |
|--------|----------|
| Cursor `.mdc` | `alwaysApply: true` → `.roo/rules/`；scope 信息用注释保留 |
| Claude Code `.claude/rules/*.md` | `paths` FM → 在规则中添加文件作用域注释 |
| Windsurf `.md` | `trigger: always_on` → `.roo/rules/`；作用域信息保留在注释中 |
| AGENTS.md | 纯 Markdown → `.roo/rules/` |
| Cline `.clinerules/` | `paths` FM → 添加文件作用域注释 |
| CodeBuddy RULE.mdc | `alwaysApply` preserved → `.roo/rules/` |

### 从 Roo Code 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| Cline | `.roo/rules/` → `.clinerules/`（if paths comment → paths FM） |
| Cursor | `.roo/rules/` → `.mdc`（alwaysApply: true） |
| Claude Code | `.roo/rules/` → `.claude/rules/` |

### 模式特定规则处理

如果源平台有特定模式的规则（如 `.roo/rules-code/` 中的规则）：
- 在 Canonical 格式的 scope_rules 中添加 `mode: code` 元数据
- 迁移到其他平台时，在规则内容中添加 `[Mode: code]` 注释前缀
- 从其他平台迁移到 Roo Code 时，如果没有模式信息，默认放入 `.roo/rules/`

---

## 错误处理 & 最佳实践

同通用 SKILL.md。
