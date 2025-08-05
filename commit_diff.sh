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
  -a, --last-commit      Use last commit changes instead of staged changes for {diff}
  -h, --help             Show this help message

If the template is not specified but exactly one .tpl is found, it will be used.
Replacements:
  {locale} → English/Russian or your value
  {branch} → current git branch
  {diff}   → git diff --cached or last commit patch if -a specified
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
#   4 - diff file path
# Outputs:
#   Writes expanded template to stdout
#######################################
expand_template() {
  local file="$1"
  local locale="$2"
  local branch="$3"
  local diff_file="$4"

  awk -v locale="$locale" -v branch="$branch" -v diff_file="$diff_file" '
    function print_diff() {
      while ((getline d < diff_file) > 0) print d
      close(diff_file)
    }
    {
      line=$0
      gsub("{locale}", locale, line)
      gsub("{branch}", branch, line)
      if (index(line, "{diff}")) {
        sub("{diff}", "", line)
        print line
        print_diff()
      } else {
        print line
      }
    }
  ' "$file"
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
  local use_last_commit="false"

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
      -a | --last-commit)
        use_last_commit="true"
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

  local tpl_files=()
  if [[ -z "$template" ]]; then
    readarray -t tpl_files < <(find "$script_dir" -maxdepth 1 -type f -name "*.$template_ext")
    if [[ ${#tpl_files[@]} -eq 1 ]]; then
      template="$(basename "${tpl_files[0]}")"
    elif [[ ${#tpl_files[@]} -eq 0 ]]; then
      err "No *.$template_ext templates found in $script_dir"
    else
      echo "Error: Multiple template files found in $script_dir:"
      local f
      for f in "${tpl_files[@]}"; do
        echo "  - $(basename "$f")"
      done
      err "Please specify one of them using -t|--template."
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

  # Use a temp file for diff content
  local diff_file
  diff_file=$(mktemp)
  trap 'rm -f "$diff_file"' EXIT

  if [[ "$use_last_commit" == "true" ]]; then
    (cd "$git_root" && git show --pretty= --no-color) > "$diff_file"
    if [[ ! -s "$diff_file" ]]; then
      err "No changes found in the last commit."
    fi
  else
    (cd "$git_root" && git diff --cached) > "$diff_file"
    if [[ ! -s "$diff_file" ]]; then
      err "No staged changes to include in diff."
    fi
  fi

  expand_template "$template_path" "$locale_str" "$branch" "$diff_file"
}

main "$@"
