---
name: sdd-archive
description: Use this skill when the user asks to archive a completed spec
argument-hint: "[<spec-slug>]"
model: sonnet
effort: low
---

# sdd-archive

Archive a completed spec.

## Input

$ARGUMENTS

**IMPORTANT**
    The user should provide a spec slug. Ask for clarification if missing, or infer from context if only one active spec exists.

## Instructions

1. Archive the spec by calling the following script:

    ```bash
    bash ./scripts/archive_spec.sh <spec-slug>
    ```

2. Confirm the move to the user

## Output

Report:
- Spec archived, from `.specs/active/<slug>` to `.specs/archive/<slug>`
- Any error (e.g. spec not found)
