
usage() {
  echo "Usage: $0 <search-path> [--dry-run]"
  echo "  Finds and optionally deletes broken symlinks pointing to /nix/store."
  exit 1
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
fi

SEARCH_PATH="$1"
DRY_RUN=false

if [[ "${2:-}" == "--dry-run" ]]; then
  DRY_RUN=true
elif [[ -n "${2:-}" ]]; then
  usage
fi


if $DRY_RUN; then
  ACTION="Would delete"
  DELETE_CMD=":"
else
  ACTION="Deleting"
  DELETE_CMD="rm"
fi


echo "Searching for broken symlinks to /nix/store in: $SEARCH_PATH"
$DRY_RUN && echo "(Dry-run mode: no files will be deleted)"

# shellcheck disable=SC2016
fd -t l -u '' "$SEARCH_PATH" --mount  \
  -x bash -c '
    ACTION="$1"; DELETE_CMD="$2"; shift 2
    for path; do
      target=$(readlink "$path")
      if [[ "$target" == /nix/store/* && ! -e "$target" ]]; then
        echo "$ACTION $path -> $target"
        $DELETE_CMD "$path"
      fi
    done
  ' _ "$ACTION" "$DELETE_CMD" {}
