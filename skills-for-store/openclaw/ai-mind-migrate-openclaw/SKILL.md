---
name: ai-mind-migrate-openclaw
description: "跨平台 AI 上下文迁移工具，专为 OpenClaw / ClawHub 用户设计。一键将 Claude Code、Cursor、WorkBuddy 等 15 个平台的记忆/规则迁移到 OpenClaw Skill 格式（YAML frontmatter + metadata.openclaw），也能将 OpenClaw 的 SKILL.md 反向导出到任意目标平台。"
version: 1.0.0
slug: ai-mind-migrate-openclaw
homepage: https://github.com/deveuper/ai-mind-migrate
metadata:
  openclaw:
    emoji: "🦞"
    os:
      - linux
      - darwin
      - win32
---

# AI Mind Migrate for OpenClaw / ClawHub

> 专为 OpenClaw / ClawHub 用户设计的跨平台 AI 上下文迁移工具。
> 一键将 Claude Code、Cursor、WorkBuddy 等 15 个平台的记忆/规则迁移到 OpenClaw Skill 格式，
> 也能将 OpenClaw 的 SKILL.md（YAML frontmatter + 指令）反向导出到任意目标平台。

## When to Use

当用户有以下需求时触发此 Skill：

- **迁移到 OpenClaw/ClawHub**: 从其他平台迁入，生成带有完整 frontmatter 的 SKILL.md
- **从 OpenClaw 迁出**: 将 SKILL.md 的 frontmatter + body 导出到其他 15 个平台
- **创建 ClawHub 发布的 Skill**: 生成符合 ClawHub 规范的 SKILL.md（含 metadata.openclaw）
- **转换 Skill 格式**: 将其他平台的规则文件打包为 OpenClaw 可安装的 Skill
- **同步 Skill 配置**: 在多个 AI 助手间保持 Skill 行为一致

关键词：openclaw, clawhub, clawdbot, SKILL.md, skill format, openclaw skill, clawhub publish,
skill migration, import to clawhub, export from clawhub, install skill,
migrate, transfer, port, convert, export, sync, claude code, cursor, codex, copilot,
workbuddy, codebuddy, windsurf, cline, roo, aider, gemini, trae, lingma, augment, qoder

---

## 支持的平台（16 个）

| # | Platform | Primary File(s) | Rules Directory | Notes |
|---|----------|----------------|-----------------|-------|
| 1 | **Claude Code** | `CLAUDE.md`, `.claude/CLAUDE.md` | `.claude/rules/*.md` | `${project_dir}` |
| 2 | **OpenAI Codex** | `AGENTS.md` | — | `~/.codex/AGENTS.md` |
| 3 | **GitHub Copilot** | `.github/copilot-instructions.md` | `.github/instructions/*.instructions.md` | Also reads AGENTS.md, CLAUDE.md |
| 4 | **Cursor** | `AGENTS.md` (simple) | `.cursor/rules/*.mdc` | `.cursorrules` deprecated |
| 5 | **Windsurf** | `.windsurfrules` (legacy) | `.windsurf/rules/*.md` | Also reads AGENTS.md |
| 6 | **Gemini CLI** | `GEMINI.md` | — | `@file.md` imports |
| 7 | **Aider** | `CONVENTIONS.md` (⚠️ use `--read`) | — | NOT auto-loaded |
| 8 | **Cline** | `.clinerules` | `.clinerules/*.md` | Only `paths` frontmatter |
| 9 | **Roo Code** | `.roorules` (legacy) | `.roo/rules/*.md` | Also reads AGENTS.md |
| 10 | **WorkBuddy** | `.workbuddy/memory/MEMORY.md` | `~/.workbuddy/memory/` (daily logs) | Project memory + identity files |
| 11 | **CodeBuddy** | `CODEBUDDY.md`, `.codebuddy/CODEBUDDY.md` | `.codebuddy/rules/{name}/RULE.mdc` | `@path` imports, auto-memory |
| 12 | **Trae** | `CLAUDE.md`, `.trae/rules/project_rules.md` | `.trae/rules/*.md` | Also `settings.json`, `mcp.json` |
| 13 | **TONGYI Lingma** | — | `.lingma/rules/*.md` | 10K char limit |
| 14 | **Augment Code** | `.augment/guidelines.md` | `.augment/rules/*.md` | Also reads AGENTS.md, CLAUDE.md |
| 15 | **Qoder/QCode** | `AGENTS.md` | `.qoder/rules/*` | 100K char total limit |
| 16 | **OpenClaw / ClawHub** | **`SKILL.md`** (主目标) | `scripts/`, `references/`, `assets/` (可选) | YAML frontmatter + Markdown body. `metadata.openclaw` / `metadata.clawdbot`. 发布到 ClawHub 需要 name, description. 50 MB bundle 限制, 默认 MIT-0 许可, slug 规则 `^[a-z0-9][a-z0-9-]*$`. |

