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
    do_export() {
        case "$1" in
            hs) pandoc "{{lesson_dir}}/lesson.hs" \
                    -t latex -o "{{lesson_dir}}/exports/lesson-hs.tex" --listings ;;
            py) uv run jupyter nbconvert --to latex \
                    "{{lesson_dir}}/lesson.py" \
                    --output-dir "{{lesson_dir}}/exports/" \
                    --output "lesson-py" ;;
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
