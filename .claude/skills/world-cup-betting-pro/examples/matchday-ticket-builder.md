# Example: Matchday with Ticket Construction

**User asks:**
> Analyze GER vs ESP, POR vs ITA, NED vs BEL. Build all three ticket types.

**Scope:** 3 matches specified by user. Do NOT auto-add any others.

**Output folder:** `analysis/2026-06-19-1430/`

| Match | Result | Risk Class | Best Edge |
|-------|--------|------------|-----------|
| GER vs ESP | GER 38% / Draw 31% / ESP 31% | STANDARD (2.1) | 总进球 3球 +2.8% |
| POR vs ITA | POR 44% / Draw 29% / ITA 27% | CORE (1.6) | 胜平负 主胜 +3.5% |
| NED vs BEL | NED 35% / Draw 30% / BEL 35% | VOLATILE (3.2) | 半全场 负胜 +8.1% |

**Three ticket types:**

**保守串关:** POR 胜 + GER 总进球3球 → @10.35 · Risk 1.9 · Stake 2.5u
**激进搏冷:** NED 半全场负胜 + GER 比分2:1 → @42.00 · Risk 3.4 · Stake 0.8u
**推荐单关 (稳):** POR 胜 @2.10 · edge +3.5% · CORE(1.6) · Stake 3u

**Phase 6:** `report.md` written (中文). **Verification:** read .md only → 3 matches ✓, 3 tickets ✓, all layers ✓.

**Phase 7:** Multi-page HTML:
- `html/赛事预览.html` — 3 match preview cards
- `html/德国-vs-西班牙.html` / `html/葡萄牙-vs-意大利.html` / `html/荷兰-vs-比利时.html` — 单场分析（含出线形势+路线预测）
- `html/投注建议.html` — 3 tickets + risk + summary

**Phase 8:** All HTML → PNG in `images/` folder.

```
analysis/2026-06-19-1430/
├── report.md
├── html/
│   ├── 赛事预览.html
│   ├── 德国-vs-西班牙.html
│   ├── 葡萄牙-vs-意大利.html
│   ├── 荷兰-vs-比利时.html
│   └── 投注建议.html
└── images/
    ├── 赛事预览.png
    ├── 德国-vs-西班牙.png
    ├── 葡萄牙-vs-意大利.png
    ├── 荷兰-vs-比利时.png
    └── 投注建议.png
```
