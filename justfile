# Validate a lesson file — auto-detect hs or py by extension
# Usage: just validate lessons/network-theory/graph-intro/lesson.hs
validate path:
    #!/usr/bin/env bash
    case "{{path}}" in
        *.hs) runghc "{{path}}" ;;
        *.py) uv run python "{{path}}" ;;
        *) echo "Unknown file type: {{path}}"; exit 1 ;;
    esac

# Export a lesson directory to LaTeX.
# lang: hs | py | '' (default = both)
# lesson_dir: e.g. lessons/network-theory/graph-intro
# Outputs: <lesson_dir>/exports/lesson-hs.tex and/or lesson-py.tex
export-latex lesson_dir lang='':
    #!/usr/bin/env bash
    set -e
    # Wrap lesson source in a fenced code block; pandoc emits listings-compatible LaTeX.
    export_via_pandoc() {
        local lang="$1" src="$2" out="$3"
        printf '%s\n' "~~~{.${lang}}" "$(cat "${src}")" '~~~' \
            | pandoc -f markdown -t latex -o "${out}" --syntax-highlighting=idiomatic
    }
    do_export() {
        case "$1" in
            hs) export_via_pandoc haskell "{{lesson_dir}}/lesson.hs" "{{lesson_dir}}/exports/lesson-hs.tex" ;;
            py) export_via_pandoc python "{{lesson_dir}}/lesson.py" "{{lesson_dir}}/exports/lesson-py.tex" ;;
        esac
    }
    case "{{lang}}" in
        hs|py) do_export "{{lang}}" ;;
        '') do_export hs; do_export py ;;
        *) echo "lang must be hs, py, or empty (both)"; exit 1 ;;
    esac

# Publish a file as a public GitHub Gist (requires gh CLI authenticated)
publish-gist path:
    gh gist create "{{path}}" --public

# Render the Quarto site locally
render:
    quarto render

# Live preview with hot reload
preview:
    quarto preview

# Deploy to GitHub Pages (creates/updates gh-pages branch)
publish:
    quarto publish gh-pages

# Scaffold a new lesson from templates
# Usage: just new-lesson network-theory graph-intro
lesson topic name:
    mkdir -p lessons/{{topic}}/{{name}}/exports
    cp templates/lesson.hs  lessons/{{topic}}/{{name}}/lesson.hs
    cp templates/lesson.py  lessons/{{topic}}/{{name}}/lesson.py
    cp templates/lesson.qmd lessons/{{topic}}/{{name}}/lesson.qmd
    echo "Created lessons/{{topic}}/{{name}}/"
