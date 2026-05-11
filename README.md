# AI Mind Migrate

> **跨平台 AI 上下文迁移工具** — 在 16 个 AI 编码助手之间无缝迁移项目规则、记忆和上下文。
>
> **Cross-platform AI context migration tool** — Seamlessly migrate project rules, memory, and context across 16 AI coding assistants.

[English](#english) | [中文](#中文) | [繁體中文](#繁體中文) | [日本語](#日本語) | [한국어](#한국어)

---

## 🌟 核心亮点 | Key Features

- **16 平台支持** | **16 Platforms**: Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Gemini CLI, Aider, Cline, Roo Code, WorkBuddy, CodeBuddy, Trae, TONGYI Lingma, Augment Code, Qoder, OpenClaw/ClawHub
- **双向迁移** | **Bidirectional**: 任意平台 ←→ 任意平台互转
- **Canonical 中间格式** | **Canonical Format**: 统一的 YAML 内部表示作为唯一真相源
- **独立 SKILL.md** | **Standalone SKILL.md**: 每个平台一个独立的 ClawHub 可发布 SKILL
- **规则类型映射** | **Rule Type Mapping**: Always Apply / Scoped / Agent-Decided / Manual 四类规则自动转换
- **字符限制处理** | **Character Limit Handling**: 自动拆分/截断，适配各平台限制

---

## 📦 文件结构 | Structure

```
ai-mind-migrate/
├── SKILL.md                    # 主 Skill — 通用迁移引擎
├── PLATFORM_REFERENCE.md       # 16 平台格式速查卡
├── migrate.sh                  # CLI 迁移脚本
└── skills-for-store/           # 16 个独立 Skill（每个可单独上传 ClawHub）
    ├── openclaw/ai-mind-migrate-openclaw/
    │   ├── SKILL.md            # OpenClaw 迁移 Skill
    │   ├── migrate.sh          # CLI 脚本
    │   └── PLATFORM_REFERENCE.md
    ├── claude-code/ai-mind-migrate-claude-code/
    ├── cursor/ai-mind-migrate-cursor/
    ├── windsurf/ai-mind-migrate-windsurf/
    ├── workbuddy/ai-mind-migrate-workbuddy/
    ├── codebuddy/ai-mind-migrate-codebuddy/
    ├── codex-copilot/ai-mind-migrate-codex-copilot/
    ├── gemini-cli/ai-mind-migrate-gemini-cli/
    ├── aider/ai-mind-migrate-aider/
    ├── cline/ai-mind-migrate-cline/
    ├── roo-code/ai-mind-migrate-roo-code/
    ├── trae/ai-mind-migrate-trae/
    ├── lingma/ai-mind-migrate-lingma/
    ├── augment-code/ai-mind-migrate-augment-code/
    └── qoder/ai-mind-migrate-qoder/
```

---

## 🚀 快速开始 | Quick Start

### 在 Claude Code 中使用

1. 将 `skills-for-store/skill-claude-code/` 复制到你的项目 `.claude/skills/` 目录
2. 在 Claude Code 中输入 `/ai-mind-migrate-claude-code` 或描述你的迁移需求
3. AI 会自动检测项目中的现有配置文件并引导迁移

### 在 WorkBuddy 中使用

1. 将 `skills-for-store/skill-workbuddy/` 复制到 `~/.workbuddy/skills/` 目录
2. 在 WorkBuddy 中输入 `@skill://ai-mind-migrate-workbuddy` 触发
3. 或直接描述你的迁移需求，WorkBuddy 会自动调用

### 在 Cursor 中使用

1. 将 `skills-for-store/skill-cursor/` 复制到 `.cursor/skills/` 目录
2. 在 Cursor Agent 中描述迁移需求即可自动触发

### 在 OpenClaw / ClawHub 中使用

1. 从 ClawHub 安装对应的 Skill，或直接克隆本仓库
2. 将对应平台的 skill 目录放入你的项目
3. 使用 `@skill://` 或 `/skill-name` 激活

---

## 🛠 支持的平台 | Supported Platforms

| # | Platform | 主文件 | Skill 存储路径 | 独有字段 |
|---|----------|--------|--------------|---------|
| 1 | **Claude Code** | CLAUDE.md / .claude/CLAUDE.md | .claude/skills/ | when_to_use, arguments, context(fork), disable-model-invocation |
| 2 | **OpenAI Codex** | AGENTS.md | ~/.codex/skills/ | metadata (任意 map) |
| 3 | **GitHub Copilot** | .github/copilot-instructions.md | .github/instructions/ | applyTo frontmatter |
| 4 | **Cursor** | AGENTS.md / .cursor/rules/*.mdc | .cursor/skills/ | paths, disable-model-invocation |
| 5 | **Windsurf** | .windsurfrules (旧) / .windsurf/rules/*.md | .windsurf/skills/ | 无（仅 core） |
| 6 | **Gemini CLI** | GEMINI.md | — | @file.md imports |
| 7 | **Aider** | CONVENTIONS.md | — | 需 --read |
| 8 | **Cline** | .clinerules / .clinerules/*.md | — | paths (仅) |
| 9 | **Roo Code** | .roorules (旧) / .roo/rules/*.md | — | mode-specific rules |
| 10 | **WorkBuddy** | .workbuddy/memory/MEMORY.md | ~/.workbuddy/skills/ | 无（agentskills.io） |
| 11 | **CodeBuddy** | CODEBUDDY.md / .codebuddy/CODEBUDDY.md | — | @path imports, 3 loading types |
| 12 | **Trae** | CLAUDE.md / .trae/rules/project_rules.md | .trae/skills/ | 多层规则优先级 |
| 13 | **TONGYI Lingma** | — / .lingma/rules/*.md | — | 4规则类型（IDE UI） |
| 14 | **Augment Code** | .augment/guidelines.md / .augment/rules/*.md | — | type (always_apply/agent_requested) |
| 15 | **Qoder/QCode** | AGENTS.md / .qoder/rules/* | — | 100K char total limit |
| 16 | **OpenClaw/ClawHub** | SKILL.md (YAML FM) | <project>/ | metadata.openclaw, version, slug |

---

## 📖 迁移模式 | Migration Modes

### 自动检测 + 转换
```
源平台 (CLAUDE.md) → 解析 Canonical 格式 → 生成目标平台 (.cursor/rules/*.mdc)
```

### 命令式 (migrate.sh)
```bash
bash migrate.sh detect              # 扫描项目中的 AI 配置文件
bash migrate.sh migrate cursor      # 迁移到 Cursor 格式
bash migrate.sh migrate claude-code # 迁移到 Claude Code 格式
bash migrate.sh export-canonical    # 导出 Canonical 快照
```

### Canonical 中间格式
所有转换通过统一的 YAML 中间格式完成，支持 15+ 种字段类型：
`project`, `commands`, `structure`, `conventions`, `boundaries`, `preferences`, `decisions`, `scope_rules`, `memory`

---

## 📜 许可证 | License

MIT-0 — 自由使用、修改和再分发。

---

## 🤝 贡献 | Contributing

PR、Issues 和 Feature Requests 欢迎提交！

---

## 🌐 跨平台 Skill 标准 | Cross-Platform Skill Standard

所有平台均遵循 [agentskills.io](https://agentskills.io) 开放标准：
- **必需**: `name` + `description`
- **可选**: `license`, `compatibility`, `metadata`, `allowed-tools`
- **平台扩展**: 各平台在此基础上添加独有字段

---

<a id="english"></a>

## English

**AI Mind Migrate** is a cross-platform tool for migrating your project context, rules, and memory between AI coding assistants. It supports 16 platforms through a unified canonical format.

**Use cases:**
- **Switch tools**: Migrate from Cursor to Claude Code without losing your project rules
- **Sync between tools**: Keep consistent rules across multiple AI coding assistants
- **Team onboarding**: Initialize a new AI tool with your team's established conventions
- **Cross-tool collaboration**: Share context between team members using different tools

**How to install:**
- **Claude Code**: Copy `skills-for-store/claude-code/ai-mind-migrate-claude-code/` to `.claude/skills/`
- **WorkBuddy**: Copy `skills-for-store/workbuddy/ai-mind-migrate-workbuddy/` to `~/.workbuddy/skills/`
- **Cursor**: Copy `skills-for-store/cursor/ai-mind-migrate-cursor/` to `.cursor/skills/`
- **Others**: Copy the relevant skill folder to the platform's skills directory

---

<a id="繁體中文"></a>

## 繁體中文



**AI Mind Migrate** 是一個跨平台的 AI 上下文遷移工具，支援 16 個編碼助手平台之間的規則與記憶雙向遷移。

**使用方式：**
- 將對應平台的 skill 資料夾複製到該平台的技能目錄
- 使用 `/skill-name` 或 `@skill://` 觸發遷移
- AI 會自動偵測現有配置並引導轉換

---

<a id="日本語"></a>

## 日本語

**AI Mind Migrate** は、16 の AI コーディングアシスタント間でプロジェクトのルール、メモリ、コンテキストをシームレスに移行するためのクロスプラットフォームツールです。

**使用方法：**
- 対応するプラットフォームの skill フォルダーをそのプラットフォームの skill ディレクトリにコピー
- `/skill-name` または `@skill://` で移行をトリガー
- AI が既存の設定を自動検出して変換をガイド

---

<a id="한국어"></a>

## 한국어

**AI Mind Migrate**는 16개의 AI 코딩 어시스턴트 간에 프로젝트 규칙, 메모리 및 컨텍스트를 원활하게 마이그레이션하기 위한 크로스 플랫폼 도구입니다.

**사용 방법：**
- 해당 플랫폼의 skill 폴더를 해당 플랫폼의 skill 디렉토리에 복사
- `/skill-name` 또는 `@skill://`로 마이그레이션 트리거
- AI가 기존 설정을 자동 감지하여 변환 안내

---

## ⚡ 支持 | Support

- **GitHub Issues**: https://github.com/deveuper/ai-mind-migrate/issues
- **ClawHub**: https://clawhub.ai

---

*Made with 🦞 by deveuper*
