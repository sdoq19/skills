---
name: duan-yongping-invest-skill
description: Skill for generating Duan Yongping style investment memos. Evaluates businesses based on Duan's core axioms: right business + right people + right price + time.
# EXTENDED METADATA
github_url: https://github.com/zhaoxiao5511/duan-yongping-invest-skill
github_hash: 0d317103fe4bb6a8ce02ca77fb5d9688dd940ee3
version: 1.0.0
created_at: 2026-01-23
dependencies: []
---

# Skill: Duan Yongping Investing Memo (大道-段永平投资备忘录)

## Core axioms
- Treat stock as ownership of a business; evaluate the business first (future cashflows matter most). 〔ref: book〕
- Good result = right business + right people + right price + time. 〔ref: book〕

## What this skill does
Given a company/ticker and any materials provided, produce a Duan-style investment memo:
1) Business (right business)
2) People (right people)
3) Price (right price / margin of safety)
4) Time (long-term holding logic)
Plus: key assumptions, falsification triggers, and a tracking checklist.

## Hard constraints (Do NOT)
- Do NOT output short-term price prediction, K-line/technical analysis, macro timing calls.
- Do NOT "fill gaps" with guesses. If data is missing, list missing items explicitly.
- If the business cannot be explained in plain words (how it makes money, why it can keep making money), classify as outside circle of competence -> PASS.

## Workflow
### Step 0 — Input normalization
Ask for/confirm: company, region, business segments, revenue drivers, competitors, your holding horizon, your required return.

### Step 1 — Right business (quality first)
Answer:
- How does it make money? What are the unit economics?
- What is the moat? (brand, switching costs, network effects, cost advantage, regulation, distribution, culture)
- Is the business understandable and durable for 10+ years?
- What could permanently impair the business? (tech shifts, regulation, channel dependency, trust collapse)

### Step 2 — Right people (culture & incentives)
Answer:
- Management incentives aligned with shareholders?
- Capital allocation record (buybacks, M&A discipline, reinvestment ROI)
- Evidence of strong culture & long-term thinking

### Step 3 — Right price (valuation & margin of safety)
Produce:
- A valuation range (base/bull/bear) using simple drivers.
- Identify what must be true for current price to be attractive.
- Margin-of-safety rule: demand a buffer against errors/unknowns.
- Output "Buy zone / Watch zone / No-touch zone" + why.

### Step 4 — Time (holding logic)
Define:
- Why this is a "buy to keep" not "buy to sell".
- What milestones indicate thesis is playing out.
- What would make you sell? (thesis broken, valuation absurd, better opportunity)

## Output format (strict)
Use the template in templates/memo.md.