---
name: ai-mind-migrate-windsurf
slug: ai-mind-migrate-windsurf
description: "跨平台 AI 上下文迁移工具，专为 Windsurf 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 14 个平台的记忆/规则迁移到 Windsurf 格式（.windsurf/rules/*.md），也能反向导出。"
version: 1.0.0
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🏄"
    os: [linux, darwin, win32]
---

# AI Mind Migrate for Windsurf

> 将 Claude Code、Cursor、WorkBuddy 等平台的规则迁移到 Windsurf (.windsurf/rules/*.md)，或反向导出。

---

## 生成器：Windsurf（主目标）

**输出文件：**
```
.windsurf/
  rules/
    {name}.md                       # 带 YAML frontmatter
```
> 不要生成旧版 `.windsurfrules`。全局规则通过 Windsurf Settings UI 配置（非文件）。

**规则文件模板：**
```markdown
---
trigger: {always_on|glob|manual|model_decision}
description: "{rule_description}"
globs:
  - "{glob_pattern}"
---

{rules_content}
```

**约束：**
- 每文件 ≤ 6,000 字符（body 仅，frontmatter 不计）
- 所有活跃规则总计 ≤ 12,000 字符（全局 + 工作空间）
- 超限时：全局优先，范围内 `always_on` 优先
- `trigger` 值：`always_on`, `glob`, `manual`, `model_decision`
- Windsurf 也读取 AGENTS.md

---

## 跨平台映射

### → Windsurf

| 源 | 映射 |
|----|------|
| Cursor `.mdc` | `alwaysApply:true` → `trigger:always_on`; `globs` → `trigger:glob`+`globs` |
| Claude Code `.claude/rules/*.md` | `paths` → `trigger:glob`+`globs` |
| CodeBuddy RULE.mdc | `alwaysApply` → `trigger:always_on` / `trigger:glob` |
| Cline `.clinerules/*.md` | `paths` → `trigger:glob`+`globs` |
| Augment `.augment/rules/*.md` | `type:always_apply` → `trigger:always_on`; `agent_requested` → `trigger:model_decision` |

### ← Windsurf

| 目标 | 映射 |
|------|------|
| Cursor | `trigger:always_on` → `alwaysApply:true`; `trigger:glob` → `alwaysApply:false`+`globs` |
| Claude Code | `trigger:always_on` → 无 FM; `trigger:glob` → `paths` |
| CodeBuddy | `trigger` → `alwaysApply` 映射 |
| Cline | `trigger:glob`+`globs` → `paths` |
| Augment | `trigger:always_on` → `type:always_apply`; `trigger:model_decision` → `type:agent_requested` |

---

## 迁移命令

| 命令 | 操作 |
|------|------|
| `migrate to windsurf` | 检测→解析→生成 `.windsurf/rules/*.md`，检查字符限制 |
| `migrate from windsurf` / `migrate to {p}` | 读取 `.windsurf/rules/` → 解析 → 生成目标格式 |
| `detect` | 扫描项目中所有 AI 记忆文件 |
