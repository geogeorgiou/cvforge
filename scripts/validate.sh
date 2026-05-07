#!/usr/bin/env bash
# Validate a .tex file by running pdflatex in nonstop/draft mode.
# Auxiliary files are written to a temp dir and cleaned up afterwards.
# Exit code 0 = clean, non-zero = errors found.

set -euo pipefail

TEX_FILE="${1:-}"

if [[ -z "$TEX_FILE" ]]; then
  echo "Usage: $0 <file.tex>"
  exit 1
fi

if [[ ! -f "$TEX_FILE" ]]; then
  echo "Error: file not found: $TEX_FILE"
  exit 1
fi

# Ensure pdflatex is available
if ! command -v pdflatex &>/dev/null; then
  echo "Error: pdflatex not found. Install MacTeX:"
  echo "  brew install --cask mactex"
  echo "  # or: brew install basictex"
  exit 1
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

ABS_TEX="$(cd "$(dirname "$TEX_FILE")" && pwd)/$(basename "$TEX_FILE")"

echo "Validating: $TEX_FILE"

# Run twice to resolve refs; suppress output and capture errors
if pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -output-directory="$TMPDIR" \
    "$ABS_TEX" &>/dev/null && \
   pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -output-directory="$TMPDIR" \
    "$ABS_TEX" &>/dev/null; then
  echo "OK: $TEX_FILE compiled without errors."
else
  # Re-run visibly so the user sees the actual errors
  echo ""
  echo "--- pdflatex output ---"
  pdflatex \
    -interaction=nonstopmode \
    -output-directory="$TMPDIR" \
    "$ABS_TEX" 2>&1 | grep -E "^(! |l\.|Error|Warning)" || true
  echo "-----------------------"
  echo "FAIL: $TEX_FILE has errors."
  exit 1
fi
