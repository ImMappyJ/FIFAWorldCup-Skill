# FIFAWorldCup.skill

> 专业级世界杯足球赛事智能分析系统 — Claude Code 技能，8 层研究架构，中国体育彩票全市场覆盖。

[![Skill](https://img.shields.io/badge/Claude%20Code-Skill-3B82F6)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-green)](./LICENSE)
[![Version](https://img.shields.io/badge/Version-2.0-8B5CF6)](./.claude/skills/world-cup-betting-pro/SKILL.md)

---

## 这是什么？

**FIFAWorldCup.skill** 是一个运行在 Claude Code 中的专业足球研究技能。输入比赛对阵，它自动执行 8 层分析流水线 — 从数据采集、模型计算、市场边缘检测到投注建议——最终输出中文 Markdown 报告 + 多页面可视化 HTML + 移动端优化 PNG 长图。

> ⚠️ **免责声明：仅限娱乐与研究用途，不构成任何投资建议。系统不承诺盈利，始终保持概率思维。**

---

## 架构

```
                    ┌─────────────────────────┐
                    │     FIFAWorldCup.skill   │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
   📊 数据层                  🧠 模型层                  💰 市场层
   多源采集+质量评分          6模型集成                  5大彩种+边缘检测
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
   🎬 剧本层                  ⚠️ 风险层                  📈 可视化层
   4剧本/场                   5维风险+Kelly+3票型       多页面HTML+PNG长图
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
              📚 历史回测层    ⇄    🔄 自学习层
```

### 8 层详解

| 层 | 名称 | 能力 |
|:---|:-----|:-----|
| **L1** | 数据层 | 中国体育彩票赔率、FIFA 官方数据、ELO、xG/xGA、天气、伤停、小组形势、旅途奔波 |
| **L2** | 模型层 | ELO + Poisson(xG驱动) + Form Power(衰减权重) + Motivation + Group Strategy(8种场景) + Travel Fatigue(6级距离) → 6模型集成 |
| **L3** | 市场层 | 5大彩种赔率去水、边缘计算、赔率走势、庄家陷阱检测、半全场9宫格分解、跨市场一致性 |
| **L4** | 剧本层 | 4种比赛剧本(统治/对攻/爆冷/僵局) × 小组压力 × 未来对手策略 × 旅途不平等 |
| **L5** | 风险层 | 5+维度风险评分(天气/轮换/疲劳/市场陷阱/模型不确定/小组压力) → Kelly仓位 × 3票型 |
| **L6** | 可视化层 | 暗色主题多页面HTML + 共享CSS + 移动端优化PNG长图(750px@2x) |
| **L7** | 历史回测层 | Brier Score · Log Loss · 校准度 · 边缘实现率 · 市场效率检验 |
| **L8** | 自学习层 | 误差分解 · 权重演化 · 参数重校准 · 模式库 · 学习日志 |

---

## 核心特性

- 🧠 **6 模型集成** — ELO、Poisson(xG)、状态功率、动机、小组策略、旅途疲劳
- 🇨🇳 **中国体育彩票全覆盖** — 胜平负 · 让球胜平负 · 半全场(9宫格) · 比分 · 总进球数(0~7+)
- 📊 **边缘检测** — 去水公平概率、模型边缘、市场陷阱标记、赔率走势分析
- 🎯 **三种投注票型** — 保守串关 + 激进搏冷 + 推荐单关(稳/搏冷方向)
- 🌐 **多页面可视化** — 赛事预览 → 单场深度分析 → 投注建议终页
- 📱 **移动端优化** — 750px@2x 全页 PNG 长图，手机一图到底
- 💬 **中文输出** — 所有报告、HTML、分析文本默认中文
- 🔄 **持续学习** — 赛后回测、误差溯源、权重自动演化

---

## 快速开始

### 前提条件

- [Claude Code](https://claude.ai/code) (VS Code / JetBrains / 终端)
- Microsoft Edge 或 Node.js(Puppeteer) — 用于 HTML → PNG 截图

### 安装

```bash
# 1. 克隆仓库到 Claude Code 的 skills 目录
git clone https://github.com/ImMappyJ/FIFAWorldCup.git

# 2. 将 skill 注册到 Claude Code (选择以下一种)

# 方式 A: 项目级 (仅当前项目可用)
mkdir -p .claude/skills
cp -r FIFAWorldCup/.claude/skills/world-cup-betting-pro .claude/skills/

# 方式 B: 用户级 (所有项目可用)
mkdir -p ~/.claude/skills
cp -r FIFAWorldCup/.claude/skills/world-cup-betting-pro ~/.claude/skills/

# 3. 安装 Puppeteer (可选，用于生成 PNG)
npx puppeteer browsers install chrome
```

### 即刻使用

在 Claude Code 中直接对话：

```
> 分析明天世界杯的四场比赛

> 分析 Brazil vs France，England vs Argentina。
  包含天气、伤病、阵容、赔率走势、比分预测、总进球、让球、半全场。
  生成保守串关 + 激进搏冷 + 推荐单关。

> 只分析 Germany vs Spain 这场。
```

---

## 输出示例

```
analysis/2026-06-20-1430/
├── report.md                         # 中文完整分析报告 (权威)
├── html/
│   ├── 赛事预览.html                  # 概览仪表盘 + 紧凑对阵卡
│   ├── Brazil-vs-France.html         # 🇧🇷⚔️🇫🇷 完整深度分析
│   ├── England-vs-Argentina.html     # 🏴󠁧󠁢󠁥󠁮󠁧󠁿⚔️🇦🇷 完整深度分析
│   └── 投注建议.html                  # 三票型 + 风险分析 + 总结
└── images/
    ├── 赛事预览.png                   # 一屏纵览 (750px@2x)
    ├── Brazil-vs-France.png
    ├── England-vs-Argentina.png
    └── 投注建议.png
```

### 预览效果

| 页面 | 内容 |
|:---|:-----|
| **赛事预览** | 比赛数/CORE数/边缘数/风险等级统计卡片 + 每场紧凑对阵卡(队名、核心概率、最佳边路、风险标签) + 跳转链接 |
| **单场分析** | 小组形势表 + 奔波距离 + 天气 + 胜平负概率条(三色) + 4剧本叙事 + 比分热力图(6×6) + 进球概率卡片(0~7+) + 半全场9宫格 + 五大市场赔率表 |
| **投注建议** | 保守串关(绿色) + 激进搏冷(红色) + 推荐单关(蓝色) + 风险摘要 + 执行总结 |

---

## 目录结构

```
.claude/skills/world-cup-betting-pro/
├── SKILL.md                    # 入口 — 核心身份 + 规则 + 指针
├── README.md                   # 技能级文档
├── templates/
│   └── report.md               # 多页面 HTML 架构规范
├── references/
│   ├── architecture.md         # 8层完整详细规范 (含公式+阈值)
│   └── checklist.md            # 执行清单 (9阶段)
├── assets/
│   ├── style.css               # 共享 CSS — 307行完整样式系统
│   └── schema.json             # 比赛数据 JSON Schema
├── scripts/
│   ├── screenshot.ps1          # Edge 无头截图 (Windows)
│   └── export.js               # Puppeteer 截图 (跨平台)
└── examples/
    ├── single-match-analysis.md   # 单场深度分析示例
    └── matchday-ticket-builder.md  # 多场 + 三票型示例
```

---

## 技术亮点

### 模型层 — 6 模型集成

| 模型 | 权重 | 说明 |
|:---|:---|:-----|
| Poisson (xG) | 35% | λ 由加权 xG 驱动，完整比分矩阵 |
| ELO | 15% | HFA=100(中立场=0)，淘汰赛平局×0.3 |
| Form Power | 15% | 衰减权重 [.30,.22,.16,.12,.08,.05,.04,.02,.01,.00] |
| Motivation | 10% | 必须赢(1.15)~已淘汰(0.82) 6级调整 |
| Group Strategy | 10% | 8种场景: 已出线/需平局/必须赢/等他人/淘汰/KO首回合/KO保领先 |
| Travel Fatigue | 8% | 6档: <50km(1.0)~>1000km(0.85)，累计>2000km额外×0.95 |
| H2H | 7% | 历史交锋加权 |

### 市场层 — 中国体育彩票 5 市场

```
边缘 = 模型概率 - 公平概率 (去水后)
强边缘 > 5%  |  中等边缘 > 2%  |  无边缘 > -2%  |  负边缘 ≤ -2%
```

### 风险层 — 3 种票型

| 票型 | 风险级别 | 腿数 | 综合赔率 | 风格 |
|:---|:---|:---|:---|:---|
| 🟢 保守串关 | CORE | 3-4 | 2.00-5.00 | 稳健基础，跨市场分散 |
| 🔴 激进搏冷 | VOLATILE | 2-3 | 5.00-15.00+ | 冷门下狗+极端比分+冷半全场 |
| 🔵 推荐单关 | CORE~VOLATILE | 1 | 任意 | 最佳单边，附稳/搏冷方向说明 |

---

## 核心原则

- 📊 永不声称确定性 — 始终标注不确定性边界
- 🇨🇳 中国体育彩票专用格式 — 不转换亚盘/欧赔术语
- 💬 中文默认 — 仅保留 ELO/xG/Kelly 等专有名词英文
- 🔗 每个数字可溯源至具体模型或数据源
- 🎨 HTML 零外部依赖 — 共享 CSS 单源内联策略
- 🎯 保守默认 — 高风险时明确警示，极端风险不推荐投注

---

## 贡献

欢迎提 Issue 和 PR。主要方向：
- 新模型集成 (如 Bayesian 动态权)
- 更多数据源接入
- 可视化增强
- 移动端布局优化

---

## License

MIT © 2026
