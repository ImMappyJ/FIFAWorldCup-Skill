# Execution Checklist

**Scope:** Only user-specified matches. **Language:** 中文.
**Output:** `analysis/YYYY-MM-DD-HHmm/` → `report.md` + `html/` + `images/`

---

## Phase 0 — SETUP
- [ ] Create output folder: `analysis/YYYY-MM-DD-HHmm/`
- [ ] Create subfolders: `html/`, `images/`
- [ ] Confirm match list (do NOT expand scope)

## Phase 1 — DATA (L1)
- [ ] Fetch: China Sports Lottery odds, FIFA schedule/squads/standings, weather@kickoff, injury/suspension news, ELO ratings, xG/xGA(FBref/Understat), recent form[10]+H2H, group standings+remaining fixtures, team base camps+travel distances
- [ ] Compute DATA_QUALITY per match; flag DQ<0.6

## Phase 2 — MODEL (L2)
- [ ] Run ELO, Poisson(λ from xG→full score matrix), Form Power, Motivation, Group Strategy, Travel Fatigue
- [ ] Ensemble→normalize, extract top 5 scores, BTTS, goal thresholds, MODEL_CONFIDENCE

## Phase 3 — MARKET (L3)
- [ ] Collect odds for 5 markets, remove vig, calculate edge per selection
- [ ] Analyze odds movement (open→current), trap detection (trap_score per match)
- [ ] 半全场: decompose Poisson HT/FT, compute 9-combo edges
- [ ] Cross-market consistency check

## Phase 4 — SCENARIO (L4)
- [ ] 4 scripts/match (Dominance/Open/Upset/Stalemate) with narratives, triggers, scores, probs
- [ ] Annotate: group pressure, future-opponent strategy, travel inequality
- [ ] Map scripts→半全场 outcomes

## Phase 5 — RISK (L5)
- [ ] Score 5+ risk dims/match (1-5), classify (CORE/STANDARD/VOLATILE/EXTREME)
- [ ] Kelly sizing (edge/(odds-1)×0.25, cap 5%), build 3 tickets:
  - **保守串关** (CORE, 3-4 legs, @2.00-5.00)
  - **激进搏冷** (VOLATILE, 2-3 legs, @5.00-15.00+, contrarian picks)
  - **推荐单关** (best single edge, 稳/搏冷 direction, Kelly-sized ≤5u)
- [ ] Bankroll rules, correlation avoidance

## Phase 6 — MARKDOWN REPORT (中文)
- [ ] Write `report.md`: header, dashboard, per-match(L1-L5), odds, 3 tickets, backtest, summary
- [ ] **Verify .md only**: all matches+L1DQ+L2probs+L3odds+L4scripts+L5tickets+L7backtest. Never re-read HTML.

## Phase 7 — HTML (多页面)

**CSS: 首次读取 `assets/style.css` 并内联到 `<style>`，后续页面复用同一 CSS 文本。**

- [ ] **7a. 赛事预览.html** — Header + Dashboard + match preview cards (`.match-card--preview`) + nav links → Footer
- [ ] **7b. 单场分析 `<主队>-vs-<客队>.html`** — 每场一个: Group context + weather/travel + win bars + scripts + heatmap + goals + 半全场 + odds table + nav
- [ ] **7c. 投注建议.html** — 3 ticket cards (.tickets) + risk digest + executive summary + nav
- [ ] Validate all HTML: no CDN/JS, dark theme, 中文, shared CSS inline

## Phase 8 — PNG
- [ ] Run `node scripts/export.js analysis/.../html/<name>.html analysis/.../images/<name>.png` for each HTML
- [ ] Uses Puppeteer fullPage:true → auto-fits content height, no blank bottom
- [ ] Visual spot-check each PNG: header-to-footer all captured, no clipping

## Phase 9 — BACKTEST + LEARN (L7/L8)
- [ ] If prior predictions: backtest (Brier, LogLoss, calibration), decompose errors
- [ ] Update model weights (≥5 matches backtested), append `learning-log.json`