---

## 架构：Canonical → 平台格式

同通用 SKILL.md 的 Canonical Format 架构。

### Agent Skills 开放标准

所有主流平台（Claude Code、Codex CLI、Cursor、Windsurf、WorkBuddy 等）均遵循 [agentskills.io](https://agentskills.io) 定义的 **Agent Skills 开放标准**，该标准规定：

| 字段 | 必需 | 类型 | 说明 |
|------|:----:|:----:|------|
| `name` | ✅ 必需 | string | kebab-case，最大 64 字符。必须匹配父目录名 |
| `description` | ✅ 必需 | string | 最大 1024 字符。描述 Skill 做什么和何时使用 |
| `license` | ❌ 可选 | string | 许可证名称或引用 |
| `compatibility` | ❌ 可选 | string | 环境要求（系统包、网络访问等） |
| `metadata` | ❌ 可选 | map | 任意键值映射（各平台可扩展） |
| `allowed-tools` | ❌ 可选 | string/list | 预批准的工具（实验性） |

各平台在该核心标准之上添加了**平台特定扩展**（详见下方兼容性矩阵）。

---

## Parser 规则（16 个平台）

完整解析规则同通用 SKILL.md 的 Phase 2 章节（包含 1–15），外加以下 OpenClaw Parser：

### OpenClaw / ClawHub Parser（新增）

**解析 SKILL.md 的 YAML frontmatter：**

| Frontmatter 字段 | Canonical 映射 | 备注 |
|-----------------|---------------|------|
| `name` | project.name | Skill 名称 |
| `description` | project.description | 用作 UI/搜索摘要 |
| `slug` | project.slug | URL 安全标识，小写 `^[a-z0-9][a-z0-9-]*$` |
| `version` | project.version | Semver 格式 |
| `homepage` | project.homepage | 项目主页 |
| `changelog` | project.changelog | 更新日志摘要 |
| `metadata.openclaw.emoji` | preferences.emoji | 显示 emoji |
| `metadata.openclaw.requires.env` | preferences.required_env_vars | **必须存在**的环境变量 |
| `metadata.openclaw.requires.bins` | preferences.required_bins | **全部**需要安装的二进制 |
| `metadata.openclaw.requires.anyBins` | preferences.any_bins | **至少一个**存在的二进制 |
| `metadata.openclaw.requires.config` | preferences.config_paths | Skill 读取的配置文件路径 |
| `metadata.openclaw.primaryEnv` | preferences.primary_env_var | 主要的凭证环境变量 |
| `metadata.openclaw.envVars` | preferences.env_vars_detail | 详细 env var 声明（含 `name`, `required`, `description`, `default`） |
| `metadata.openclaw.install` | commands.install_commands | 安装依赖规格（含 `kind`, `formula`/`package`, `bins`, `id`, `label`） |
| `metadata.openclaw.os` | boundaries.os_restrictions | 操作系统限制 |
| `metadata.openclaw.always` | preferences.always_active | 是否始终活跃（无需显式安装） |
| `metadata.openclaw.skillKey` | preferences.invocation_key | 调用键覆盖 |
| `metadata.openclaw.nix` | preferences.nix_spec | Nix 插件规格 |
| `metadata.openclaw.config` | preferences.config_spec | Clawdbot 配置规格 |
| `allowed-tools` | boundaries.allowed_tools | 允许使用的工具列表 |
| `license` | metadata.license | 许可证信息（ClawHub 发布时默认 MIT-0） |

**解析 Markdown body：**
- `##` headings → convention categories
- Code blocks → commands（如果是 bash 命令块，提取为安装/使用命令）
- `scripts/`, `references/`, `assets/` 引用文件 → scope_rules 或 memory
- `allowed-tools` → boundaries

**解析辅助文件：**
- `.clawhubignore` / `.gitignore`：记录发布时应排除的文件
- `scripts/` 目录：脚本文件列表 → commands 补充
- `references/` 目录：引用文档 → memory 条目

**注意事项：**
- `metadata` 可以是 YAML 对象格式，也可以是内联 JSON 字符串格式（两种均支持）
- 代码中引用的环境变量**必须**在 frontmatter 中声明（安全审查检查项）

---

## 平台生成器

### 1–15. 其他平台生成器

参考通用 SKILL.md 对应章节。

---

### 16. OpenClaw / ClawHub Generator（主目标 — 最详细）

**要创建的文件结构：**

```
SKILL.md                            # 核心：YAML frontmatter + Markdown body
scripts/                            # 可执行脚本（可选）
  {name}.py / {name}.sh
references/                         # 引用文档（可选）
  {topic}.md
assets/                             # 输出资源（可选）
  {template-files}
.clawhubignore                      # 发布排除规则（可选，语法同 .gitignore）
```

---

**最小 frontmatter 模板（本地开发，不发布）：**

```yaml
---
name: my-skill
description: "Short summary of what this skill does."
---
```

> `version` 在本地开发时可选，但发布到 ClawHub 时强烈推荐。

---

**完整 frontmatter 模板（发布到 ClawHub）：**

以下为官方规范支持的完整 frontmatter 字段：

```yaml
---
name: my-awesome-skill
slug: my-awesome-skill
description: "专为 X 用户设计的工具，功能包括 A、B、C。Use when 用户需要执行 X 相关的任务。"
version: 1.0.0
homepage: https://github.com/{user}/{repo}
changelog: "初始版本：支持核心 A 和 B 功能。"
metadata:
  openclaw:
    emoji: "🚀"
    requires:
      env:
        - API_KEY
      bins:
        - curl
      anyBins:
        - node
        - bun
      config:
        - ~/.config/my-skill/config.json
    primaryEnv: API_KEY
    envVars:
      - name: API_KEY
        required: true
        description: "API 密钥，用于认证请求。"
      - name: BASE_URL
        required: false
        description: "自定义 API 基础 URL。默认值: https://api.example.com"
    install:
      - id: brew-curl
        kind: brew
        formula: curl
        bins: [curl]
        label: "安装 curl (brew)"
    os:
      - linux
      - darwin
      - win32
    always: false
    skillKey: my-skill
---
```

> ⚠️ `metadata` 字段也支持内联 JSON 格式：
> ```yaml
> metadata: {"openclaw":{"emoji":"🚀","requires":{"bins":["curl"]}}}
> ```

---

**Markdown Body 模板：**

```markdown
# {skill-name}

{one-line description of what this skill does}

## Quick Start

```bash
{quick command example}
```

## Core Instructions

{详细的指令和步骤}

## Key Constraints

{重要约束和注意事项}

## Example

{使用示例}
```

> ⚠️ **不要在 body 中写"When to Use"章节** — frontmatter.description 才是触发机制，"When to Use" 信息不在 body 加载前可见。

---

**关键约束（ClawHub 发布规范）：**

| 规则 | 详情 |
|------|------|
| **必需 frontmatter** | `name`, `description`（`version` 强烈推荐） |
| **版本号** | Semver 格式（`1.0.0`, `1.2.3`）。每次发布创建新版本 |
| **Slug** | 默认由文件夹名派生。必须小写 URL 安全格式 `^[a-z0-9][a-z0-9-]*$`。如需覆盖，显式设置 `slug` |
| **许可证** | ClawHub 默认 **MIT-0**。不支持自定义许可证，不要添加冲突的许可条款 |
| **Bundle 大小** | 最大 **50 MB** |
| **文件类型** | 仅文本文件（JSON, YAML, TOML, JS, TS, Markdown, SVG 等）。扩展名允许列表在仓库 `packages/schema/src/textFiles.ts` 中定义。内容类型以 `text/` 开头的也被视为文本 |
| **文件数量** | SKILL.md + 最多约 **40 个非 `.md` 文件**（尽力而为的上限） |
| **付费** | 不支持付费 Skill、定价、付费墙或收入分成 |
| **第三方成本** | 如果集成付费第三方服务，需在指令中明确说明外部成本和所需账户 |
| **环境变量** | 代码中实际使用的 env var **必须**在 `requires.env`、`primaryEnv` 或 `envVars` 中声明。未声明会被安全审查标记为 **metadata 不匹配** |
| **安全审查** | ClawHub 自动检查 frontmatter 与实际代码的一致性 |
| **覆盖文件** | `.clawhubignore` 和 `.gitignore` 在发布/同步时均被遵守 |

---

## 迁移命令

### `migrate to openclaw` / `migrate to clawhub`

1. 检测项目中的所有 AI 记忆文件
2. 报告检测到的平台和文件
3. 解析所有文件到 Canonical 格式
4. 显示提取内容摘要
5. 询问用户以下信息：
   - Skill 名称（slug 默认 = 文件夹名）
   - Emoji（可选）
   - 所需二进制和环境变量（可选）
6. 生成 OpenClaw 格式的 SKILL.md
   - 如果用户打算发布到 ClawHub：生成完整 frontmatter
   - 如果仅本地使用：生成最小 frontmatter
7. 如果有脚本文件，生成 `scripts/` 目录并引用
8. 生成 `.clawhubignore`（如果项目有 `.gitignore`）
9. 报告创建的文件和警告

### `migrate from openclaw` / `migrate to {platform}`

1. 读取 SKILL.md 的 YAML frontmatter 和 body
2. 解析到 Canonical 格式（含所有 metadata.openclaw 字段）
3. 读取 `scripts/`, `references/`, `assets/` 中的内容（如有）
4. 生成目标平台的对应文件
5. 根据目标平台支持情况：
   - 如果目标平台支持 YAML frontmatter（如 Cursor `.mdc`），保留相关 frontmatter
   - 否则将 frontmatter 信息内联到 body 注释中

---

## 跨平台 Skill 格式对比

以下对比各平台创建/发布 Skill 的格式和机制：

| 平台 | Skill 目录 | SKILL.md 核心字段 | 平台独有字段 | 商店/市场 | 文件结构 |
|------|-----------|-------------------|-------------|-----------|---------|
| **OpenClaw/ClawHub** | `<project>/` 或 `skill-<name>/` | name, description, version | metadata.openclaw(requires/envVars/install/emoji/os) | ✅ **ClawHub** (clawhub.ai) | SKILL.md + scripts/ + references/ + assets/ |
| **Claude Code** | `.claude/skills/<name>/` | name, description | when_to_use, arguments, disable-model-invocation, user-invocable, allowed-tools, context(fork), model, effort, agent, hooks, paths, shell | ❌ 无中心市场（通过 Git/Plugin 分发） | SKILL.md + scripts/ + examples/ + templates/ |
| **OpenAI Codex CLI** | `~/.codex/skills/<name>/` | name, description | metadata(任意键值) | ❌ 无中心市场（OpenAI skills repo） | SKILL.md + scripts/ + templates/ |
| **Cursor** | `.cursor/skills/<name>/` 或 `.agents/skills/<name>/` | name, description | paths(作用域), disable-model-invocation | ❌ 无中心市场（通过 Git 安装） | SKILL.md + scripts/ + references/ + assets/ |
| **Windsurf** | `.windsurf/skills/<name>/` | name, description | 无（仅 core 字段） | ❌ 无中心市场 | SKILL.md + 支持文件 |
| **WorkBuddy** | `~/.workbuddy/skills/<name>/` | name, description | 无（仅 core 字段，但支持 @skill:// 调用） | ❌ 内置 Skill 商店 | SKILL.md（极简） |
| **Gemini CLI** | `~/.gemini/skills/` (推测) | name, description | — | ❌ | SKILL.md |
| **Trae** | `.trae/skills/<name>/` | name, description | — | ❌ | SKILL.md |
| **Cline** | `.clinerules/`（规则，非 Skill） | — | — | ❌ | 规则文件 |
| **Roo Code** | `.roo/rules/`（规则） | — | — | ❌ | 规则文件 |

### 关键发现

1. **所有平台都遵循同一个核心标准**（agentskills.io）：name + description 是唯二必需的
2. **唯一有商业化市场的平台是 OpenClaw/ClawHub**
3. **Claude Code 和 Cursor 扩展了最多平台特有字段**（如 context fork、paths 作用域）
4. **OpenClaw 是唯一有完整发布-分发-安装链的平台**
5. **Codex 和 Claude Code 在同一个目录层级中冲突** — `.claude/skills/` 和 `.codex/skills/` 互不干扰，Cursor/Windsurf 也兼容读取 `~/.claude/skills/`

---

## 平台兼容性矩阵

| Feature | Claude Code | Codex | Copilot | Cursor | Windsurf | Gemini | Aider | Cline | Roo | WorkBuddy | CodeBuddy | Trae | Lingma | Augment | Qoder | **OpenClaw** |
|---------|------------|-------|---------|--------|----------|--------|-------|-------|-----|-----------|-----------|------|--------|---------|-------|--------------|
| **主文件** | CLAUDE.md | AGENTS.md | copilot-instructions.md | AGENTS.md/.mdc | .windsurfrules | GEMINI.md | CONVENTIONS.md | .clinerules | .roorules | MEMORY.md | CODEBUDDY.md | project_rules.md | rules/*.md | guidelines.md | AGENTS.md | **SKILL.md (YAML FM)** |
| **Skill 目录** | .claude/skills/ | ~/.codex/skills/ | — | .cursor/skills/ | .windsurf/skills/ | — | — | — | — | ~/.workbuddy/skills/ | — | .trae/skills/ | — | — | — | **project root** |
| **Frontmatter** | paths | — | applyTo | globs+alwaysApply | trigger+globs | — | — | paths | — | — | alwaysApply+globs | — | — | type | — | **name/desc/version/metadata.openclaw** |
| **Skill FM 字段** | name, desc, when_to_use, arguments, disable-model, user-invocable, allowed-tools, model, effort, context, agent, hooks, paths, shell | name, desc, metadata | — | name, desc, paths, license, compatibility, metadata, disable-model-invocation | name, desc | — | — | — | — | name, desc | — | name, desc | — | — | — | **name, desc, version, slug, homepage, changelog, metadata.openclaw** |
| **环境声明** | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | **requires.env / envVars** |
| **依赖安装** | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | **install (brew/node/go/uv)** |
| **作用域** | paths | — | applyTo | paths | — | — | — | paths | — | — | paths | — | glob UI | — | — | — |
| **版本管理** | — | — | — | — | — | — | — | — | — | — | — | — | — | — | — | **Semver** |
| **Bundle 限制** | ~200 lines | 32KB total | — | — | 6K+12K chars | — | — | — | — | concise | 200 lines | — | 10K/file | — | 100K total | **50 MB** |
| **允许文件** | MD | MD | MD | MDC/MD | MD | MD | MD | MD | MD | MD | MD | MD | NL | MD | NL | **纯文本** |
| **商业市场** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | **✅ ClawHub** |

---

## 特殊处理

### 从其他平台迁移到 OpenClaw

| 源平台 | 映射方式 |
|--------|----------|
| **CLAUDE.md** | `##` headings → body `##` sections，内容摘要 → frontmatter description |
| **AGENTS.md** | `## Commands` → body 命令章节 |
| **Cursor `.mdc`** | `alwaysApply` → 保留为 body 指示；`globs` → 保留在 body 注释中 |
| **WorkBuddy MEMORY.md** | Sections → body sections；conventions → usage instructions |
| **CodeBuddy RULE.mdc** | frontmatter fields → 近似映射到 metadata.openclaw |
| **任何纯 Markdown 规则** | 检查是否包含 YAML frontmatter：有则解析，无则整文件 → body |

### 从 OpenClaw 迁移到其他平台

| 目标平台 | 映射方式 |
|----------|----------|
| **Claude Code** | frontmatter.description → CLAUDE.md 头部；body → CLAUDE.md body |
| **AGENTS.md** | body commands → `## Commands`；body instructions → `## Conventions` |
| **WorkBuddy MEMORY.md** | body sections → MEMORY.md sections；frontmatter.metadata 保留为注释 |
| **Cursor** | 如果有 scripts/ → 创建 Cursor 脚本规则 |
| **CodeBuddy** | frontmatter → CODEBUDDY.md；scripts/ → 保留在 references/ 中 |

### 跨平台 Skill 格式映射（基于 agentskills.io 标准）

所有主流平台都遵循 agentskills.io 核心标准，以下是 Skill 特有字段的跨平台映射：

| agentskills.io 核心 | Claude Code | Cursor | Windsurf | Codex CLI | WorkBuddy | OpenClaw |
|--------------------|-------------|--------|----------|-----------|-----------|----------|
| `name` | `name` | `name` | `name` | `name` | `name` | `name` |
| `description` | `description` | `description` | `description` | `description` | `description` | `description` |
| `license` | — | `license` | — | — | — | 隐含 MIT-0 |
| `compatibility` | — | `compatibility` | — | — | — | — |
| `metadata` (map) | — | `metadata` | — | `metadata` | — | `metadata.openclaw` |
| `allowed-tools` | `allowed-tools` | — | — | — | — | — |

**平台独有 Skill 字段迁移规则：**

| 源平台 | 字段 | 迁移到其他平台的方式 |
|--------|------|---------------------|
| Claude Code | `when_to_use` | 合并到 `description` 末尾 |
| Claude Code | `arguments` | 转为 body 中的注释说明 |
| Claude Code | `context: fork` + `agent` | 转为注释，其他平台不支持 fork 模式 |
| Claude Code | `disable-model-invocation` | Cursor 直接映射；其他平台转为注释 |
| Claude Code | `user-invocable` | 转为 body 注释 |
| Claude Code | `model` / `effort` | 转为 body 注释（其他平台不支持模型覆盖） |
| Claude Code | `hooks` | 转为 body 注释 |
| Cursor / Windsurf | `paths`（作用域） | 转为 body 注释 `<!-- Scoped to: {glob} -->` |
| OpenClaw | `metadata.openclaw.*` | 转为 body 注释 `<!-- Requires: env={...}, bins={...} -->` |
| OpenClaw | `install` specs | 转为 body 代码块（安装命令） |
| OpenClaw | `emoji` | 支持 emoji 的平台保留（CodeBuddy），否则去掉 |
| OpenClaw | `os` | 转为 body 注释 |
| Claude Code | `allowed-tools` | 转为 body 备注或去掉 |

### 处理 metadata 字段

**迁移到 OpenClaw 时：**
- 询问用户是否计划发布到 ClawHub
- 如果是，要求提供 `version`、`emoji`、`requires` 等字段
- 如果不是，生成最小 frontmatter（仅 name + description）
- `metadata` 使用 YAML 对象格式（更可读），可选提供内联 JSON 格式的示例

**从 OpenClaw 迁移时：**
- `requires.env` → 如果目标平台支持 env 声明，保留；否则添加注释
- `requires.bins` → 如果目标平台不支持，添加注释说明需要安装的二进制
- `install` specs → 转换为目标平台的原生命令
- `emoji` → 如果目标平台支持 emoji（CodeBuddy 等），保留；否则去掉
- `os` → 如果目标平台有 OS 限制，保留；否则去掉

### 处理 scripts/ 和引用文件

OpenClaw Skill 支持附属文件目录：
- **迁移到 OpenClaw**：检测源项目中的脚本文件，放入 `scripts/` 并在 body 中引用
- **从 OpenClaw 迁移**：根据目标平台决定处理方式
  - 目标平台支持脚本执行 → 保留为独立文件
  - 目标平台不支持 → 脚本内容内联到 body 中作为代码示例

### Bundle 大小管理

ClawHub 限制 50 MB。迁移到 OpenClaw 时：
- 统计生成的文件总大小
- 接近 50 MB 时建议拆分为多个 Skill 或精简资源
- 在迁移报告中标明 bundle 大小估算
- 非 `.md` 文件数量接近 40 时发出警告

### metadata 格式选择

生成时默认使用 YAML 对象格式（更可读、更易编辑）。
也可选择内联 JSON 格式（更紧凑），适用于 frontmatter 较长的场景。
解析器应同时支持 YAML 和 JSON 两种格式的 `metadata` 字段。

---

## 错误处理

同通用 SKILL.md，额外包括：

8. **缺少必需 frontmatter**：如果发布到 ClawHub，`name` 和 `description` 必须存在
9. **环境变量未声明**：body 中引用了 env var 但 frontmatter 未声明 → 添加警告并自动补充
10. **许可证冲突**：用户指定了非 MIT-0 许可证 → 警告 ClawHub 默认 MIT-0
11. **Bundle 超出限制**：> 50 MB → 建议拆分
12. **非文本文件**：尝试包含二进制文件 → 警告仅文本文件可发布
13. **Slug 格式错误**：文件夹名或 `slug` 字段不符合 `^[a-z0-9][a-z0-9-]*$` → 自动修正

---

## 最佳实践

同通用 SKILL.md，额外包括：

9. **保持 frontmatter 准确** — ClawHub 安全审查会交叉检查 frontmatter 与实际代码
10. **渐进式披露** — SKILL.md body 保持简洁（< 500 行），详细内容放到 `references/` 中
11. **SKILL.md 不包含"When to Use"** — frontmatter.description 才是触发机制
12. **依赖声明一致** — `requires.bins` 和 `install` 中的 binary 名称必须匹配
13. **准确声明环境变量** — 所有代码中使用的 env var 必须在 `requires.env` 或 `envVars` 中声明
14. **`metadata` 推荐 YAML 格式** — 更易读、更易版本控制。JSON 内联格式作为紧凑备选
15. **`install` 中的 `id` 和 `label`** — 用于 CLI 显示安装进度，推荐提供
