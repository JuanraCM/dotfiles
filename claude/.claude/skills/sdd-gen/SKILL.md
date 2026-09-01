---
name: sdd-gen
description: Use this skill when the user asks to generate a spec for AI-assisted implementation
argument-hint: "[<description>]"
model: opus
effort: high
---

# sdd-gen

Generate a specification for AI-assisted implementation.

## Input 

$ARGUMENTS

## Instructions

1. Create a spec by calling the following script:

    ```bash
    bash ./scripts/create_spec.sh <spec-slug>
    ```

2. Fill in the output spec file based on the input provided

## Guidelines

**Sizing tasks:**
- Group changes that must ship together (schema + types + migration = 1 task)
- Split at natural commit boundaries
- If a task might hit context limits, it's too big

**Writing good verify steps:**
- Prefer commands over manual checks
- Manual checks should be specific: "Click X, see Y" not "verify it works"
- Include the unhappy path when relevant

**Context section tips:**
- List only files the agent will actually touch or need to reference
- "Patterns to follow" with a concrete example file beats abstract description
- Capture decisions so the agent doesn't re-litigate them

**When to skip sections:**
- Trivial features (< 3 files): inline everything, skip Context
- Bug fixes: Why + What + single Task may suffice
- Spikes/exploration: just Why + What + time box

## Scaling

**Small (1-3 files):** Abbreviated spec, 1-2 tasks, ~20 lines
**Medium (4-10 files):** Full spec, 2-4 tasks, ~40 lines  
**Large (10+ files):** Consider splitting into multiple specs

## Output

After writing:
1. Spec saved to `.specs/<slug>.md`
2. Review for completeness. Could a new agent implement T1 with no other context?
3. To implement: Read `.specs/<slug>.md` and implement T1
