# Quiver

Advanced mathematics for cybersecurity — network theory, complexity theory, ML, and foundations. Published as a Quarto static wiki on GitHub Pages.

## Purpose

Each "lesson" is a self-contained mathematical concept presented in both Haskell and Python, validated by running the code, exported to LaTeX, and published via Quarto. GitHub Gists act as shareable snapshots of individual lesson files.

## Tech Stack

| Tool | Role |
|------|------|
| `runghc` | Run Haskell lesson files |
| `uv` | Python project management and running Python lessons |
| `just` | Operational recipes (validate, export, publish) |
| `quarto` | Static site generation → GitHub Pages |
| `pandoc` | Haskell → LaTeX (ships with Quarto) |
| `jupyter nbconvert` | Python → LaTeX |
| `gh` | Publish gists, interact with GitHub |

## Directory Layout

```
lessons/
  <topic>/           # foundations | network-theory | complexity-theory | ml
    <lesson-name>/
      lesson.hs      # Haskell implementation
      lesson.py      # Python implementation
      lesson.qmd     # Quarto page (imports LaTeX exports for PDF; inline code for HTML)
      exports/
        lesson-hs.tex
        lesson-py.tex
templates/
  lesson.hs          # Haskell skeleton
  lesson.qmd         # Quarto skeleton
_quarto.yml          # Site config
index.qmd            # Homepage
justfile             # All recipes
pyproject.toml       # uv dependencies
```

## Lesson Workflow

```
1. Plan          — decide topic, name, and mathematical content
2. Create        — just new-lesson <topic> <name>
3. Implement     — edit lessons/<topic>/<name>/lesson.hs and lesson.py
4. Validate      — just validate lessons/<topic>/<name>/lesson.hs
                   just validate lessons/<topic>/<name>/lesson.py
5. Export LaTeX  — just export-latex lessons/<topic>/<name>
6. Write page    — edit lessons/<topic>/<name>/lesson.qmd (fill title, motivation, inline snippets)
7. Preview       — just preview
8. Publish gist  — just publish-gist lessons/<topic>/<name>/lesson.hs
                   just publish-gist lessons/<topic>/<name>/lesson.py
9. Deploy wiki   — just publish
```

## Just Recipes

```bash
just validate <path>                  # run .hs via runghc or .py via uv
just export-latex <lesson_dir>        # export both hs and py to LaTeX
just export-latex <lesson_dir> hs     # export Haskell only
just export-latex <lesson_dir> py     # export Python only
just new-lesson <topic> <name>        # scaffold from templates
just render                           # build site locally → _site/
just preview                          # live-reload dev server
just publish                          # deploy to GitHub Pages (gh-pages branch)
just publish-gist <path>              # create public gist for a file
```

## Constraints

- Haskell files must run cleanly via `runghc` with no build step.
- Python files must run cleanly via `uv run python <file>`.
- LaTeX exports are generated artifacts — do not edit them by hand.
- The repo is public (required for GitHub Pages on a free account).
- `uv.lock` is committed for reproducible Python environments.
