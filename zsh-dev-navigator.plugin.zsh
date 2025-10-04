DEV_BASE_DIR="${ZSH_DEV_NAVIGATOR_DIR:-$HOME/dev}"

dev() {
    local open_in_vscode=false
    local create_directory=false
    local project_name=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--open)
                open_in_vscode=true
                shift
                ;;
            -c|--create)
                create_directory=true
                shift
                ;;
            *)
                project_name="$1"
                shift
                ;;
        esac
    done

    if [ -z "$project_name" ]; then
        if [[ -d "$DEV_BASE_DIR" ]]; then
            if command -v fzf >/dev/null 2>&1; then
                project_name=$(ls -1 "$DEV_BASE_DIR" | fzf --height 40% --border --prompt="Select project: " --bind "ctrl-c:abort" --header="Press ESC to open root dev folder")
            fi
        else
            echo "DEV base directory not found: $DEV_BASE_DIR" >&2
            return 1
        fi
    fi

    if [ -z "$project_name" ]; then
        local target_dir="$DEV_BASE_DIR"
    else
        local target_dir="$DEV_BASE_DIR/$project_name"
    fi

    if [ ! -d "$target_dir" ]; then
        if [ "$create_directory" = true ]; then
            echo "Creating new project directory: $target_dir"
            mkdir -p "$target_dir"
            if [ $? -ne 0 ]; then
                echo "Failed to create directory: $target_dir" >&2
                return 1
            fi
        else
            echo "Project not found: $target_dir" >&2
            return 1
        fi
    fi

    if [ "$open_in_vscode" = true ]; then
        if command -v code >/dev/null 2>&1; then
            code "$target_dir"
            echo "Opened in VS Code: $target_dir"
        else
            echo "VS Code (code command) not found." >&2
            return 1
        fi
    else
        cd "$target_dir" || return 1
    fi
}

_dev_completions() {
    local context state line
    local -a options project_dirs project_names

    _arguments -C \
        '(-o --open)'{-o,--open}'[Open directory in VS Code]' \
        '(-c --create)'{-c,--create}'[Create directory if it does not exist]' \
        '*:project:->projects' && return 0

    case $state in
        projects)
            if [[ -d "$DEV_BASE_DIR" ]]; then
                project_dirs=("$DEV_BASE_DIR"/*(N/))
                project_names=("${(@)project_dirs:t}")
                _describe 'projects' project_names
            fi
            ;;
    esac
}

compdef _dev_completions dev
