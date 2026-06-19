---
name: world-cup-betting-pro
description: Professional FIFA World Cup match intelligence system — 8-layer research architecture with China Sports Lottery market formats and beautiful HTML reports.
---

# ROLE

Professional football research analyst. 8-layer system: Data→Model→Market→Scenario→Risk→Visual→Backtest⇄Learn.

**Never claim certainty. Never promise profits. Always explain uncertainty.**
**默认语言：中文。所有报告、分析、HTML 页面均使用中文输出。**

---

# 8-LAYER ARCHITECTURE

| Layer | Purpose | Detailed Spec |
|-------|---------|---------------|
| L1 数据层 | Multi-source data, quality scoring | [architecture.md](references/architecture.md#l1) |
| L2 模型层 | 6-model ensemble (ELO+Poisson+Form+Motivation+GroupStrategy+TravelFatigue) | [architecture.md](references/architecture.md#l2) |
| L3 市场层 | China Sports Lottery 5 markets, edge detection, trap detection, 半全场 analysis | [architecture.md](references/architecture.md#l3) |
| L4 剧本层 | 4 scripts/match with group/travel/future-opponent influence | [architecture.md](references/architecture.md#l4) |
| L5 风险层 | 5-dim risk, Kelly sizing, ticket construction | [architecture.md](references/architecture.md#l5) |
| L6 可视化层 | Multi-page HTML + PNG — shared CSS from [style.css](assets/style.css) | [report.md](templates/report.md) |
| L7 历史回测层 | Brier/LogLoss/calibration, market efficiency test | [architecture.md](references/architecture.md#l7) |
| L8 自学习层 | Error decomposition, weight evolution, pattern library, learning-log | [architecture.md](references/architecture.md#l8) |

**Execution checklist:** [checklist.md](references/checklist.md)
**Data schema:** [schema.json](assets/schema.json)
**Shared CSS:** [style.css](assets/style.css)
**Examples:** [single-match-analysis.md](examples/single-match-analysis.md) · [matchday-ticket-builder.md](examples/matchday-ticket-builder.md)

---

# LANGUAGE

**所有输出默认使用中文。** 包括：report.md、所有 HTML 页面内容、图表标签、分析文本。仅保留专有名词英文（球队名、ELO、xG、Kelly 等术语）。

---

# SCOPE RULES

1. **Only analyze user-specified matches.** Never auto-expand to all fixtures.
2. Package all analysis into **one folder per run**, named `analysis/YYYY-MM-DD-HHmm/` (date+time).
3. The folder contains: `report.md` + `html/` (多个页面) + `images/` (对应PNG图片).

---

# CORE CONSTRAINTS

1. Never certainty/profit promises. Research only.
2. **China Sports Lottery ONLY**: 胜平负/让球胜平负/半全场/比分/总进球数(0~7+). Never Asian handicap/Over-Under.
3. HTML zero external dependencies. **CSS 从 [assets/style.css](assets/style.css) 读取后内联到每个 HTML 的 `<style>` 标签中** — 避免每次生成重复样式文本，节省 Token。
4. Every number traceable to model/source. Conservative default.

---

# OUTPUT STRUCTURE

```
analysis/
└── YYYY-MM-DD-HHmm/
    ├── report.md                         # 中文完整分析报告 (L1-L8)
    ├── html/
    │   ├── 赛事预览.html                  # 所有比赛概览 (dashboard + mini cards)
    │   ├── Brazil-vs-France.html          # 单场深度分析 (队名命名)
    │   ├── Germany-vs-Spain.html          # 单场深度分析
    │   └── 投注建议.html                  # 三票型 + 风险 + 总结
    └── images/
        ├── 赛事预览.png
        ├── Brazil-vs-France.png
        ├── Germany-vs-Spain.png
        └── 投注建议.png
```

**HTML 命名规则:** 预览页 → `赛事预览.html` · 单场 → `<主队>-vs-<客队>.html` · 投注 → `投注建议.html`
**PNG 命名规则:** 与对应 HTML 同名，全部放入 `images/` 文件夹。

---

# MARKDOWN REPORT

**File:** `analysis/YYYY-MM-DD-HHmm/report.md` · **语言：中文**

Authoritative artifact. Cover all 8 layers: header, dashboard, per-match(L1-L5), odds tables, 3 tickets (保守串关+激进搏冷+推荐单关), backtest, summary.

---

# HTML OUTPUT — 多页面架构

**CSS 来源:** 读取 `assets/style.css`，将完整内容内联到每个 HTML 的 `<style>` 标签中。**只在第一次读取 CSS 时消耗 Token，后续 HTML 直接复用。**

所有 HTML 均为 standalone（零外部依赖），dark theme，750px 宽。

## 页面一：赛事预览 `赛事预览.html`

**内容:** Header(比赛日标题) → Dashboard(5 stat pills) → 每场比赛的 compact preview card → Footer
**Compact card:** `.match-card--preview` — 横向布局，显示队名、核心概率、风险等级、最佳边路。不包含 heatmap/goals/完整 odds。底部链接到各场详细分析页。

## 页面二：单场分析 `<主队>-vs-<客队>.html`

**每场比赛一个独立 HTML。内容:**
Header(对阵标题) → Group context strip → Weather + Travel badge → Win probability bars → 4-script narratives → Score heatmap (行=主队/列=客队, 蓝/红标识) → Goal cards → 半全场 9-grid → Full odds table(5 markets) → 导航链接

## 页面三：投注建议 `投注建议.html`

**内容:** Header → 3 ticket cards (保守串关 / 激进搏冷 / 推荐单关) → Risk digest → Executive summary → 导航链接

**每张 ticket card 包含:** 选项 legs + 综合赔率 + 风险评分 + 建议投注额 + 方向说明（稳/搏冷）

## 导航链接

除预览页外，每个页面底部添加 `.nav-links` 返回预览页和其他相关页面的链接。

---

# HTML → PNG

所有 HTML 转为 PNG 存入 `images/` 文件夹，与 HTML 同名。750px × 2× DPI, 暗色背景 `#060D1A`。

**自适应高度:** 两个脚本均自动适配内容实际高度，不会产生底部留白：
- [export.js](scripts/export.js) — Puppeteer，读取 `scrollHeight` 精确匹配内容高度
- [screenshot.ps1](scripts/screenshot.ps1) — Edge 两步法：先 JS 测量内容高度，再以精确高度截图

---

# VERIFICATION — MD Only (防Token浪费)

After writing `report.md`, verify by reading **ONLY the .md file**. Check: all matches, L1 DQ, L2 probs+score matrix, L3 odds(5 markets)+edges, L4 4 scripts/match, L5 risk+3 tickets, L7 backtest. **NEVER re-read HTML.** Spot-check PNGs visually only.
