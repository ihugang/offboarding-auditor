#!/usr/bin/env bash
#
# inventory.sh — 项目继承审计 Phase 1 自动盘点
#
# 用途：在交接审计前，一键扫出「随人流失风险」的客观信号，给 Phase 2 逐维度审计当原料。
# 它只采集事实、不下结论——判断交给 Claude（结合接手人视角与证据）。
#
# 用法：
#   bash scripts/inventory.sh [目标目录]        # 默认当前目录
#   bash scripts/inventory.sh /path/to/repo > inventory.md
#
# 依赖：bash + git；rg/fd 可选（缺了自动回退到 grep/find）。

set -uo pipefail

TARGET="${1:-.}"
cd "$TARGET" 2>/dev/null || { echo "❌ 无法进入目录: $TARGET"; exit 1; }
ROOT="$(pwd)"

# ---- 工具探测（缺啥回退啥）-------------------------------------------------
if command -v rg >/dev/null 2>&1; then SEARCH="rg"; else SEARCH="grep"; fi
HAS_GIT=0; git rev-parse --is-inside-work-tree >/dev/null 2>&1 && HAS_GIT=1

hr() { printf '\n%s\n' "------------------------------------------------------------"; }
h2() { printf '\n## %s\n\n' "$1"; }

# rg/grep 统一计数封装（递归、忽略大小写、统计匹配行数）
count_matches() { # $1=pattern
  if [ "$SEARCH" = "rg" ]; then
    rg -i --no-messages -c "$1" 2>/dev/null | awk -F: '{s+=$NF} END{print s+0}'
  else
    grep -rIi --exclude-dir=.git -c "$1" . 2>/dev/null | awk -F: '{s+=$NF} END{print s+0}'
  fi
}
list_matches() { # $1=pattern  $2=max lines
  if [ "$SEARCH" = "rg" ]; then
    rg -i --no-messages -n "$1" 2>/dev/null | head -n "${2:-20}"
  else
    grep -rIin --exclude-dir=.git "$1" . 2>/dev/null | head -n "${2:-20}"
  fi
}

printf '# 项目盘点报告（自动生成）\n'
printf '\n- 目标：`%s`\n- 时间：%s\n- 搜索引擎：%s ｜ Git：%s\n' \
  "$ROOT" "$(date '+%Y-%m-%d %H:%M')" "$SEARCH" "$([ $HAS_GIT = 1 ] && echo 有 || echo 无)"

# ===========================================================================
h2 "1. 规模与结构"
TRACKED=0
if [ $HAS_GIT = 1 ]; then
  TRACKED=$(git ls-files | wc -l | tr -d ' ')
  printf -- '- Git 跟踪文件数：%s\n' "$TRACKED"
fi
printf -- '- 按扩展名 Top 文件类型：\n'
if [ $HAS_GIT = 1 ]; then FILELIST=$(git ls-files); else FILELIST=$(find . -type f -not -path './.git/*' 2>/dev/null); fi
echo "$FILELIST" | sed -n 's/.*\.\([A-Za-z0-9]\{1,8\}\)$/\1/p' | sort | uniq -c | sort -rn | head -n 12 | sed 's/^/    /'

# ===========================================================================
h2 "2. 文档清单（可理解性原料）"
DOC_HITS=$(echo "$FILELIST" | grep -iE 'readme|/docs/|\.md$|\.adoc$|architecture|adr|changelog|contributing' || true)
if [ -n "$DOC_HITS" ]; then echo "$DOC_HITS" | head -n 40 | sed 's/^/- /'; else echo "- ⚠️ 未发现任何文档文件（README/docs/*.md）——重大缺口"; fi

# ===========================================================================
h2 "3. Bus Factor（作者集中度）"
if [ $HAS_GIT = 1 ]; then
  printf -- '- 提交分布（git shortlog）：\n'
  git shortlog -sn --all 2>/dev/null | head -n 15 | sed 's/^/    /'
  printf -- '\n- 单一作者文件（仅 1 人改过 = 知识孤岛，离职高危）：\n'
  CAP=400; PROCESSED=0; SOLO=0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    PROCESSED=$((PROCESSED+1))
    [ $PROCESSED -gt $CAP ] && break
    n=$(git log --format='%an' -- "$f" 2>/dev/null | sort -u | wc -l | tr -d ' ')
    if [ "$n" = "1" ]; then
      a=$(git log --format='%an' -- "$f" 2>/dev/null | sort -u | head -n1)
      printf '    - %s  （唯一作者：%s）\n' "$f" "$a"
      SOLO=$((SOLO+1))
      [ $SOLO -ge 30 ] && { echo "    - …（仅显示前 30 个）"; break; }
    fi
  done <<< "$FILELIST"
  [ $SOLO = 0 ] && echo "    （前 $CAP 个文件内未发现单一作者文件）"
  [ $PROCESSED -gt $CAP ] && echo "    ⚠️ 文件过多，仅扫描了前 $CAP 个，结果不完整"
