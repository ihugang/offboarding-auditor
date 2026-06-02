# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)（Semantic Versioning）。

## [0.0.1] - 2026-06-02

首版（initial release）。

### Added
- `SKILL.md`：离职/交接审计方法论 —— Phase 0–4 流程、10 个审计维度、严重度分级、可继承度评分（0–100）、报告模板、核心原则。
- `scripts/inventory.sh`：Phase 1 自动盘点脚本（bash + git，rg/fd 可选回退）。采集 Bus Factor、隐性知识信号、密钥与个人账号风险、未完成工作、依赖与测试清单。
- `references/example-report.md`：一份填好的样板审计报告。
- 双语 README（英文默认 + 简体中文，顶部语言互相切换）。
