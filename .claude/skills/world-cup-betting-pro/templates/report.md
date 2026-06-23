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
   │ ⚽ 巴西 vs 法国    CORE · Risk 1.6      │
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
→ Path Analysis（出线形势 & 淘汰赛路线）
   ├─ 小组当前排名表（高亮主客两队，标注出线区/淘汰区）
   ├─ 剩余赛程一览（各队剩余对手 + 关键度标记）
   ├─ 出线概率矩阵（每队拿第1/第2/淘汰概率）
   ├─ 路线对比卡（拿第1 vs 拿第2的淘汰赛路线 + 对手难度）
   ├─ 战略动机标签（全力争胜 / 中性 / 可能留力）
   └─ 对阵树可视化（聚焦该队所在半区，含路线连接线）
→ Weather + Travel Badge
→ Win Probability Bars (三色: 主胜蓝/平灰/客胜红)
→ Model Ensemble Breakdown (7模型贡献)
→ 4-Script Narratives (A表现/B对攻/C爆冷/D僵局, 每剧本含strategic_motive)
→ Poisson得分矩阵（含赔率 — 按概率降序排列的比分概率表，每行标注对应赔率，最可能比分高亮）
→ Goal Cards (0~7+ 球概率, 最佳高亮)
→ 半全场 9-Grid (3×3, 有边路的格子绿色高亮)
→ Full Odds Table (5 markets: 胜平负/让球胜平负/半全场/比分/总进球数, 标记 edge)
→ Navigation (← 返回预览 | 其他场次 | 投注建议 →)
→ Footer
```

**关键 CSS 类:** `.match-card` `.group-strip` `.win-bars` `.poisson-matrix-section` `.poisson-table` `.poisson-row--best` `.prob-value` `.odds-value` `.score-line` `.goal-cards` `.htft-grid` `.odds-table` `.path-analysis` `.standing-table` `.prob-matrix` `.route-cards` `.motive-tag` `.bracket-tree` `.nav-links`

### Poisson得分矩阵 HTML 结构

**Poisson模型预测的比分概率矩阵，按概率降序排列，每行标注对应赔率。**
**只在比分处标注国家队译名（巴西、法国），列标题用译名即可。**

```html
<div class="poisson-matrix-section">
  <!-- 标题栏 -->
  <div class="section-header">
    <span class="accent-bar"></span><span class="icon">📊</span>
    <span class="title">Poisson 得分矩阵</span>
  </div>

  <table class="poisson-table">
    <thead>
      <tr>
        <th>#</th>
        <th>比分 (主:客)</th>
        <th>Poisson 概率</th>
        <th>赔率</th>
      </tr>
    </thead>
    <tbody>
      <tr class="poisson-row--best">
        <td>1</td>
        <td><span class="score-line">🇧🇷 巴西 <strong>1:1</strong> 🇫🇷 法国</span></td>
        <td><span class="prob-value">12.3%</span></td>
        <td><span class="odds-value">@6.50</span></td>
      </tr>
      <tr>
        <td>2</td>
        <td><span class="score-line">🇧🇷 巴西 <strong>1:0</strong> 🇫🇷 法国</span></td>
        <td><span class="prob-value">10.8%</span></td>
        <td><span class="odds-value">@7.00</span></td>
      </tr>
      <tr>
        <td>3</td>
        <td><span class="score-line">🇧🇷 巴西 <strong>2:1</strong> 🇫🇷 法国</span></td>
        <td><span class="prob-value">9.2%</span></td>
        <td><span class="odds-value">@8.50</span></td>
      </tr>
      <tr>
        <td>4</td>
        <td><span class="score-line">🇧🇷 巴西 <strong>0:0</strong> 🇫🇷 法国</span></td>
        <td><span class="prob-value">8.5%</span></td>
        <td><span class="odds-value">@9.00</span></td>
      </tr>
      <tr>
        <td>5</td>
        <td><span class="score-line">🇧🇷 巴西 <strong>0:1</strong> 🇫🇷 法国</span></td>
        <td><span class="prob-value">7.8%</span></td>
        <td><span class="odds-value">@9.50</span></td>
      </tr>
      <tr>
        <td>6</td>
        <td><span class="score-line">🇧🇷 巴西 <strong>2:0</strong> 🇫🇷 法国</span></td>
        <td><span class="prob-value">7.2%</span></td>
        <td><span class="odds-value">@10.00</span></td>
      </tr>
      <!-- ... 继续列出所有比分（通常 ~10-15 行），按概率降序 -->
    </tbody>
  </table>
