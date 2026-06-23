# World Cup Betting Pro — 8-Layer Professional Research System

## Architecture

```
数据层 → 模型层 → 市场层 → 剧本层 → 风险层 → 可视化层
                               ↕         ↕
                          历史回测层 ←→ 自学习层
```

1. **数据层** — Multi-source data with quality scoring
2. **模型层** — 6-model ensemble (ELO + Poisson + Form + Motivation + Group Strategy + Travel Fatigue)
3. **市场层** — China Sports Lottery odds, edge detection, 半全场 analysis, trap detection
4. **剧本层** — 4-script narratives with group/travel/future-opponent influence
5. **风险层** — 5-dim risk, Kelly sizing, ticket construction
6. **可视化层** — Standalone dark-theme HTML with Poisson matrices and dashboards
7. **历史回测层** — Brier score, calibration, market efficiency testing
8. **自学习层** — Error decomposition, weight updates, pattern library, learning log

## Directory Structure

```
.claude/skills/world-cup-betting-pro/
├── SKILL.md                    # Entry point — core identity + pointers
├── README.md                   # This file
├── examples/
│   ├── single-match-analysis.md   # Single match deep analysis
│   └── matchday-ticket-builder.md  # Full matchday with tickets
├── templates/
│   └── report.md               # 3-page HTML architecture spec
├── references/
│   ├── architecture.md         # Full 8-layer detailed specification
│   └── checklist.md            # Execution checklist (phases 1-9)
├── scripts/
│   └── export.js               # Puppeteer: HTML → PNG (fullPage auto-height)
└── assets/
    ├── style.css               # Shared CSS — single source, inlined into all HTML
    └── schema.json             # Match data JSON schema
```

## Usage Examples

```
# Full matchday analysis
Analyze tomorrow's four World Cup matches.

# With ticket construction
Analyze today's World Cup matches and build all three ticket types:
conservative accumulator + aggressive cold-bet + recommended single.

# Specific matches
Analyze: 巴西 vs 法国, 英格兰 vs 阿根廷
Use China Sports Lottery odds. Include weather, injuries, lineups,
market movement, score prediction, total goals, handicap, HT/FT.
Generate: 保守串关 + 激进搏冷 + 推荐单关.
```

## Output

```
analysis/YYYY-MM-DD-HHmm/
├── report.md                         # 中文完整分析报告
├── html/
│   ├── 赛事预览.html                  # 所有比赛概览
│   ├── <主队>-vs-<客队>.html          # 单场深度分析
│   └── 投注建议.html                  # 三票型+风险+总结
└── images/
    ├── 赛事预览.png                   # 同名 PNG (750px@2x)
    ├── <主队>-vs-<客队>.png
    └── 投注建议.png
```

Plus: `analysis/learning-log.json` — continuous improvement log

## Language

**默认中文。** 所有报告、HTML、分析文本使用中文输出。

## CSS Strategy

`assets/style.css` — 共享样式单源。首次读取后内联到每个 HTML `<style>` 标签，后续页面直接复用，节省 Token。

## Verification

Only `report.md` is read back for completeness verification — never the HTML. Spot-check PNGs visually.

## Key Principles

- Never claim certainty. Always explain uncertainty.
- China Sports Lottery formats only (胜平负, 让球胜平负, 半全场, 比分, 总进球数)
- No external dependencies in HTML; shared CSS from assets/style.css
- Every prediction traceable to a specific model or data source
- Three ticket types: 保守串关 (steady) + 激进搏冷 (cold) + 推荐单关 (稳/搏冷)
- Research and entertainment purposes only
