---
name: herdr-worktree
description: Use this skill when the user asks to create (or switch to) a git worktree. Creates it through worktrunk so hooks run, and opens it as a herdr worktree workspace, with no picker or popup.
argument-hint: "<branch> [--base <ref>]"
model: sonnet
effort: low
---

# herdr-worktree

Create or switch to a git worktree without user interaction. Does the same as the herdr-worktrunk plugin's
`worktrunk.open` action in workspace mode, minus the fzf picker.

## Input

$ARGUMENTS

**IMPORTANT**
    The user should provide a branch name (or a worktrunk shortcut: `pr:N`, `mr:N`, a PR/MR URL, `^`, `-`).
    If missing, infer a short kebab-case name from the task at hand. Ask only if there is nothing to infer from.

## Instructions

1. Pick the arguments:
    - `<branch>`: an existing local/remote branch is checked out. Any other name creates a new branch.
    - `--base <ref>`: only for new branches. Leave it out to branch from the default branch. Pass `--base @` when the
      user says "from the current branch" / "from here".
    - `--cwd <path>`: the repo to use. Defaults to the current directory.
    - `--focus`: only if the user asks to jump to / focus the new workspace. By default it opens in the background.

2. Run the script:

    ```bash
    bash ./scripts/create_worktree.sh <branch> [--base <ref>] [--cwd <path>] [--focus]
    ```

3. If it fails because worktrunk needs **hook approval**, show the user the commands worktrunk listed and ask
   whether to approve them. If they agree, re-run with `--yes`. If they want to skip hooks, re-run with `--no-hooks`.
   Never pass `--yes` without asking first.

## Output

The script prints a JSON summary on stdout: `branch`, `path`, `action` (`created` / `existing`), `workspace_id`,
`pane_id`, and an optional `note`. Tell the user the branch and worktree path in one short line. If the user
wants follow-up work done in the worktree, use `path` as the working directory.
