#!/bin/bash

set -e

script_path="$(readlink -f "${BASH_SOURCE[0]}")"
script_dir="$(cd "$(dirname "$script_path")" && pwd)"
git_root="$(git rev-parse --show-toplevel 2>/dev/null)"

#######################################
# Print usage/help message.
# Arguments:
#   None
#######################################
usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  -t, --template NAME    Template name (*.tpl) from the script directory
  -l, --locale LOCALE    Locale: en (default) or ru. If not found in map, passed as is.
  -L, --list             List all available templates
  -h, --help             Show this help message

If the template is not specified but exactly one .tpl is found, it will be used.
Replacements:
  {locale} → English/Russian or your value
  {branch} → current git branch
  {diff}   → git diff --cached
EOF
}

#######################################
# Print error message and exit with code 1.
# Arguments:
#   1 - error message
#######################################
err() {
  echo "Error: $1" >&2
  exit 1
}

#######################################
# List all available template files (*.tpl).
# Arguments:
#   None
#######################################
list_templates() {
  find "$script_dir" -maxdepth 1 -type f -name "*.$template_ext" -printf "%f\n"
}

#######################################
# Get current git branch name.
# Arguments:
#   None
# Outputs:
#   Writes branch name to stdout
#######################################
get_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

#######################################
# Expand template file, replacing placeholders.
# Arguments:
#   1 - template file path
#   2 - locale string
#   3 - branch name
# Outputs:
#   Writes expanded template to stdout
#######################################
expand_template() {
  local file="$1"
  local locale="$2"
  local branch="$3"

  awk -v locale="$locale" -v branch="$branch" -v diff="$(cd "$git_root" && git diff --cached)" '
    {
			line=$0
			gsub(/\{locale\}/, locale, line)
			gsub(/\{branch\}/, branch, line)
			if (line ~ /{diff}/) {
				sub(/{diff}/, "", line)
				print line
				print diff
			} else {
				print line
			}
    }' "$file"
}

#######################################
# Main function: parses arguments, selects template,
# prepares replacements, runs expansion.
# Arguments:
#   All command-line arguments
#######################################
main() {
	if [[ -z "$git_root" ]]; then
			err "Not in a git repository."
	fi

  template_ext="tpl"
  declare -A locale_map=(["en"]="English" ["ru"]="Russian")

  local template=""
  local locale="en"
  local mode="run"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -t | --template)
        template="$2"
        shift 2
        ;;
      -l | --locale)
        locale="$2"
        shift 2
        ;;
      -L | --list)
        mode="list"
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  done

  if [[ "$mode" == "list" ]]; then
    list_templates
    exit 0
  fi

  # Template check and selection
  local tpl_files=()
  if [[ -z "$template" ]]; then
    readarray -t tpl_files < <(find "$script_dir" -maxdepth 1 -type f -name "*.$template_ext")
    if [[ ${#tpl_files[@]} -eq 1 ]]; then
      template="$(basename "${tpl_files[0]}")"
    elif [[ ${#tpl_files[@]} -eq 0 ]]; then
      err "No *.$template_ext templates found in $script_dir"
    else
      err "Template (-t) is not specified. Multiple are available: $(printf '%s, ' "${tpl_files[@]}")"
    fi
  fi

  local template_path="$script_dir/$template"
  if [[ ! -f "$template_path" ]]; then
    err "Template $template not found in $script_dir"
  fi

  # Accept locale from map or use as is if not found
  local locale_str
  if [[ -n "${locale_map[$locale]}" ]]; then
    locale_str="${locale_map[$locale]}"
  else
    locale_str="$locale"
  fi

  local branch
  branch="$(get_current_branch)"

  expand_template "$template_path" "$locale_str" "$branch" # | xclip -selection clipboard

  echo 'Wrap the answer in triple backticks (```).'
}

main "$@"
