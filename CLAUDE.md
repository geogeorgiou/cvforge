# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A version-controlled LaTeX CV. Sources live under `src/YEAR/` (e.g. `src/2026/FE-CV-May2026.tex`). Compiled PDFs are exported to `dist/` (gitignored).

## Prerequisites

LaTeX must be installed to compile or validate. On macOS:

```bash
brew install --cask mactex   # full TeX Live (~4 GB), recommended
# or
Install via website       # https://www.tug.org/mactex/mactex-download.html
```

After install, ensure `/Library/TeX/texbin` is on `$PATH`.

## Commands

```bash
# Validate a .tex file (syntax check — runs pdflatex in draft/nonstop mode)
./scripts/validate.sh src/2026/FE-CV-May2026.tex

# Export a .tex file to dist/ as PDF
./scripts/export.sh src/2026/FE-CV-May2026.tex

# Export all .tex files under src/
./scripts/export.sh --all
```

## Project layout

```
src/
  YEAR/
    *.tex          # one file per CV variant / date
scripts/
  validate.sh      # lint/syntax check via pdflatex nonstop mode
  export.sh        # compile to PDF → dist/YEAR/
dist/              # gitignored compiled PDFs
```

## LaTeX conventions used in this repo

- **Two-column layout** via `paracol` (0.30 / 0.70 split). Left = sidebar, right = main body.
- **Section headings** use custom commands `\xmlsection` (main) and `\xmlsidesection` (sidebar) that render `<SectionName/>` style headings in accent blue (`#1F4E79`).
- **Job entries**: `\jobentry{Title}{Date}{Company}{Role}` followed by a `cvitems` list and an optional `\techstack{...}` line.
- `fontawesome5` is optional; the preamble stubs missing icon commands so the file compiles without it.
- Run `pdflatex` **twice** on any file to resolve cross-references and hyperlinks correctly.

## Adding a new CV variant

1. Copy the latest `.tex` from `src/YEAR/` into the appropriate year folder.
2. Update the filename to reflect the role/date (e.g. `BE-CV-Jun2026.tex`).
3. Adjust content; run `./scripts/validate.sh` before committing.
4. Run `./scripts/export.sh` to produce the PDF in `dist/`.
