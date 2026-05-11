---
name: ai-mind-migrate-cursor
slug: ai-mind-migrate-cursor
description: "跨平台 AI 上下文迁移工具，专为 Cursor 用户设计。一键将 Claude Code、Codex、WorkBuddy 等 14 个平台的记忆/规则迁移到 Cursor 格式（.cursor/rules/*.mdc + AGENTS.md），也能反向导出。从旧版 .cursorrules 升级到 .mdc 时使用。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
trigger:
  type: chat
  prompt: "当用户需要跨工具迁移规则、同步记忆、或从其他 AI 编码助手移植配置时"
metadata:
  openclaw:
    emoji: "🖱️"
    os: [linux, darwin, win32]
---

# AI Mind Migrate for Cursor

> 将 Claude Code、Codex、WorkBuddy 等平台的规则迁移到 Cursor (.cursor/rules/*.mdc + AGENTS.md)，或反向导出。

---

## 支持的 15 个平台

| # | Platform | 主文件 | 规则目录 |
|---|----------|--------|---------|
| 1 | **Claude Code** | CLAUDE.md, .claude/CLAUDE.md | .claude/rules/*.md |
| 2 | **OpenAI Codex** | AGENTS.md | — |
| 3 | **GitHub Copilot** | .github/copilot-instructions.md | .github/instructions/ |
| 4 | **Cursor (主目标)** | AGENTS.md, .cursor/rules/*.mdc | .cursor/rules/ |
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

扫描项目根目录中所有已知 AI 记忆文件（CLAUDE.md, AGENTS.md, .cursor/rules/*.mdc, .windsurfrules, .clinerules, .workbuddy/memory/MEMORY.md 等共 15 个平台格式）。

### Phase 2: 解析 → Canonical 格式

**Cursor (.mdc)**: `alwaysApply:true` → scope_rules(always); `alwaysApply:false`+`globs` → scope_rules(with paths); `alwaysApply:false`+description only → agent-decided; `alwaysApply:false`+no desc+no globs → manual.

**其余平台解析规则**: CLAUDE.md(headings→categories), AGENTS.md(Commands/Conventions/Boundaries→sections), Windsurf(trigger→scope_rules), Copilot(applyTo→scope_rules), Cline(paths→scope_rules), Roo(plain MD), WorkBuddy(MEMORY.md→conventions), CodeBuddy(RULE.mdc→scope_rules), Lingma/Qoder(NL→conventions), Augment(type→always/agent), Trae(plain MD).

### Phase 3: 合并

去重、优先平台特定规则、保留 scope 信息。

---

## 生成器

### Cursor Generator（主目标）

**输出文件：**
```
.cursor/rules/{name}.mdc            # 现代格式（带 frontmatter）
.cursor/rules/{name}.md             # 简单格式（无 frontmatter，始终）
AGENTS.md                           # 简化全局指令（可选）
```
> `.cursorrules`（单文件）已被弃用（Mar 2026+）。使用 `.mdc` 或 AGENTS.md。

**MDC 模板：**

| 模式 | `alwaysApply` | `globs` | `description` |
|------|:---:|:---:|:---:|
| Always Apply | `true` | ignored | ignored |
| Apply Intelligently | `false` | omitted | provided |
| Apply to Specific Files | `false` | provided | optional |
| Manual | `false` | omitted/empty | omitted/empty |

```markdown
---
description: "Rule description"
globs: src/**/*.ts          # 可选，按文件类型作用
alwaysApply: false           # `true` 则始终生效
---

# Rule Name

{rules}
```

**约束：**
- `.mdc` = 带 frontmatter; `.md` = 简单始终活跃
- AGENTS.md 也支持；用户规则通过 Cursor Settings → Rules UI 设置

---

## 跨平台映射

### → Cursor

| 源 | 映射 |
|----|------|
| Claude Code `.claude/rules/*.md` | `paths` → `globs` in `.mdc` |
| CodeBuddy RULE.mdc | `globs` → `globs`（直接） |
| Windsurf | `trigger:always_on` → `alwaysApply:true`; `trigger:glob` → `alwaysApply:false`+`globs` |
| Cline `.clinerules/*.md` | `paths` → `globs`; 无 FM → `alwaysApply:true` |
| Augment `.augment/rules/*.md` | `type:always_apply` → `alwaysApply:true`; `agent_requested` → `alwaysApply:false`+`desc` |
| `.cursorrules`（旧版） | 纯文本 → `.mdc` + AGENTS.md |

### ← Cursor

| 目标 | 映射 |
|------|------|
| Claude Code | `alwaysApply:true` → 无 FM; `globs` → `paths` |
| CodeBuddy | 直接映射到 RULE.mdc |
| Windsurf | `alwaysApply` → `trigger` 映射 |
| Cline | `globs` → `paths` |
| Augment | `alwaysApply` → `type` 映射 |

---

## 迁移命令

| 命令 | 操作 |
|------|------|
| `migrate to cursor` | 检测→解析→生成 `.cursor/rules/*.mdc` + AGENTS.md |
| `migrate from cursor` / `migrate to {p}` | 读取 `.cursor/rules/` → 解析 → 生成目标格式 |
| `detect` | 扫描并报告项目中已有 AI 记忆文件 |
