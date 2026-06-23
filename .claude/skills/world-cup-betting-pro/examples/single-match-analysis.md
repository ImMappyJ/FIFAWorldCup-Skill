# Example: Single Match Deep Analysis

**User asks:**
> Analyze Brazil vs France in the World Cup semi-final.

**Scope:** 1 match only. Output folder: `analysis/2026-06-19-1430/`

**Phase 0:** Create output folder. Do NOT auto-add other matches.

**Phase 1-5 (L1-L5):** Run full pipeline for BRA vs FRA. Key findings:

| Layer | Key Output |
|-------|-----------|
| L1 Data | Weather: Dallas 32°C. Travel: BRA 1800km vs FRA 380km → DQ 0.85 |
| L2 Model | BRA 42% / Draw 30% / FRA 28%. Top score: 1:1 (12%). Travel fatigue shifts ~3% to FRA |
| L3 Market | 胜平负: FRA@3.40 shows +1.7% edge. 半全场 平平@4.50 → +2.3% edge. Trap: low |
| L4 Scripts | A(Dominance)30% · B(Open)28% · C(Upset)24% · D(Stalemate)18% |
| L5 Risk | STANDARD (2.8). 保守串关 N/A(1 match). 激进搏冷 N/A. 推荐单关(稳): 总进球 2球 @3.20 · Kelly 1.2u |

**Phase 6:** Write `report.md` (中文) → **verify by reading .md only.** All layers present, 1 match confirmed.

**Phase 7:** 3 HTML pages:
- `html/赛事预览.html` — single match preview card
- `html/巴西-vs-法国.html` — 完整单场分析 (group + path分析 + weather + bars + scripts + Poisson得分矩阵(含赔率) + goals + 半全场 + odds)
- `html/投注建议.html` — 推荐单关 + risk + summary

**Phase 8:** Screenshot all HTML → `images/` via `node scripts/export.js` (750px@2x, fullPage auto-height). Spot-check visually.

**Phase 9:** Backtest prior, append learning-log.

**Final folder:**
```
analysis/2026-06-19-1430/
├── report.md
├── html/
│   ├── 赛事预览.html
│   ├── 巴西-vs-法国.html
│   └── 投注建议.html
└── images/
    ├── 赛事预览.png
    ├── 巴西-vs-法国.png
    └── 投注建议.png
```
