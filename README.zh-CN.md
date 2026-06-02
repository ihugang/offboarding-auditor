[English](README.md) | **简体中文**

<p align="center">
  <img src="icon.png" alt="offboarding-auditor" width="160">
</p>

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
bash skills/offboarding-auditor/scripts/inventory.sh <目标仓库路径> > inventory.md
```

## 安装

本仓库**既是 Claude Code plugin,也是独立 skill**,挑一种用即可。

### 方式 A — Plugin（推荐，原生安装）

在 Claude Code 里：

```text
/plugin marketplace add ihugang/offboarding-auditor
/plugin install offboarding-auditor@ihugang-skills
```

带升级（`/plugin marketplace update`）和卸载管理。skill 由模型自动调用,也可显式调用 `/offboarding-auditor:offboarding-auditor`。

### 方式 B — 终端一键安装

装到 `~/.claude/skills/`（全局），需要 `git`：

```bash
curl -fsSL https://raw.githubusercontent.com/ihugang/offboarding-auditor/main/install.sh | bash
```

项目级安装（装到 `./.claude/skills/`）：

```bash
SCOPE=project bash -c "$(curl -fsSL https://raw.githubusercontent.com/ihugang/offboarding-auditor/main/install.sh)"
```

### 方式 C — 手动

一个 skill 就是一个含 `SKILL.md` 的文件夹,把它复制进你的 skills 目录：

```bash
git clone https://github.com/ihugang/offboarding-auditor.git
cp -R offboarding-auditor/skills/offboarding-auditor ~/.claude/skills/offboarding-auditor   # 全局
# 或：cp -R offboarding-auditor/skills/offboarding-auditor .claude/skills/offboarding-auditor  # 项目级
```

### 然后

**新开一个 Claude Code 会话**（skill/plugin 在会话启动时加载,不热更新），用自然语言触发——比如「对这个项目做离职/交接审计」「看下这个仓库的 bus factor」。

> 自包含：无需构建、无依赖。`scripts/inventory.sh` 需要 `bash` + `git`；`rg` / `fd` 可选（缺了自动回退 `grep` / `find`）。

## 结构

```text
.
├── .claude-plugin/
│   ├── plugin.json                          # Plugin 清单
│   └── marketplace.json                     # Marketplace 目录（本仓库 = 单 plugin 的 marketplace）
├── install.sh                               # 终端一键安装脚本
└── skills/offboarding-auditor/
    ├── SKILL.md                             # 主指令：方法论、10 维度、评分、中英报告模板
    ├── scripts/inventory.sh                 # Phase 1 自动盘点（bash + git；rg/fd 可选）
    └── references/
        ├── example-report.zh.md             # 样板报告（中文）
        └── example-report.en.md             # 样板报告（英文）
```

## 许可证

MIT
