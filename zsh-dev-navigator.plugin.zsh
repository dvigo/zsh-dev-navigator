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
                # Show only directories if using -c or -cg flags
                if [ "$create_directory" = true ]; then
                    project_name=$(find "$DEV_BASE_DIR" -maxdepth 1 -type d ! -path "$DEV_BASE_DIR" -exec basename {} \; | fzf --height 40% --border --prompt="Select directory: " --bind "ctrl-c:abort" --header="Press ESC to open root dev folder")
                else
                    # Show both files and directories for regular navigation
                    project_name=$(ls -1 "$DEV_BASE_DIR" | fzf --height 40% --border --prompt="Select project: " --bind "ctrl-c:abort" --header="Press ESC to open root dev folder")
                fi
            else
                # Fallback when fzf is not available
                echo "Available projects in $DEV_BASE_DIR:"
                if [ "$create_directory" = true ]; then
                    # Show only directories for -c or -cg flags
                    find "$DEV_BASE_DIR" -maxdepth 1 -type d ! -path "$DEV_BASE_DIR" -exec basename {} \; | sort
                else
                    # Show both files and directories for regular navigation
                    ls -1 "$DEV_BASE_DIR" | sort
                fi
                echo -n "Enter project/file name (or press Enter for root directory): "
                read -r project_name
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

    # Check if target is a file
    if [ -f "$target_dir" ]; then
        # Prevent -c and -cg flags from working with files
        if [ "$create_directory" = true ]; then
            echo "Error: Cannot use -c or -cg flags with files. Target is a file: $target_dir" >&2
            return 1
        fi
        
        if [ "$open_in_editor" = true ]; then
            # Open file in editor without execution
            "$EDITOR_CMD" "$target_dir"
            echo "Opened file in $EDITOR_CMD: $target_dir"
            cd "$(dirname "$target_dir")" || return 1
            return 0
        else
            # Ask for confirmation before executing file
            echo "Target is a file: $target_dir"
            echo -n "Do you want to execute this file? [y/N]: "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                cd "$(dirname "$target_dir")" || return 1
                "$target_dir"
                return $?
            else
                echo "File execution cancelled."
                return 0
            fi
        fi
    fi
    
    # Handle non-existent targets
    if [ ! -e "$target_dir" ]; then
        if [ "$create_directory" = true ]; then
            # Creating new directory
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
        elif [ "$open_in_editor" = true ]; then
            # Handle -o flag with non-existent files
            echo "File does not exist: $target_dir"
            echo -n "Do you want to create this file? [y/N]: "
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                # Create parent directory if needed
                local parent_dir="$(dirname "$target_dir")"
                if [ ! -d "$parent_dir" ]; then
                    mkdir -p "$parent_dir" || {
                        echo "Failed to create parent directory: $parent_dir" >&2
                        return 1
                    }
                fi
                # Create empty file and open in editor
                touch "$target_dir" || {
                    echo "Failed to create file: $target_dir" >&2
                    return 1
                }
                "$EDITOR_CMD" "$target_dir"
                echo "Created and opened file in $EDITOR_CMD: $target_dir"
                cd "$(dirname "$target_dir")" || return 1
                return 0
            else
                echo "File creation cancelled."
                return 0
            fi
        else
            # Handle non-existent files/directories without flags
            # Try to determine if it's intended to be a file based on extension or context
            if [[ "$project_name" == *.* ]]; then
                # Has file extension, likely a file
                echo "File does not exist: $target_dir"
                echo -n "Do you want to create this file? [y/N]: "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    # Create parent directory if needed
                    local parent_dir="$(dirname "$target_dir")"
                    if [ ! -d "$parent_dir" ]; then
                        mkdir -p "$parent_dir" || {
                            echo "Failed to create parent directory: $parent_dir" >&2
                            return 1
                        }
                    fi
                    # Create empty file
                    touch "$target_dir" || {
                        echo "Failed to create file: $target_dir" >&2
                        return 1
                    }
                    echo "File created: $target_dir"
                    echo -n "Do you want to execute this file? [y/N]: "
                    read -r exec_response
                    if [[ "$exec_response" =~ ^[Yy]$ ]]; then
                        cd "$(dirname "$target_dir")" || return 1
                        "$target_dir"
                        return $?
                    else
                        cd "$(dirname "$target_dir")" || return 1
                        return 0
                    fi
                else
                    echo "File creation cancelled."
                    return 0
                fi
            else
                # No file extension, likely a directory
                echo "Project/directory not found: $target_dir" >&2
                echo "Use -c flag to create a new directory: dev -c $project_name"
                return 1
            fi
        fi
    fi

    # Handle directory navigation (only for directories at this point)
    if [ "$open_in_editor" = true ]; then
        "$EDITOR_CMD" "$target_dir"
        echo "Opened in $EDITOR_CMD: $target_dir"
        cd "$target_dir" || return 1
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
                # Check if we're using -c or -cg flags (only show directories)
                if [[ ${words[(I)(-c|--create|-cg|--create-git)]} -gt 0 ]]; then
                    project_dirs=("$DEV_BASE_DIR"/*(N/))
                    project_names=("${(@)project_dirs:t}")
                    _describe 'directories' project_names
                else
                    # Show both files and directories for regular navigation
                    local all_items=("$DEV_BASE_DIR"/*(N))
                    local item_names=("${(@)all_items:t}")
                    _describe 'projects' item_names
                fi
            fi
            ;;
    esac
}

compdef _dev_completions dev
