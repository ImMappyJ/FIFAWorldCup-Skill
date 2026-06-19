# 8-Layer Architecture Reference

---

## L1: 数据层 (DATA)

### Source Priority
| Tier | Sources | What |
|------|---------|------|
| T1 | lottery.gov.cn, fifa.com, confederation sites | Official odds, schedules, squads, standings |
| T2 | Weather, team announcements, Transfermarkt | Temp/humidity/wind/rain, lineups/injuries, market values |
| T3 | FBref/Understat, eloratings.net, Soccerway | xG/xGA, ELO & trend, form[10]+H2H |
| T4 | lottery.gov.cn movements, European books, social | Odds movement, cross-market ref, public sentiment |

### Per-Match Data Checklist
```
match_id, stage, datetime, venue
weather{t_c, humidity%, wind_kmh, rain%, pitch}
team_home/away{name, fifa_rank, elo, elo_trend, form[10], xG[5], xGA[5], poss%, shots_avg}
squad_home/away{xi[], injuries[], suspensions[], key[], rotation_risk, bench}
h2h{W, D, L, avg_goals}
motivation{must_win, qualification, approach}
```

**Group context:** group_table{played,pts,GF,GA,GD,position}, remaining_fixtures[], qualification_scenarios, tiebreaker_status.

**Future opponent:** next_opponent{name, strength, rest_days}, knock-out_path → infer rotation/push incentive.

**Travel log:** base_camp→venue distance_km, travel_mode{bus/train/flight}, hours, days_since_last, cumulative_km.

### Data Quality
`DQ = (T1×3 + T2×2 + T3×1) / max_score`. Flag DQ < 0.6 as **LOW CONFIDENCE**.

---

## L2: 模型层 (MODEL)

### Six-Model Ensemble

**A: ELO** — `P_home = 1/(1+10^(-(ELO_h-ELO_a+HFA)/400))`, HFA=100 (0 neutral venue). Draw=1-P_home-P_away. Knockout: draw ×0.3.

**B: Poisson** — `λ_home/away = weighted_xG(last10, opponent_def, venue)`. `P(i,j) = Pois(i,λ_h) × Pois(j,λ_a)`. Sum for W/D/L + total goals. Build full 0:0 to 6+:6+ matrix. Top 5 scorelines, BTTS prob, goal thresholds.

**C: Form Power** — Decay weights `[.30, .22, .16, .12, .08, .05, .04, .02, .01, .00]` × result points over last 10 matches.

**D: Motivation** — must_win_qualified:1.15, must_win_elim:1.08, knockout:1.05, nothing_to_play:0.90, dead_rubber:0.85.

**E: Group Strategy Adjustment**

| Situation | Factor | Effect |
|-----------|--------|--------|
| Qualified + easy next opponent | 0.88 | Rotation likely, effort ↓ |
| Qualified + tough next opponent | 0.93 | Partial rotation |
| Need draw to qualify | 0.95 | Conservative, draw prob ↑ |
| Must win to qualify | 1.10 | All-out attack, variance ↑ |
| Need help from other match | 0.97 | Distraction risk |
| Eliminated | 0.82 | Pride only, youth players |
| KO — first leg advantage needed | 1.05 | Aggressive home leg |
| KO — protecting first-leg lead | 0.92 | Cautious, counter |

**F: Travel Fatigue**

| Distance | Factor |
|----------|--------|
| <50 km (same city) | 1.00 |
| 50-200 km (bus, <3h) | 0.98 |
| 200-500 km (train/flight, 3-6h) | 0.95 |
| 500-1000 km (flight) | 0.90 |
| >1000 km / cross-timezone | 0.85 |

Cumulative >2000 km in tournament: extra ×0.95. Compare both sides for travel inequality.

### Ensemble Weights
Poisson:0.35, ELO:0.15, Form:0.15, Motivation:0.10, GroupStrategy:0.10, TravelFatigue:0.08, H2H:0.07. Normalize to 1.0.

### Confidence
`MODEL_CONF = 1 - max(variance_across_models)`.

---

## L3: 市场层 (MARKET)

### 5 Markets (China Sports Lottery ONLY)

| Market | Chinese | Outcomes |
|--------|---------|----------|
| Win/Draw/Loss | 胜平负 | 3 |
| Handicap W/D/L | 让球胜平负 | 3 (handicap-adjusted) |
| Half/Full | 半全场 | 9: 胜胜〜負負 |
| Correct Score | 比分 | Per scoreline |
| Total Goals | 总进球数 | 0,1,2,3,4,5,6,7+球 |

**NEVER translate to Asian handicap, Over/Under 2.5, or European handicap terms.**

### Edge Detection
```
vig = sum(1/odds_i) - 1.0
fair_prob_i = (1/odds_i) / sum(1/odds_i)   # proportional vig removal
edge = model_prob - fair_prob
```
Thresholds: strong >.05 | moderate >.02 | none >-.02 | negative ≤-.02.

### Movement Signals
- Steaming short → sharp money on favorite
- Steaming long → sharp money on underdog → investigate upset
- Volatile → check for breaking news (injury, lineup leak)
- Stable → pure model vs market edge

### Trap Detection (flag trap_score > 0.6)
- Public >70% one side but odds move opposite direction
- Favorite odds suspiciously generous vs model probability
- Heavily-bet match with unusually stable odds → 庄家控盘嫌疑

