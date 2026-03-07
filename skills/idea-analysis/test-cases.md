# Idea Analysis — Test Cases

These test cases cover the key trigger scenarios for the idea-analysis skill.
Use them to validate that the skill produces high-quality, consistent outputs.

---

## Test Case 1 — Greenfield Product Idea (Clear)

**Prompt:**
> I want to build a mobile app that helps independent personal trainers manage their clients —
> scheduling, workout plans, progress tracking, and payments. All in one place.

**What to evaluate:**
- Skill should proceed without clarifying questions (persona and problem are clear)
- Should identify strong existing competitors (Trainerize, TrueCoach, PT Distinction, Mindbody)
- Willingness to Pay should be Medium-High with rationale (trainers monetize their time)
- Complexity should be L or XL (multi-feature, payments integration)
- Recommendation: likely Pivot or Go-with-focus (crowded market, needs differentiation angle)
- Handoff Block YAML should be complete

---

## Test Case 2 — Feature Addition to Existing Product (Clear)

**Prompt:**
> We have a B2B SaaS project management tool used by software teams. I want to add an AI
> feature that automatically writes standup summaries from GitHub commits and Jira tickets
> every morning and posts them to Slack.

**What to evaluate:**
- Skill should proceed without clarifying questions
- Should identify competitors/analogues (Geekbot, Standuply, Linear's auto-summaries, GitHub Copilot for PRs)
- Business Impact should note strong retention/stickiness effect
- Complexity: M (well-defined integrations, LLM summarization is solved)
- Recommendation: likely Go
- Handoff Block should include Slack + GitHub + Jira as constraints

---

## Test Case 3 — Vague One-Liner (Triggers Clarifying Questions)

**Prompt:**
> I want to build something for restaurants.

**What to evaluate:**
- Skill MUST ask 2-3 clarifying questions before proceeding — not jump to analysis
- Questions should focus on: target user (owner? customer? staff?), problem space, new vs existing
- Should NOT produce a full analysis until clarification is provided
- Questions should be focused and numbered, not open-ended rambling

---

## Test Case 4 — Change to Existing Product (Reduction / Simplification)

**Prompt:**
> Our e-commerce platform has a 7-step checkout flow. I want to reduce it to a single page
> checkout to improve conversion rates. Is this worth doing?

**What to evaluate:**
- Should recognize this as an optimization change, not a new product
- Should cite checkout abandonment research and industry benchmarks (search for real data)
- Competitors section should reference best-in-class (Shopify, Stripe, Apple Pay one-click)
- Complexity: S or M
- Recommendation: strong Go (well-validated pattern)
- Confidence: High

---

## Test Case 5 — Ambitious / Risky Idea (Tests No-Go / Pivot)

**Prompt:**
> I want to create a new social network for professional athletes — like LinkedIn but for sports.
> Agents, scouts, sponsors, and athletes all in one platform.

**What to eval:**
- Should surface cold-start problem and network effect chicken-and-egg risk
- Should find prior attempts (Ballr, Locker Room, Overtime, existing LinkedIn use by athletes)
- Feasibility should flag XL complexity and high market risk
- Recommendation: likely Pivot or No-Go with a focused alternative suggested
- Handoff Block should still be present (even for No-Go/Pivot) with the refined framing

---

## Grading Dimensions (qualitative)

For each test case, assess:

1. **Trigger behavior** — Did the skill ask questions when it should? Skip them when it shouldn't?
2. **Research quality** — Are competitors real and relevant? Are claims sourced?
3. **Rating calibration** — Are WTP / Complexity / Confidence ratings reasoned, not default?
4. **Recommendation quality** — Is it decisive? Does it acknowledge the counter-argument?
5. **Handoff Block completeness** — Is the YAML complete with no placeholder text?
6. **No filler** — Does the output avoid vague praise or hedge-everything language?
