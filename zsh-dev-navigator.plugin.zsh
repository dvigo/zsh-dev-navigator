DEV_BASE_DIR="${ZSH_DEV_NAVIGATOR_DIR:-$HOME/dev}"

dev() {
  if [ -z "$1" ]; then
    cd "$DEV_BASE_DIR" || return 1
    return 0
  fi

  local target_dir="$DEV_BASE_DIR/$1"

  if [ -d "$target_dir" ]; then
    cd "$target_dir" || return 1
  else
    echo "Project not found: $target_dir" >&2
    return 1
  fi
}

_dev_completions() {
  local -a project_dirs
  if [[ -d "$DEV_BASE_DIR" ]]; then
    project_dirs=("$DEV_BASE_DIR"/*(N/))
    local -a project_names=("${(@)project_dirs:t}")
    _describe 'projects' project_names
  fi
}

compdef _dev_completions dev
