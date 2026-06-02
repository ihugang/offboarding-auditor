# offboarding-auditor

> A Claude Code skill that audits a departing engineer's code & docs to make sure the project can actually be **inherited** by whoever takes over.

当程序员**离职 / 转岗 / 外包到期**时，本 skill 审计其负责的代码与文档，回答一个问题：

> **换一个完全不认识原作者的新人来接手，他能不能在不打电话问原作者的前提下，把这件事独立干完？**

不是评判代码「写得好不好」，而是评估「**能不能被别人继承**」。核心是抢救 **Bus Factor**——别让关键知识随人一起走掉。

## 它做什么

- **Phase 1 盘点**：`scripts/inventory.sh` 一键扫出客观信号——作者集中度（知识孤岛）、隐性知识标记、密钥与个人账号绑定风险、未完成工作、依赖与测试清单。
- **Phase 2 审计**：按 10 个维度逐项核查，每条结论都挂证据（文件/行号 或 缺失的事实）。
- **Phase 3 评分**：严重度分级（🔴 阻断 / 🟠 高 / 🟡 中 / ⚪ 低）+ 可继承度评分（0–100）+ 「能否安全交接」判定。
- **Phase 4 产出**：审计报告 + **离职前待补清单**（趁人还在，列出具体、可分配的补救项）。

## 用法

在 Claude Code 中触发（离职审计 / handover audit / bus factor 等），或手动跑盘点脚本：

```bash
bash scripts/inventory.sh <目标仓库路径> > inventory.md
```

## 结构

```
.
├── SKILL.md                   # 主指令：方法论、10 维度、评分、报告模板
├── scripts/inventory.sh       # Phase 1 自动盘点（bash + git；rg/fd 可选）
└── references/example-report.md  # 一份填好的样板审计报告
```

## 安装为 Claude Code skill

把本仓库放到 Claude 的 skills 目录下即可（目录名建议与 `SKILL.md` 中的 `name: offboarding-auditor` 一致）。
