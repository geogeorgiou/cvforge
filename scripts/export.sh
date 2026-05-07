#!/usr/bin/env bash
# Export .tex file(s) to PDF under dist/, mirroring the src/ directory structure.
#
# Usage:
#   ./scripts/export.sh src/2026/FE-CV-May2026.tex   # single file
#   ./scripts/export.sh --all                          # all .tex files under src/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"

if ! command -v pdflatex &>/dev/null; then
  echo "Error: pdflatex not found. Install MacTeX:"
  echo "  brew install --cask mactex"
  echo "  # or: brew install basictex"
  exit 1
fi

compile_file() {
  local tex_file="$1"
  local abs_tex
  abs_tex="$(cd "$(dirname "$tex_file")" && pwd)/$(basename "$tex_file")"

  # Derive output path: src/2026/foo.tex → dist/2026/foo.pdf
  local rel_path="${abs_tex#$REPO_ROOT/src/}"
  local rel_dir
  rel_dir="$(dirname "$rel_path")"
  local out_dir="$DIST_DIR/$rel_dir"
  local pdf_name
  pdf_name="$(basename "$tex_file" .tex).pdf"

  mkdir -p "$out_dir"

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  echo "Compiling: $tex_file"

  for pass in 1 2; do
    if ! pdflatex \
        -interaction=nonstopmode \
        -halt-on-error \
        -output-directory="$tmpdir" \
        "$abs_tex" &>/dev/null; then
      echo ""
      echo "--- pdflatex error (pass $pass) ---"
      pdflatex \
        -interaction=nonstopmode \
        -output-directory="$tmpdir" \
        "$abs_tex" 2>&1 | grep -E "^(! |l\.|Error)" || true
      echo "-----------------------------------"
      echo "FAIL: $tex_file"
      return 1
    fi
  done

  cp "$tmpdir/$(basename "$tex_file" .tex).pdf" "$out_dir/$pdf_name"
  echo "  → $out_dir/$pdf_name"
}

if [[ "${1:-}" == "--all" ]]; then
  find "$REPO_ROOT/src" -name "*.tex" | while read -r f; do
    compile_file "$f"
  done
else
  if [[ -z "${1:-}" ]]; then
    echo "Usage: $0 <file.tex>"
    echo "       $0 --all"
    exit 1
  fi
  compile_file "$1"
fi
