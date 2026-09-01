#!/usr/bin/env bash
set -euo pipefail

slug="${1:?Usage: archive_spec.sh <task-slug>}"
spec_dir="./.specs/active/$slug"

[ -d "$spec_dir" ] || { echo "No such spec: $slug" >&2; exit 1; }

archive_dir="./.specs/archive"

[ -d "$archive_dir" ] || mkdir -p "$archive_dir"
mv "$spec_dir" "$archive_dir/"

echo "Spec archived successfully"
