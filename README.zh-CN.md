[English](README.md) | **简体中文**

# offboarding-auditor

> 一个 Claude Code skill：审计离职程序员的代码与文档，确保项目能真正被接手人「继承」。

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
├── SKILL.md                         # 主指令：方法论、10 维度、评分、中英报告模板
├── scripts/inventory.sh             # Phase 1 自动盘点（bash + git；rg/fd 可选）
└── references/
    ├── example-report.zh.md         # 样板报告（中文）
    └── example-report.en.md         # 样板报告（英文）
```

## 安装为 Claude Code skill

一个 skill 就是一个含有 `SKILL.md` 的文件夹，文件夹名要与 frontmatter 里的 `name: offboarding-auditor` 一致。可以装成**全局**（所有项目可用）或**项目级**。

### 方式 A — 全局（所有项目）

```bash
git clone https://github.com/ihugang/offboarding-auditor.git \
  ~/.claude/skills/offboarding-auditor
```

或者本地已有仓库，复制 / 软链接过去：

```bash
# 复制
cp -R ./offboarding-auditor ~/.claude/skills/offboarding-auditor

# 或软链接（改源码即时生效；需保证源码路径始终挂载可用）
ln -s "$(pwd)/offboarding-auditor" ~/.claude/skills/offboarding-auditor
```

### 方式 B — 项目级（仅当前仓库）

```bash
git clone https://github.com/ihugang/offboarding-auditor.git \
  .claude/skills/offboarding-auditor
```

### 验证与使用

```bash
# 文件夹顶层应有 SKILL.md
ls ~/.claude/skills/offboarding-auditor/SKILL.md
```

然后**新开一个 Claude Code 会话**（skill 在会话启动时加载，不热更新），用自然语言触发——比如「对这个项目做离职/交接审计」「看下这个仓库的 bus factor」，或直接 `/offboarding-auditor`。

> 本 skill 自包含：无需构建、无依赖。`scripts/inventory.sh` 需要 `bash` + `git`；`rg` / `fd` 可选（缺了自动回退 `grep` / `find`）。

## 许可证

MIT
