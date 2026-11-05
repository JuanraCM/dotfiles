#!/usr/bin/env bash
# Non-interactive twin of herdr-worktrunk's picker (workspace mode): create or
# switch a worktree through worktrunk, so its hooks run, then register it as a
# native herdr worktree workspace. No fzf, no popup.
#
# Usage: create_worktree.sh <branch> [--base <ref>] [--cwd <path>] [--focus] [--yes] [--no-hooks]
#
#   <branch>     new branch name, existing local/remote branch, or worktrunk
#                shortcut (^, -, pr:N, mr:N, PR/MR URL)
#   --base       base for a NEW branch (default: worktrunk's default branch;
#                accepts shortcuts, e.g. @ for the current branch)
#   --cwd        repo to operate on (default: $PWD)
#   --focus      focus the herdr workspace (default: open it in the background)
#   --yes        auto-approve worktrunk hook prompts (only with user consent)
#   --no-hooks   skip worktrunk hooks
#
# Prints a JSON summary on stdout; worktrunk/hook output goes to stderr.

set -euo pipefail

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

name="" base="" cwd=$PWD focus=--no-focus wt_extra=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --base) base=${2:?--base needs a value}; shift 2 ;;
    --cwd) cwd=${2:?--cwd needs a value}; shift 2 ;;
    --focus) focus=--focus; shift ;;
    --yes) wt_extra+=(--yes); shift ;;
    --no-hooks) wt_extra+=(--no-hooks); shift ;;
    -*) die "unknown option: $1" ;;
    *) [[ -z $name ]] || die "unexpected argument: $1"; name=$1; shift ;;
  esac
done
[[ -n $name ]] || die "usage: create_worktree.sh <branch> [--base <ref>] [--cwd <path>] [--focus] [--yes] [--no-hooks]"

command -v wt >/dev/null || die "worktrunk (wt) not found on PATH"
command -v jq >/dev/null || die "jq not found on PATH"
herdr=${HERDR_BIN_PATH:-herdr}

cd "$cwd" || die "cannot cd into $cwd"
git rev-parse --git-dir >/dev/null 2>&1 || die "$cwd is not a git repository"

# Same rules as the plugin: shortcuts and existing refs are switched to (wt
# creates the worktree if missing); anything else is a new branch.
is_shortcut() { case $1 in '^'|'-'|*:*) return 0 ;; *) return 1 ;; esac; }
ref_exists() {
  git show-ref --quiet --verify "refs/heads/$1" || git show-ref --quiet --verify "refs/remotes/$1"
}

if is_shortcut "$name" || ref_exists "$name"; then
  [[ -n $base ]] && printf 'warning: %s already exists, ignoring --base %s\n' "$name" "$base" >&2
  wtargs=(switch "$name")
else
  wtargs=(switch --create "$name")
  [[ -n $base ]] && wtargs+=(--base "$base")
fi

# stdin from /dev/null so an approval prompt fails fast instead of hanging.
if ! result=$(wt "${wtargs[@]}" ${wt_extra[@]+"${wt_extra[@]}"} --no-cd --format=json </dev/null); then
  die "wt ${wtargs[*]} failed (see output above). If it asked to approve hooks, re-run with --yes once the user agrees, or --no-hooks."
fi

branch=$(jq -r '.branch // empty' <<<"$result" 2>/dev/null || true)
action=$(jq -r '.action // empty' <<<"$result" 2>/dev/null || true)
wtpath=$(jq -r '.path // empty' <<<"$result" 2>/dev/null || true)
[[ -n $wtpath ]] || die "worktrunk returned no worktree path for: $name"

label=${branch:-$name}
[[ -n $branch && $branch != "$name" ]] && label="$branch ($name)"

summary() {
  jq -n --arg branch "${branch:-$name}" --arg path "$wtpath" --arg action "$action" \
    --arg workspace "${1:-}" --arg pane "${2:-}" --arg note "${3:-}" \
    'def nonempty: if . == "" then null else . end;
     {branch: $branch, path: $path, action: $action,
      workspace_id: ($workspace | nonempty), pane_id: ($pane | nonempty), note: ($note | nonempty)}'
}

# Outside herdr there is nothing to register; the worktree itself is done.
if ! source_json=$("$herdr" worktree list --cwd "$PWD" --json 2>/dev/null); then
  summary "" "" "herdr not reachable; worktree created but not opened as a workspace"
  exit 0
fi

# Register under the repo's root workspace (a linked worktree's own workspace is
# rejected by `worktree open`), pre-creating it with the repo name as label.
repo_root=$(jq -r '.result.source.repo_root' <<<"$source_json")
root_workspace_id=$(jq -r '.result.source.source_workspace_id // empty' <<<"$source_json")
if [[ -z $root_workspace_id ]]; then
  repo_label=$(jq -r '.result.source.repo_name // empty' <<<"$source_json")
  repo_label=${repo_label%.git}
  [[ -n $repo_label ]] && "$herdr" workspace create --cwd "$repo_root" --label "$repo_label" --no-focus >/dev/null
fi

# The main checkout is the root workspace itself; don't relabel it to the branch.
label_args=(--label "$label")
if [[ "$(cd "$wtpath" && pwd -P)" == "$(cd "$repo_root" && pwd -P)" ]]; then
  label_args=()
fi

open_json=$("$herdr" worktree open --cwd "$repo_root" --path "$wtpath" ${label_args[@]+"${label_args[@]}"} "$focus" --json) \
  || die "herdr worktree open failed for $wtpath"

summary "$(jq -r '.result.workspace.workspace_id // empty' <<<"$open_json")" \
  "$(jq -r '.result.root_pane.pane_id // empty' <<<"$open_json")"
