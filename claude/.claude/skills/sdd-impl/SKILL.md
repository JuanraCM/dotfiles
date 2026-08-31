---
name: sdd-impl
description: Use this skill when the user asks to implement a task from a specific spec file
argument-hint: "[<spec path>] [<task number>]"
model: sonnet 
effort: medium
context: fork
---

# sdd-impl

Execute a single task from a spec file.

## Input

$ARGUMENTS

**IMPORTANT**
    The user should provide a spec path and a task ID. Example: `/path/to/spec T<N>`.
    Ask for clarification in case params are missing.

## Instructions

1. Read the spec file
2. Find the specified task
3. Review **Why**, **What**, **Constraints** and **Current State** sections for context
4. Implement exactly what the task describes, nothing more
5. Run the **Verify** step

## Guidelines

- Only this task, ignore others in the spec
- Only files listed in the task
- No drive-by refactors or additions
- Follow constraints strictly
- Write tests if specified
- Do NOT add dependencies unless specified in **Constraints**

## Output

Report:

- What was implemented
- Files created or modified
- Verification result (pass/fail)
- Any issues or blockers

Suggest next steps:

- If more tasks remain: Read spec and implement T<N+1>
- If all tasks complete: Run **Done** section commands
