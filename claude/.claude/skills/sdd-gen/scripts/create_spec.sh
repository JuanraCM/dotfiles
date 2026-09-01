#!/usr/bin/env bash
set -euo pipefail

slug="${1:?Usage: create_spec.sh <task-slug>}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template="$script_dir/../assets/spec-template.md"

spec_dir="./.specs/active/$slug"
spec_path="$spec_dir/spec.md"

mkdir -p "$spec_dir"
[ -f "$spec_dir/spec.md" ] || cp "$template" "$spec_path"

echo "Spec created at $spec_path"