### 半全场 Odds (9-Combo)
Decompose Poisson: `P_HT(h/d/a)` using λ/2, then `P_FT|HT`. `P(combo) = P_HT × P_FT|HT`.

Odds structure: 胜胜/负负 lowest · 平平 moderate · 平胜/平负 higher · 胜负/负胜 highest · 胜平/负平 moderate-high.

Key edges: comeback potential → 平胜/平负 undervalued · dominance → 胜胜/负负 may have edge · cagey 1H → 平平/平胜/平负 cluster undervalued.

### Cross-Market Consistency
胜平负 winner ↔ 让球胜平负 direction. 总进球 distribution ↔ 比分 implied totals. 半全场 ↔ HT/FT model decomposition. sum(胜* combos) ≈ 胜 prob from 胜平负.

---

## L4: 剧本层 (SCENARIO)

4 scripts per match. Each: 3-5 sentence narrative + key trigger + score range + model probability.

| Script | Theme | Trigger | Scores |
|--------|-------|---------|--------|
| A: Dominance | Favorite controls, scores first | Early goal <30' | 1:0,2:0,2:1,3:0,3:1 |
| B: Open Game | Both attack, high-event | Both score in 1H | 2:2,3:2,2:3,3:3 |
| C: Upset | Underdog counters perfectly | Underdog scores 1st | 0:1,1:2,0:2 |
| D: Stalemate | Cautious, few chances | 0:0 at 60', few SoT | 0:0,1:1 |

Each script references: tactical matchup · key player mini-story · weather · game-state dynamics · subs · **group pressure** · **future-opponent strategy** · **travel inequality**.

**Group/future-opp influence:** Must-win → B/D less likely. Need draw → D more likely. Tough next opponent → A less dominant. Eliminated → C more likely vs them.

**半全场 mapping:** A→勝勝/平勝, B→勝勝/平勝/勝平, C→平負/負負/勝負, D→平平/平勝/平負.

---

## L5: 风险层 (RISK)

### 5-Dimension Risk (1-5 each)
- **Weather:** rain>50%, extreme temp, high wind
- **Rotation:** qualified, injury crisis, depth, future-opponent rotation incentive
- **Fatigue:** <3d rest, travel>500km, cumulative>1500km, cross-TZ, travel inequality
- **Market Trap:** trap_score > 0.4
- **Model Uncertainty:** MODEL_CONF < 0.3
- **Group Pressure:** must-win-or-out, need-help, simultaneous-fixture uncertainty

`MATCH_RISK = avg(dims)`. <2.0:CORE · 2.0-3.0:STANDARD · 3.0-4.0:VOLATILE · ≥4.0:EXTREME(no bet).

### Position Sizing
`Kelly = edge/(odds-1)`. Stake = Kelly × 0.25, cap 5% bankroll. Bankroll = 100u virtual.
Max single:5u, acca:3u, total exposure:15u. Stop-loss: -20% drawdown.

### Ticket Construction

**保守串关 (Conservative Accumulator):** CORE only, edge>0, 3-4 legs, combined odds 2.00-5.00, diversify across markets. Stable foundation.

**激进搏冷 (Aggressive Cold-Bet):** VOLATILE matches (3.0-4.0 risk), edge>0.05 on contrarian picks, 2-3 legs, combined odds 5.00-15.00+. Hunt undervalued underdogs + extreme scores + cold 半全场 combos. High variance, small stake.

**推荐单关 (Recommended Single):** Best single edge across all risk classes. Can be conservative (CORE/STANDARD, edge>0.02, solid fundamentals) or cold-bet (VOLATILE, edge>0.05, contrarian angle). Kelly-sized, max 5u. Always explain the rationale direction (稳 vs 搏冷).

**Correlation avoidance:** same-team same-direction, 勝+总进球>3, 平平+总进球0-1球.

---

## L7: 历史回测层 (BACKTEST)

After matchday: Brier Score, Log Loss, calibration error per decile (well-calibrated: error<0.05), edge realization rate, model-vs-market accuracy.

Scoreline metrics: exact score accuracy, goal difference accuracy, total goals bucket accuracy.

Market efficiency test: if avg(model_edge) > avg(actual_profit) consistently → market efficient → reduce model weight. If converge over 20+ → model well-calibrated.

Include backtest status in every report.

---

## L8: 自学习层 (SELF-LEARN)

### Error Classification
model_error (right direction, wrong magnitude) · data_error (stale/missing info) · black_swan (red card, VAR, own goal, penalty miss) · market_smarter (market adjusted, model lagged) · unknown.

### Weight Evolution
Every 5 matches: `new_weight = 0.7×old + 0.3×softmax(-Brier_per_model)`.

### Parameter Recalibration (per tournament stage)
HFA, λ scaling (xG→goals conversion), draw adjustment, motivation factors.

### Pattern Library
- group_stage_R3_simultaneous: correlated outcomes, higher scoring
- knockout_ET: underdogs force ET > win in 90 minutes
- high_heat (>30°C): 2H scoring drops ~20%
- heavy_rain: long shots↑, total goals↓, upsets more likely
- early_goal (<15'): +1.2 total goals on average
- derby_match: form↓, cards↑, scoring slightly lower

### Feedback Loop
Trace error→specific layer→apply correction. Validated edge→increase confidence. Lucky outcome→do not update. Append `analysis/learning-log.json`.
