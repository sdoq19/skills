---
name: self-improving-agent
description: Enable Claude Code to continuously learn, adapt, and improve from session observations. Combines instinct-based learning with autonomous loop patterns for self-evolving agent capabilities. Use when setting up continuous learning workflows or autonomous agent systems.
priority: high
version: 1.0.0
---

# Self-Improving Agent

An autonomous learning system that enables Claude Code to continuously improve through observation, pattern extraction, and skill evolution.

## Core Philosophy

> The best agent is one that learns from its own experiences. Every session is an opportunity to capture reusable patterns and evolve capabilities.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    SELF-IMPROVING AGENT                          │
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │  OBSERVE    │───▶│  LEARN      │───▶│  EVOLVE     │          │
│  │  Sessions   │    │  Patterns   │    │  Skills     │          │
│  └─────────────┘    └─────────────┘    └─────────────┘          │
│         │                  │                  │                  │
│         ▼                  ▼                  ▼                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │  Hooks      │    │  Instincts  │    │  Commands   │          │
│  │  (100%      │    │  (Atomic    │    │  Skills     │          │
│  │   capture)  │    │   patterns) │    │  Agents     │          │
│  └─────────────┘    └─────────────┘    └─────────────┘          │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  FEEDBACK LOOP                                          │    │
│  │  User corrections → Confidence adjustment → Better output│    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Observation Layer (100% Capture via Hooks)

Hooks fire deterministically on every tool use, capturing:
- User prompts and intents
- Tool calls and outcomes
- Errors and resolutions
- User corrections

```json
// ~/.claude/settings.json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{ "type": "command", "command": "~/.claude/skills/self-improving-agent/hooks/observe.sh" }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{ "type": "command", "command": "~/.claude/skills/self-improving-agent/hooks/observe.sh" }]
    }]
  }
}
```

### 2. Instinct System (Atomic Learning)

Instincts are small, learned behaviors with confidence scoring:

```yaml
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
domain: "code-style"
source: "session-observation"
scope: project
---

# Prefer Functional Style

## Action
Use functional patterns over classes when appropriate.

## Evidence
- Observed 5 instances of functional pattern preference
- User corrected class-based approach on 2025-01-15
```

**Confidence Scoring:**

| Score | Meaning | Behavior |
|-------|---------|----------|
| 0.3 | Tentative | Suggested but not enforced |
| 0.5 | Moderate | Applied when relevant |
| 0.7 | Strong | Auto-approved |
| 0.9 | Near-certain | Core behavior |

### 3. Evolution Pipeline

```
Instincts (atomic)
    │
    ├── Cluster similar instincts
    │
    ▼
Evolved Artifacts
    ├── Commands (/new-feature, /fix-bug)
    ├── Skills (testing-workflow, refactor-patterns)
    └── Agents (code-reviewer, refactor-specialist)
```

### 4. Project Scoping

| Pattern Type | Scope | Examples |
|-------------|-------|---------|
| Framework conventions | **project** | "Use React hooks", "Django REST patterns" |
| File structure | **project** | "Tests in `__tests__/`" |
| Security practices | **global** | "Validate input", "Sanitize SQL" |
| Git practices | **global** | "Conventional commits" |

## Autonomous Loop Patterns

### Pattern 1: Sequential Pipeline

```bash
#!/bin/bash
set -e

# Step 1: Implement
claude -p "Implement the feature with TDD."

# Step 2: De-sloppify (cleanup)
claude -p "Review changes. Remove redundant tests, excessive checks."

# Step 3: Verify
claude -p "Run build + lint + tests. Fix failures."

# Step 4: Commit
claude -p "Create conventional commit."
```

### Pattern 2: Continuous Loop with Context Bridge

```bash
# SHARED_TASK_NOTES.md bridges context between iterations
claude -p "Read SHARED_TASK_NOTES.md. Continue work. Update notes at end."
```

### Pattern 3: Quality-Gated Loops

```
┌──────────────────────────────────────────────────┐
│  ITERATION                                        │
│                                                   │
│  1. Plan (Opus) → Deep reasoning                  │
│  2. Implement (Sonnet) → Fast execution           │
│  3. Review (Opus) → Quality gate                  │
│  4. Fix (Sonnet) → Address issues                 │
│  5. Verify → All checks pass                      │
│                                                   │
│  FAIL? → Capture context → Retry with learning    │
│  PASS? → Commit → Next iteration                  │
└──────────────────────────────────────────────────┘
```

## Quick Start

### 1. Enable Observation

Add hooks to `~/.claude/settings.json` (see Observation Layer above).

### 2. Initialize Directory Structure

```bash
mkdir -p ~/.claude/homunculus/{instincts/{personal,inherited},evolved/{agents,skills,commands},projects}
```

### 3. Use Learning Commands

| Command | Description |
|---------|-------------|
| `/instinct-status` | Show learned instincts with confidence |
| `/evolve` | Cluster instincts into skills/commands |
| `/instinct-export` | Export instincts to file |
| `/instinct-import <file>` | Import instincts |
| `/promote [id]` | Promote project instincts to global |
| `/projects` | List all known projects |

## Learning Signals

**Confidence INCREASES when:**
- Pattern repeatedly observed
- User doesn't correct behavior
- Similar instincts from other sources agree

**Confidence DECREASES when:**
- User explicitly corrects behavior
- Pattern not observed for extended time
- Contradicting evidence appears

## Best Practices

### Do's

1. **Let patterns emerge naturally** - Don't force instincts
2. **Trust high-confidence instincts** - They've proven reliable
3. **Review low-confidence suggestions** - May need refinement
4. **Promote cross-project patterns** - Universal behaviors become global
5. **Export and share** - Team learning multiplies value

### Don'ts

1. **Don't override user corrections** - They're the ground truth
2. **Don't skip verification** - Quality gates prevent regressions
3. **Don't ignore context** - Project scope matters
4. **Don't over-evolve** - Some instincts should stay atomic
5. **Don't hoard learnings** - Share with team

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Infinite loop without exit | Wastes resources | Add max-runs, max-cost, or completion signal |
| No context bridge | Each iteration starts fresh | Use SHARED_TASK_NOTES.md |
| Retrying same failure | No learning | Capture error context for next attempt |
| Negative instructions | Downstream quality effects | Add separate cleanup pass |
| All agents in one context | Author bias | Separate reviewer from author |

## File Structure

```
~/.claude/homunculus/
├── identity.json           # Your profile
├── projects.json           # Project registry
├── observations.jsonl      # Global observations
├── instincts/
│   ├── personal/           # Auto-learned global
│   └── inherited/          # Imported global
├── evolved/
│   ├── agents/             # Generated agents
│   ├── skills/             # Generated skills
│   └── commands/           # Generated commands
└── projects/
    └── <project-hash>/     # Project-scoped data
        ├── observations.jsonl
        ├── instincts/
        └── evolved/
```

## Integration with Other Skills

| Skill | Integration |
|-------|-------------|
| `security-review` | Learn security patterns as global instincts |
| `verification-loop` | Quality gates feed into learning |
| `skill-from-masters` | Expert methods become high-confidence instincts |
| `brainstorming` | Creative patterns captured for reuse |

## Privacy

- Observations stay **local**
- Project-scoped instincts isolated per project
- Only **patterns** (instincts) can be exported — not raw observations
- No actual code or conversation content is shared
- You control what gets exported and promoted

---

*Self-improving agents: learning from every interaction, evolving with every session.*
