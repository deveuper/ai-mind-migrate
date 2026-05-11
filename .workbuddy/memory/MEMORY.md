# AI Mind Migrate 项目 — 长期记忆

## 项目概要
AI Mind Migrate：跨平台 AI 上下文迁移工具，支持 16 个编码助手平台之间的规则/记忆双向迁移。

## 核心文件
- `SKILL.md` — 通用主 Skill（1250 行），定义 Canonical 格式 + 15 个平台解析器 + 15 个生成器
- `PLATFORM_REFERENCE.md` — 16 平台格式速查卡（文件路径、frontmatter 格式、激活模式映射、字符限制）
- `migrate.sh` — 自动化迁移脚本（355 行），扫描 + 解析 + 生成流程
- `skills-for-store/` — 16 个独立 SKILL.md 目录（3306 行总）

## 关键架构决策

### Canonical 中间格式
使用统一的 YAML 内部格式作为唯一真相源，所有平台通过 Parse → Canonical → Generate 流程转换。

### 独立 SKILL.md 设计
每个平台一个独立 SKILL.md，采用宿主平台视角：
- 标题/描述/关键词针对该平台优化
- 主目标 Generator 最详细
- 保留全部 16 个 Parser（支持双向迁移）
- 包含跨平台字段映射表

## 已验证的官方格式

### 核心标准（agentskills.io）
所有平台都遵循：name + description 为唯二必需字段。可选：license, compatibility, metadata, allowed-tools。

### 平台特有字段

| 平台 | 独有字段 | 存储路径 |
|------|---------|---------|
| Claude Code | when_to_use, arguments, disable-model-invocation, context(fork), agent, hooks, paths, shell | .claude/skills/<name>/ |
| Cursor | paths, disable-model-invocation | .cursor/skills/<name>/ |
| Windsurf | 无（仅 core） | .windsurf/skills/<name>/ |
| WorkBuddy | 无（仅 core + @skill://） | ~/.workbuddy/skills/<name>/ |
| Codex CLI | metadata（任意 key-value） | ~/.codex/skills/<name>/ |
| OpenClaw/ClawHub | metadata.openclaw (requires/envVars/install/emoji/os) | <project>/ |

### 关键发现
- OpenClaw/ClawHub 是唯一有商业市场的平台
- WrokBuddy 格式最简单（就是 agentskills.io 标准）
- Claude Code 扩展了最多平台特有字段
- Cursor/Windsurf 兼容读取 `~/.claude/skills/` 和 `~/.agents/skills/`

## 已完成工作
- 生成 16 个独立 SKILL.md（全部通过 ClawHub 可发布格式）
- 添加完整 YAML frontmatter（name, slug, description, version, homepage, metadata.openclaw）
- 修复 OpenClaw 格式：去掉 category/license 冗余字段、修正 install 规格（加 id/label）
- 补充跨平台 Skill 字段映射表
- 搜索并验证了各平台官方文档