else
  echo "- ⚠️ 非 Git 仓库，无法分析作者集中度"
fi

# ===========================================================================
h2 "4. 未完成工作（in-flight）"
if [ $HAS_GIT = 1 ]; then
  printf -- '- 未合并分支：\n'; git branch --no-merged 2>/dev/null | sed 's/^/    /' | head -n 20
  printf -- '- 工作区未提交改动：\n'; git status --porcelain 2>/dev/null | sed 's/^/    /' | head -n 20
  if git rev-parse '@{u}' >/dev/null 2>&1; then
    printf -- '- 本地领先远端（未推送）提交：\n'; git log --oneline '@{u}..' 2>/dev/null | sed 's/^/    /' | head -n 20
  fi
  printf -- '- 最近活跃区域（近 20 次提交）：\n'; git log --oneline -n 20 2>/dev/null | sed 's/^/    /'
else
  echo "- ⚠️ 非 Git 仓库，无法分析未完成工作"
fi

# ===========================================================================
h2 "5. 隐性知识信号"
for kw in 'TODO' 'FIXME' 'HACK' 'XXX' '临时' '先这样' '别动' '不要动' 'workaround' 'magic'; do
  c=$(count_matches "$kw")
  printf -- '- %-10s 命中 %s 处\n' "$kw" "$c"
done
printf -- '\n- 抽样（前 25 条 TODO/FIXME/HACK）：\n'
list_matches 'TODO|FIXME|HACK' 25 | sed 's/^/    /'

# ===========================================================================
h2 "6. 依赖与构建清单（可运行性原料）"
for f in package.json package-lock.json yarn.lock pnpm-lock.yaml requirements.txt pyproject.toml Pipfile go.mod Cargo.toml pom.xml build.gradle Gemfile composer.json Dockerfile docker-compose.yml docker-compose.yaml Makefile; do
  [ -e "$f" ] && printf -- '- ✅ %s\n' "$f"
done
printf -- '- CI 配置：\n'
echo "$FILELIST" | grep -iE '\.github/workflows/|\.gitlab-ci|\.circleci/|jenkinsfile|\.travis|azure-pipelines' | sed 's/^/    /' | head -n 10 || echo "    （未发现 CI 配置）"

# ===========================================================================
h2 "7. 密钥与个人账号风险（依赖权限归属 ⚠️）"
if [ -e .env.example ] || [ -e .env.sample ]; then echo "- ✅ 存在 .env.example/.sample（环境变量有模板）"; else echo "- ⚠️ 未发现 .env.example——新人不知道要配哪些环境变量"; fi
if [ $HAS_GIT = 1 ] && git ls-files --error-unmatch .env >/dev/null 2>&1; then echo "- 🔴 .env 被纳入 Git 跟踪——疑似密钥入库"; fi
printf -- '- 疑似硬编码密钥/token（人工复核）：\n'
list_matches 'api[_-]?key|secret|password|token|BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}' 20 | sed 's/^/    /'
printf -- '\n- 出现的邮箱地址（排查个人账号绑定，人工复核归属）：\n'
if [ "$SEARCH" = "rg" ]; then
  rg -oI --no-messages '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' 2>/dev/null | sort -u | head -n 20 | sed 's/^/    /'
else
  grep -rohIE --exclude-dir=.git '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' . 2>/dev/null | sort -u | head -n 20 | sed 's/^/    /'
fi

# ===========================================================================
h2 "8. 测试与可测试性原料"
TESTHITS=$(echo "$FILELIST" | grep -iE '(^|/)tests?/|_test\.|\.test\.|\.spec\.|test_.*\.py' || true)
if [ -n "$TESTHITS" ]; then
  printf -- '- 测试文件数：%s\n' "$(echo "$TESTHITS" | wc -l | tr -d ' ')"
  echo "$TESTHITS" | head -n 15 | sed 's/^/    /'
else
  echo "- ⚠️ 未发现明显的测试文件——可测试性维度高危"
fi

hr
printf '✅ 盘点完成。以上为客观信号，请结合「接手人视角」在 Phase 2 逐维度审计中下结论。\n'
