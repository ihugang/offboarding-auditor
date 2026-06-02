# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)（Semantic Versioning）。

## [0.2.0] - 2026-06-02

### Added
- **Plugin / Marketplace 支持**：仓库现同时是一个 Claude Code plugin + marketplace，可用 `/plugin marketplace add ihugang/offboarding-auditor` + `/plugin install offboarding-auditor@ihugang-skills` 原生安装。新增 `.claude-plugin/plugin.json` 与 `.claude-plugin/marketplace.json`。
- **`install.sh`**：终端一键安装（`curl … | bash`），支持 `SCOPE=project` 项目级安装。
- README 顶部加入项目图标 `icon.png`，安装说明重写为 Plugin / 脚本 / 手动 三种方式。

### Changed
- **目录重构为官方 plugin 布局**：skill 内容从仓库根目录移入 `skills/offboarding-auditor/`（含 `SKILL.md`、`scripts/`、`references/`）。

## [0.1.0] - 2026-06-02

### Added
- 报告支持**中英双语**：Phase 0 新增「报告语言」确认项，最终报告语言由用户开始前的选择决定（不指定时跟随对话语言）。
- SKILL.md 报告模板拆为【中文模板】+【English template】两套。
- 新增 `references/example-report.en.md`（英文样板报告）。

### Changed
- `references/example-report.md` 重命名为 `references/example-report.zh.md`（与英文版命名对齐）。

## [0.0.1] - 2026-06-02

首版（initial release）。

### Added
- `SKILL.md`：离职/交接审计方法论 —— Phase 0–4 流程、10 个审计维度、严重度分级、可继承度评分（0–100）、报告模板、核心原则。
- `scripts/inventory.sh`：Phase 1 自动盘点脚本（bash + git，rg/fd 可选回退）。采集 Bus Factor、隐性知识信号、密钥与个人账号风险、未完成工作、依赖与测试清单。
- `references/example-report.md`：一份填好的样板审计报告。
- 双语 README（英文默认 + 简体中文，顶部语言互相切换）。
