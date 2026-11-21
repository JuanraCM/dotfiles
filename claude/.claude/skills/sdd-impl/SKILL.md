---
name: sdd-impl
description: Use this skill when the user asks to implement a task, or all tasks, from a specific spec file
argument-hint: "<spec path> --task <N> | --auto"
model: sonnet 
effort: medium
context: fork
---

# sdd-impl

Execute one task (`--task`) or every task (`--auto`) from a spec file.

## Input

$ARGUMENTS

**IMPORTANT**
    The user should provide a spec path and a mode:
    - `/path/to/spec --task <N>`: implement task T<N> only
    - `/path/to/spec --auto`: implement all tasks in one run
    Ask for clarification in case params are missing.

## Instructions

1. Read `AGENTS.md` at the project root (and any nested `AGENTS.md` in directories you will touch). If none exists, continue without it
2. Read the spec file
3. Review **Why**, **What**, **Constraints** and **Current State** sections for context
4. Pick tasks by mode:
    - `--task N`: only T<N>
    - `--auto`: every task, in order
5. For each task:
    1. Implement exactly what the task describes, nothing more
    2. Run its **Verify** step
    3. `--auto` only: if Verify passes, commit this task alone as `T<N>: <task title>`. If it fails, stop. Do not commit or start the next task.
6. `--auto` only: after the last task, run the **Done** section commands

## Guidelines

- Only the current task, ignore others in the spec
- Only files listed in the task
- No drive-by refactors or additions
- Follow constraints strictly
- Write tests if specified
- Do NOT add dependencies unless specified in **Constraints**
- `--task` never commits. `--auto` makes one commit per task, nothing staged outside the task's files

## Output

Report:

- What was implemented, per task
- Files created or modified
- Verification result (pass/fail), per task
- `--auto`: commit hash per task, **Done** result
- Any issues or blockers

Suggest next steps:

- `--task`, more tasks remain: `<spec path> --task <N+1>`
- `--task`, all tasks complete: Run **Done** section commands
- `--auto` stopped on a failure: fix the cause, then `<spec path> --task <N>` for the failed task and onward