</div>
```

**规则:**
- 按 Poisson 概率降序排列（最可能比分排第一）
- `.poisson-row--best` — 最可能比分行，金色高亮 + glow
- `.prob-value` — 概率值，粗体显示
- `.odds-value` — 赔率值，绿色高亮（对应中国竞彩 比分 玩法）
- `.score-line` — 比分行，包含国旗 + 译名 + 比分
- 仅列出概率 >1% 的比分（通常 10-15 行）
- 赔率为中国竞彩 比分 玩法对应的官方赔率

### 出线分析 HTML 结构

**位置：** Group Context Strip 之后，Weather 之前。

```html
<div class="path-analysis">
  <!-- Section 标题 -->
  <div class="section-header">
    <span class="accent-bar"></span><span class="icon">🧮</span>
    <span class="title">出线形势 & 淘汰赛路线</span>
  </div>

  <!-- ① 小组排名表 -->
  <table class="standing-table">
    <tr><th>#</th><th>球队</th><th>赛</th><th>胜</th><th>平</th><th>负</th><th>进</th><th>失</th><th>净</th><th>分</th></tr>
    <tr class="highlight-team pos-1st"><td><span class="pos-num">1</span></td><td>🇧🇷 巴西</td><td>2</td><td>2</td><td>0</td><td>0</td><td>5</td><td>1</td><td>+4</td><td><strong>6</strong></td></tr>
    <tr class="pos-2nd"><td><span class="pos-num">2</span></td><td>🇫🇷 法国</td><td>2</td><td>1</td><td>0</td><td>1</td><td>3</td><td>2</td><td>+1</td><td><strong>3</strong></td></tr>
    <tr class="pos-out"><td><span class="pos-num">3</span></td><td>🇨🇲 喀麦隆</td><td>2</td><td>1</td><td>0</td><td>1</td><td>2</td><td>4</td><td>-2</td><td><strong>3</strong></td></tr>
    <tr class="pos-out"><td><span class="pos-num">4</span></td><td>🇷🇸 塞尔维亚</td><td>2</td><td>0</td><td>0</td><td>2</td><td>1</td><td>4</td><td>-3</td><td><strong>0</strong></td></tr>
  </table>

  <!-- ② 剩余赛程 -->
  <div class="fixture-list">
    <div class="fixture-item"><span class="teams">🇧🇷 巴西 vs 🇷🇸 塞尔维亚</span><span class="impact">关键</span></div>
    <div class="fixture-item"><span class="teams">🇫🇷 法国 vs 🇨🇲 喀麦隆</span><span class="impact">生死战</span></div>
  </div>

  <!-- ③ 出线概率矩阵 -->
  <div class="prob-matrix">
    <div class="prob-cell">
      <div class="team-name">🇧🇷 巴西</div>
      <div class="prob-bar-track"><div class="prob-bar-fill" style="width:85%;background:var(--success);"></div></div>
      <div class="prob-label">出线 95%</div>
    </div>
    <div class="prob-cell">
      <div class="team-name">🇫🇷 法国</div>
      <div class="prob-bar-track"><div class="prob-bar-fill" style="width:45%;background:var(--warning);"></div></div>
      <div class="prob-label">出线 50%</div>
    </div>
    <div class="prob-cell">
      <div class="team-name">🇨🇲 喀麦隆</div>
      <div class="prob-bar-track"><div class="prob-bar-fill" style="width:40%;background:var(--warning);"></div></div>
      <div class="prob-label">出线 45%</div>
    </div>
  </div>

  <!-- ④ 路线对比卡 -->
  <div class="route-cards">
    <div class="route-card route-card--1st">
      <div class="route-title">🏆 拿第1的路线</div>
      <div class="route-leg"><span class="opponent">Ro16 vs 2B</span><span class="difficulty">🔴 tough</span></div>
      <div class="route-leg"><span class="opponent">QF vs 1D/2C</span><span class="difficulty">🟡 even</span></div>
      <div class="route-leg"><span class="opponent">SF vs 1E/2F/1G/2H</span><span class="difficulty">🟢 easy</span></div>
      <div class="route-diff">同半区强敌较少 ✓</div>
    </div>
    <div class="route-card route-card--2nd">
      <div class="route-title">🥈 拿第2的路线</div>
      <div class="route-leg"><span class="opponent">Ro16 vs 1B</span><span class="difficulty">🔴 tough</span></div>
      <div class="route-leg"><span class="opponent">QF vs 1A/2B</span><span class="difficulty">🔴 tough</span></div>
      <div class="route-leg"><span class="opponent">SF vs 1C/2D/1E/2F</span><span class="difficulty">🔴 tough</span></div>
      <div class="route-diff">连续遭遇强队 ✗</div>
    </div>
  </div>

  <!-- ⑤ 战略动机标签 -->
  <div class="motive-bar">
    <span class="motive-tag motive-tag--push"><span class="motive-icon">🔥</span> 巴西全力争胜——第1路线更有利</span>
    <span class="motive-tag motive-tag--neutral"><span class="motive-icon">⚖️</span> 法国中性——出线优先</span>
  </div>

  <!-- ⑥ 对阵树 -->
  <div class="bracket-tree">
    <div class="bracket-round">
      <div class="bracket-round__title">Ro16</div>
      <div class="bracket-match bracket-match--projected">
        <span class="team team--highlight">🇧🇷 巴西</span>
        <span class="scoreline">vs 2B</span>
      </div>
      <div class="bracket-connector"></div>
      <div class="bracket-match bracket-match--empty">2B</div>
    </div>
    <div class="bracket-round">
      <div class="bracket-round__title">QF</div>
      <div class="bracket-match bracket-match--empty">1D/2C</div>
      <div class="bracket-connector bracket-connector--merge"></div>
      <div class="bracket-match bracket-match--empty">1D/2C</div>
    </div>
    <div class="bracket-round">
      <div class="bracket-round__title">SF</div>
      <div class="bracket-match bracket-match--empty">上半区</div>
      <div class="bracket-connector"></div>
      <div class="bracket-match bracket-match--empty">上半区</div>
    </div>
  </div>
</div>
```

**颜色编码规则:**
- `.pos-1st` 行 — 绿色圆形标记，代表出线区
- `.pos-2nd` 行 — 浅绿标记，代表竞争区
- `.pos-out` 行 — 红色标记，代表淘汰区
- `.highlight-team` 行 — 蓝色底色，代表当前分析的主客两队
- `.route-card--1st` — 蓝色顶边，代表第1名路线
- `.route-card--2nd` — 黄色顶边，代表第2名路线
- `.motive-tag--push` — 绿色，全力争胜
- `.motive-tag--neutral` — 灰色，中性
- `.motive-tag--conserve` — 红色，可能留力

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
4. 预览页额外使用 `.match-card--preview`；单场页使用 `.match-card`（完整版），外加 `.path-analysis` `.bracket-tree`（出线分析）；投注页使用 `.tickets`。

## Screenshot

所有 HTML → PNG 存入 `images/`，与 HTML 同名。750px × 2× DPI。
**唯一方案:** [export.js](../scripts/export.js) — Puppeteer `fullPage: true`，自动匹配内容高度，无留白。
