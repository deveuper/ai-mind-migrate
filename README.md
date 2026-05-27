# AI Mind Migrate

> **Cross-platform AI context migration tool** — Seamlessly migrate project rules, memory, and context across 16 AI coding assistants.
>
> **跨平台 AI 上下文迁移工具** — 在 16 个 AI 编码助手之间无缝迁移项目规则、记忆和上下文。

[English](#english) | [中文](#中文) | [繁體中文](#繁體中文) | [日本語](#日本語) | [한국어](#한국어)

---

## Key Features

- **16 Platforms Supported**: Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Gemini CLI, Aider, Cline, Roo Code, WorkBuddy, CodeBuddy, Trae, TONGYI Lingma, Augment Code, Qoder, OpenClaw/ClawHub
- **Bidirectional Migration**: Any platform → any other platform, both directions
- **Canonical Format**: Unified YAML internal representation as the single source of truth
- **Standalone SKILL.md**: Each platform has its own independent, ClawHub-publishable SKILL
- **Rule Type Mapping**: Always Apply / Scoped / Agent-Decided / Manual — automatic conversion
- **Character Limit Handling**: Auto-split/truncate to match each platform's constraints

---

## Project Structure

```
ai-mind-migrate/
├── SKILL.md                    # Master Skill — universal migration engine
├── PLATFORM_REFERENCE.md       # 16-platform format cheat sheet
├── migrate.sh                  # CLI migration script
└── skills-for-store/           # 16 standalone Skills (each self-contained)
    ├── openclaw/ai-mind-migrate-openclaw/
    │   ├── SKILL.md
    │   ├── migrate.sh
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

Each folder under `skills-for-store/{platform}/ai-mind-migrate-{platform}/` is completely self-contained and can be used independently. Upload any of these folders to a skill marketplace or copy to the platform's skill directory.

---

## Quick Start

### Using with Claude Code
1. Copy `skills-for-store/claude-code/ai-mind-migrate-claude-code/` to your project's `.claude/skills/` directory
2. In Claude Code, type `/ai-mind-migrate-claude-code` or describe your migration needs
3. The AI will automatically detect existing config files and guide the migration

### Using with WorkBuddy
1. Copy `skills-for-store/workbuddy/ai-mind-migrate-workbuddy/` to `~/.workbuddy/skills/`
2. Trigger with `@skill://ai-mind-migrate-workbuddy` in WorkBuddy
3. Or just describe your migration needs — WorkBuddy auto-invokes the skill

### Using with Cursor
1. Copy `skills-for-store/cursor/ai-mind-migrate-cursor/` to `.cursor/skills/`
2. Describe your migration needs in Cursor Agent — it triggers automatically

### Using with OpenClaw
1. Install from ClawHub or clone this repository
2. Copy the relevant platform skill folder to your project
3. Activate with `@skill://` or `/skill-name`

### CLI Usage (migrate.sh)
```bash
bash migrate.sh detect              # Scan project for AI config files
bash migrate.sh migrate cursor      # Migrate to Cursor format
bash migrate.sh migrate claude-code # Migrate to Claude Code format
bash migrate.sh export-canonical    # Export canonical YAML snapshot
```

---

## Supported Platforms

| # | Platform | Primary File(s) | Skill Directory | Unique Fields |
|---|----------|----------------|-----------------|---------------|
| 1 | **Claude Code** | CLAUDE.md / .claude/CLAUDE.md | .claude/skills/ | when_to_use, arguments, context(fork), disable-model-invocation |
| 2 | **OpenAI Codex** | AGENTS.md | ~/.codex/skills/ | metadata (arbitrary map) |
| 3 | **GitHub Copilot** | .github/copilot-instructions.md | .github/instructions/ | applyTo frontmatter |
| 4 | **Cursor** | AGENTS.md / .cursor/rules/*.mdc | .cursor/skills/ | paths, disable-model-invocation |
| 5 | **Windsurf** | .windsurfrules (legacy) / .windsurf/rules/*.md | .windsurf/skills/ | None (core only) |
| 6 | **Gemini CLI** | GEMINI.md | — | @file.md imports |
| 7 | **Aider** | CONVENTIONS.md | — | Requires --read |
| 8 | **Cline** | .clinerules / .clinerules/*.md | — | paths (only) |
| 9 | **Roo Code** | .roorules (legacy) / .roo/rules/*.md | — | mode-specific rules |
| 10 | **WorkBuddy** | .workbuddy/memory/MEMORY.md | ~/.workbuddy/skills/ | None (agentskills.io) |
| 11 | **CodeBuddy** | CODEBUDDY.md / .codebuddy/CODEBUDDY.md | — | @path imports, 3 loading types |
| 12 | **Trae** | CLAUDE.md / .trae/rules/project_rules.md | .trae/skills/ | Multi-level rule priority |
| 13 | **TONGYI Lingma** | — / .lingma/rules/*.md | — | 4 rule types (IDE UI) |
| 14 | **Augment Code** | .augment/guidelines.md / .augment/rules/*.md | — | type (always_apply/agent_requested) |
| 15 | **Qoder/QCode** | AGENTS.md / .qoder/rules/* | — | 100K char total limit |
| 16 | **OpenClaw/ClawHub** | SKILL.md (YAML FM) | <project>/ | metadata.openclaw, version, slug |

---

## Migration Modes

### Auto-detect + Convert
```
Source Platform (CLAUDE.md) → Parse Canonical Format → Generate Target (.cursor/rules/*.mdc)
```

### Canonical Intermediate Format
All conversions go through a unified YAML intermediate format supporting 15+ field types:
`project`, `commands`, `structure`, `conventions`, `boundaries`, `preferences`, `decisions`, `scope_rules`, `memory`

### Cross-platform Rule Type Mapping
| Source Type | → Always | → Scoped | → Agent-Decided | → Manual |
|-------------|----------|----------|-----------------|----------|
| Always | Direct | Add glob paths | Change type | Change type |
| Scoped | Remove paths | Direct | Keep paths | Keep paths |
| Agent-Decided | Set alwaysApply | Set alwaysApply:false+paths | Direct | Remove description |
| Manual | Set alwaysApply | Set alwaysApply:false+paths | Add description | Direct |

---

## Cross-platform Skill Standard

All platforms follow the [agentskills.io](https://agentskills.io) open standard:
- **Required**: `name` + `description`
- **Optional**: `license`, `compatibility`, `metadata`, `allowed-tools`
- **Platform Extensions**: Each platform adds unique fields on top of this standard

---

## License

MIT-0 — Free to use, modify, and redistribute.

---

## Contributing

PRs, Issues, and Feature Requests are welcome!

---

## Support

- **GitHub Issues**: https://github.com/deveuper/ai-mind-migrate/issues

---

*Made with 🦞 by deveuper*

---

<a id="中文"></a>

# 中文

## AI Mind Migrate

**跨平台 AI 上下文迁移工具** — 在 16 个 AI 编码助手之间无缝迁移项目规则、记忆和上下文。

### 主要特点

- **16 平台支持**：Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Gemini CLI, Aider, Cline, Roo Code, WorkBuddy, CodeBuddy, Trae, TONGYI Lingma, Augment Code, Qoder, OpenClaw/ClawHub
- **双向迁移**：任意平台 ←→ 任意平台互转
- **Canonical 中间格式**：统一的 YAML 内部表示作为唯一真相源
- **独立 SKILL.md**：每个平台一个独立的自包含 SKILL
- **规则类型映射**：Always Apply / Scoped / Agent-Decided / Manual 四类规则自动转换

### 各平台使用

**Claude Code**: 复制 `skills-for-store/claude-code/ai-mind-migrate-claude-code/` 到 `.claude/skills/`，使用 `/ai-mind-migrate-claude-code` 触发。

**WorkBuddy**: 复制 `skills-for-store/workbuddy/ai-mind-migrate-workbuddy/` 到 `~/.workbuddy/skills/`，使用 `@skill://ai-mind-migrate-workbuddy` 触发。

**Cursor**: 复制 `skills-for-store/cursor/ai-mind-migrate-cursor/` 到 `.cursor/skills/`，描述迁移需求即可自动触发。

**CLI**: `bash migrate.sh detect` 扫描项目配置，`bash migrate.sh migrate cursor` 迁移到指定格式。

### 项目结构

```
ai-mind-migrate/
├── SKILL.md                    # 主 Skill
├── PLATFORM_REFERENCE.md       # 平台格式速查
├── migrate.sh                  # CLI 脚本
└── skills-for-store/           # 16 个独立 Skill
    ├── openclaw/ai-mind-migrate-openclaw/
    ├── claude-code/ai-mind-migrate-claude-code/
    ├── cursor/ai-mind-migrate-cursor/
    └── ...
```

每个 `skills-for-store/{平台}/ai-mind-migrate-{平台}/` 文件夹都是自包含的，可直接使用。

---

<a id="繁體中文"></a>

# 繁體中文

## AI Mind Migrate

**跨平台 AI 上下文遷移工具** — 支援 16 個編碼助手平台之間的規則與記憶雙向遷移。

### 主要特點

- **16 平台支援**：Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Gemini CLI, Aider, Cline, Roo Code, WorkBuddy, CodeBuddy, Trae, TONGYI Lingma, Augment Code, Qoder, OpenClaw/ClawHub
- **雙向遷移**：任意平台 ←→ 任意平台互轉
- **獨立 SKILL.md**：每個平台一個獨立的自包含 SKILL

### 使用方式

**Claude Code**：將 `skills-for-store/claude-code/ai-mind-migrate-claude-code/` 複製到 `.claude/skills/`，使用 `/ai-mind-migrate-claude-code` 觸發。

**WorkBuddy**：將 `skills-for-store/workbuddy/ai-mind-migrate-workbuddy/` 複製到 `~/.workbuddy/skills/`，使用 `@skill://ai-mind-migrate-workbuddy` 觸發。

**Cursor**：將 `skills-for-store/cursor/ai-mind-migrate-cursor/` 複製到 `.cursor/skills/`，描述遷移需求即可。

---

<a id="日本語"></a>

# 日本語

## AI Mind Migrate

**16 の AI コーディングアシスタント間でプロジェクトのルール、メモリ、コンテキストをシームレスに移行するクロスプラットフォームツール。**

### 主な特徴

- **16 プラットフォーム対応**：Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Gemini CLI, Aider, Cline, Roo Code, WorkBuddy, CodeBuddy, Trae, TONGYI Lingma, Augment Code, Qoder, OpenClaw/ClawHub
- **双方向移行**：任意のプラットフォーム間で相互変換
- **スタンドアロン SKILL.md**：各プラットフォームに独立した SKILL

### 使用方法

**Claude Code**：`skills-for-store/claude-code/ai-mind-migrate-claude-code/` を `.claude/skills/` にコピーし、`/ai-mind-migrate-claude-code` で起動。

**WorkBuddy**：`skills-for-store/workbuddy/ai-mind-migrate-workbuddy/` を `~/.workbuddy/skills/` にコピーし、`@skill://ai-mind-migrate-workbuddy` で起動。

**Cursor**：`skills-for-store/cursor/ai-mind-migrate-cursor/` を `.cursor/skills/` にコピー。

---

<a id="한국어"></a>

# 한국어

## AI Mind Migrate

**16개의 AI 코딩 어시스턴트 간에 프로젝트 규칙, 메모리 및 컨텍스트를 원활하게 마이그레이션하는 크로스 플랫폼 도구입니다.**

### 주요 기능

- **16개 플랫폼 지원**: Claude Code, OpenAI Codex, GitHub Copilot, Cursor, Windsurf, Gemini CLI, Aider, Cline, Roo Code, WorkBuddy, CodeBuddy, Trae, TONGYI Lingma, Augment Code, Qoder, OpenClaw/ClawHub
- **양방향 마이그레이션**: 모든 플랫폼 간 상호 변환
- **독립형 SKILL.md**: 각 플랫폼에 독립적인 SKILL

### 사용 방법

**Claude Code**: `skills-for-store/claude-code/ai-mind-migrate-claude-code/`를 `.claude/skills/`에 복사하고 `/ai-mind-migrate-claude-code`로 실행합니다.

**WorkBuddy**: `skills-for-store/workbuddy/ai-mind-migrate-workbuddy/`를 `~/.workbuddy/skills/`에 복사하고 `@skill://ai-mind-migrate-workbuddy`로 실행합니다.

**Cursor**: `skills-for-store/cursor/ai-mind-migrate-cursor/`를 `.cursor/skills/`에 복사합니다.
