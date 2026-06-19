# HTML Templates — 多页面架构

**CSS 来源:** [assets/style.css](../assets/style.css) — 读取后内联到每个 HTML 的 `<style>` 中。共享样式，避免重复生成。

**输出路径:** `analysis/YYYY-MM-DD-HHmm/html/` · 命名: `赛事预览.html` / `<主队>-vs-<客队>.html` / `投注建议.html`

**设计语言:** 中文 · Dark theme (`--bg:#060D1A`) · 750px 宽 @2x DPI · 零外部依赖

---

## 页面一：赛事预览 `赛事预览.html`

**用途:** 一屏概览所有比赛，快速对比。顶部链接到各场详细分析。

**结构:**
```
Header(比赛日 + 日期 + 比赛数量 badge)
→ Dashboard(5 pills: 比赛数/CORE数/边缘数/冷门风险/平均风险)
→ Match preview cards (每场一个 .match-card--preview)
   ┌─────────────────────────────────────────────┐
   │ ⚽ Brazil vs France    CORE · Risk 1.6      │
   │ 主胜42%  平30%  客胜28%   最佳: 总进球2球    │
   │                    [查看详细分析 →]          │
   └─────────────────────────────────────────────┘
→ Footer
```

**Compact card (`.match-card--preview`):**
- 横向布局：队名 vs 队名 | 快速概率 | 最佳边路 | 风险标签
- 风险标签颜色: CORE=green · STANDARD=yellow · VOLATILE=red
- 右侧链接 → 对应单场分析 HTML

---

## 页面二：单场分析 `<主队>-vs-<客队>.html`

**用途:** 单场比赛完整深度分析。每场比赛一个独立 HTML。

**结构 (从上到下):**
```
Header(对阵双方 + 比赛信息 + 阶段)
→ Group Context Strip (小组排名表 + 出线形势 + 奔波距离)
→ Weather + Travel Badge
→ Win Probability Bars (三色: 主胜蓝/平灰/客胜红)
→ Model Ensemble Breakdown (6模型贡献)
→ 4-Script Narratives (A表现/B对攻/C爆冷/D僵局)
→ Score Heatmap (7×7 热力图 — 竖=列/蓝=主队进球 0~5+, 横=行/红=客队进球 0~5+. 角格指示方向, 最佳比分高亮)
→ Goal Cards (0~7+ 球概率, 最佳高亮)
→ 半全场 9-Grid (3×3, 有边路的格子绿色高亮)
→ Full Odds Table (5 markets: 胜平负/让球胜平负/半全场/比分/总进球数, 标记 edge)
→ Navigation (← 返回预览 | 其他场次 | 投注建议 →)
→ Footer
```

**关键 CSS 类:** `.match-card` `.group-strip` `.win-bars` `.score-heatmap` `.score-grid` `.score-grid__top-header` `.score-grid__left-header` `.goal-cards` `.htft-grid` `.odds-table` `.nav-links`

### 比分热力图 HTML 结构

**约定：横 = 行（红色顶部标签），竖 = 列（蓝色左侧标签）。**

```html
<div class="score-heatmap">
  <!-- 标题栏：明确标注哪队是哪根轴 -->
  <div class="score-heatmap__title">
    <span class="axis-badge axis-badge--home">🇧🇷 Brazil 进球（列）</span>
    <span class="axis-arrow">×</span>
    <span class="axis-badge axis-badge--away">🇫🇷 France 进球（行）</span>
  </div>

  <div class="score-grid-wrapper">
    <div class="score-grid">
      <!-- 角格：方向指示 -->
      <div class="score-grid__corner">
        <span class="corner-row">行 →</span>
        <span class="corner-col">↓ 列</span>
      </div>
      <!-- 顶部 = 行头：客队进球数 0~5+（红色，横排） -->
      <div class="score-grid__top-header">0</div>
      <div class="score-grid__top-header">1</div>
      <div class="score-grid__top-header">2</div>
      <div class="score-grid__top-header">3</div>
      <div class="score-grid__top-header">4</div>
      <div class="score-grid__top-header">5+</div>
      <!-- 左侧 = 列头：主队 0 球（蓝色，竖排）→ 6 个概率格（该行 × 6 列） -->
      <div class="score-grid__left-header">0</div>
      <div class="score-cell score-cell--hot">1.2%</div>
      <div class="score-cell score-cell--hot">2.8%</div>
      <div class="score-cell score-cell--best">5.1%</div>
      <div class="score-cell">3.4%</div>
      <div class="score-cell">1.8%</div>
      <div class="score-cell">0.9%</div>
      <!-- 第2-6行同理：主队 1~5+ 球 → 各 6 个概率格 -->
      ...
    </div>
  </div>
</div>
```

**颜色编码规则:**
- 左侧 `.score-grid__left-header` — 蓝色背景 `rgba(59,130,246,0.1)`，竖排 = **列**，代表主队进球数 0~5+
- 顶部 `.score-grid__top-header` — 红色背景 `rgba(239,68,68,0.1)`，横排 = **行**，代表客队进球数 0~5+
- 角格：`corner-row`（红，"行 →" 横方向）+ `corner-col`（蓝，"↓ 列" 竖方向）
- `.score-cell--best` — 最可能比分，金色高亮 + glow

---

## 页面三：投注建议 `投注建议.html`

**用途:** 三票型汇总 + 风险分析 + 执行摘要。

**结构:**
```
Header(投注建议 + 日期)
→ 3 Ticket Cards (.tickets grid)
   ┌──────────────┬──────────────┬──────────────┐
   │ 保守串关      │ 激进搏冷      │ 推荐单关      │
   │ green top    │ red top      │ blue top     │
   │ 3-4 legs     │ 2-3 legs     │ 1 pick       │
   │ @2.00-5.00   │ @5.00-15.00+ │ Kelly-sized  │
   │ Stake: 2.5u  │ Stake: 0.8u  │ 稳/搏冷标签   │
   └──────────────┴──────────────┴──────────────┘
→ Risk Digest (.risk-digest — 所有比赛风险项)
→ Executive Summary (.summary — 3-col key takeaways)
→ Navigation (← 返回预览)
→ Footer
```

**关键 CSS 类:** `.tickets` `.ticket-card--conservative` `.ticket-card--cold` `.ticket-card--single` `.tag--steady` `.tag--cold` `.risk-digest` `.summary` `.nav-links`

---

## CSS 共用策略

1. 第一次生成 HTML 时，读取 `assets/style.css`，完整内联到 `<style>` 标签。
2. 后续 HTML 页面直接复用同一 CSS 文本 — 不再重复消耗 Token 生成样式。
3. 所有页面共用 `:root` 变量、typography、section header、footer、nav-links。
4. 预览页额外使用 `.match-card--preview`；单场页使用 `.match-card`（完整版）；投注页使用 `.tickets`。

---

## Screenshot

所有 HTML → PNG 存入 `images/`，与 HTML 同名。750px × 2× DPI。
**自适应高度:** export.js 读取 scrollHeight 精确匹配 · screenshot.ps1 大窗口截图后自动裁剪底部空白。不再有留白。
