PLUGIN_DIR="${0:A:h}"
DEV_CONFIG_FILE="$PLUGIN_DIR/config"

DEV_BASE_DIR=$(grep -E '^\s*dev_directory\s*=' "$DEV_CONFIG_FILE" | cut -d '=' -f2- | xargs | sed "s|~|$HOME|")
EDITOR_CMD=$(grep -E '^\s*editor\s*=' "$DEV_CONFIG_FILE" | cut -d '=' -f2- | xargs)
AUTO_GIT_INIT=$(grep -E '^\s*auto_git_init\s*=' "$DEV_CONFIG_FILE" | cut -d '=' -f2- | xargs)

dev() {
    local open_in_editor=false
    local create_directory=false
    local git_init=false
    local project_name=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--open)
                open_in_editor=true
                shift
                ;;
            -c|--create)
                create_directory=true
                shift
                ;;
            -cg|--create-git)
                create_directory=true
                git_init=true
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

    local target_dir
    if [ -z "$project_name" ]; then
        target_dir="$DEV_BASE_DIR"
    else
        target_dir="$DEV_BASE_DIR/$project_name"
    fi

    if [ ! -d "$target_dir" ]; then
        if [ "$create_directory" = true ]; then
            echo "Creating new project directory: $target_dir"
            mkdir -p "$target_dir" || {
                echo "Failed to create directory: $target_dir" >&2
                return 1
            }
            
            # Initialize git repository if -cg flag was used OR if auto_git_init is enabled
            if [ "$git_init" = true ] || [ "$AUTO_GIT_INIT" = "true" ]; then
                echo "Initializing git repository..."
                (cd "$target_dir" && git init) || {
                    echo "Warning: Failed to initialize git repository" >&2
                }
            fi
        else
            echo "Project not found: $target_dir" >&2
            return 1
        fi
    fi

    if [ "$open_in_editor" = true ]; then
        "$EDITOR_CMD" "$target_dir"
        echo "Opened in $EDITOR_CMD: $target_dir"
    else
        cd "$target_dir" || return 1
    fi
}

_dev_completions() {
    local context state line
    local -a options project_dirs project_names

    _arguments -C \
        '(-o --open)'{-o,--open}'[Open directory in default editor]' \
        '(-c --create)'{-c,--create}'[Create directory if it does not exist]' \
        '(-cg --create-git)'{-cg,--create-git}'[Create directory and initialize git repository]' \
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
