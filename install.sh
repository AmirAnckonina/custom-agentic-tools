#!/usr/bin/env bash
#
# install.sh — install capability bundles from this repo into your live ~/.claude.
#
# Each capability lives in capabilities/<name>/ as a "bundle" manifest (the set of
# agents/commands/skills it installs) plus a README.md guide, side by side. Items
# are SYMLINKED, so the repo stays the single source of truth: edit a file here (or
# from any Claude session) and it's live, and `git commit && git push` is your
# version control + backup. Idempotent.
#
# Usage:
#   ./install.sh list                      # show available bundles
#   ./install.sh <bundle> [<bundle>...]    # install one or more bundles
#   ./install.sh <skill-name>              # install a single skill, e.g. gh-ops
#   ./install.sh uninstall                 # remove every link this repo created
#
#   CLAUDE_DIR=path/to/.claude ./install.sh <bundle>   # project-level install
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/claude"
CAPS="$REPO/capabilities"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

meta() { grep -m1 "^# $1:" "$2" | sed "s/^# $1: //" || true; }

list_bundles() {
  echo "Available capabilities:"
  for d in "$CAPS"/*/; do
    local name="$(basename "$d")"
    printf "  %-18s %s\n" "$name" "$(meta desc "$d/bundle")"
  done
  echo
  echo "Install:  ./install.sh <capability> [<capability>...]   |   ./install.sh <skill-name>"
}

# ensure CLAUDE_DIR/<kind> is a real dir (convert any legacy whole-dir symlink)
ensure_dir() {
  local d="$CLAUDE_DIR/$1"
  [ -L "$d" ] && rm "$d"
  mkdir -p "$d"
}

link_item() {
  local item="$1"                 # e.g. skills/gh-ops or agents/architect.md
  local from="$SRC/$item"
  local to="$CLAUDE_DIR/$item"
  [ -e "$from" ] || { echo "  ! missing in repo: $item"; return; }
  ensure_dir "${item%%/*}"
  if [ -L "$to" ]; then rm "$to"
  elif [ -e "$to" ]; then mv "$to" "$to.backup.$(date +%s)"; echo "  backed up existing $item"
  fi
  ln -s "$from" "$to"
  echo "  linked $item"
}

install_bundle() {
  local name="$1" f="$CAPS/$1/bundle"
  echo "== $name — $(meta desc "$f")"
  while IFS= read -r line; do
    line="$(echo "${line%%#*}" | xargs)"     # strip comment, trim
    [ -n "$line" ] && link_item "$line"
  done < "$f"
  local req; req="$(meta requires "$f")"
  if [ -n "$req" ]; then echo "  requires: $req"; fi
}

# resolve a bare name (e.g. "gh-ops") to its claude/{agents,commands,skills} path
resolve_item() {
  local name="$1"
  for kind in skills agents commands; do
    [ -d "$SRC/$kind/$name" ] && { echo "$kind/$name"; return 0; }
    [ -f "$SRC/$kind/$name.md" ] && { echo "$kind/$name.md"; return 0; }
  done
  return 0
}

install_target() {
  local name="$1"
  if [ -f "$CAPS/$name/bundle" ]; then
    install_bundle "$name"
    return
  fi
  local item; item="$(resolve_item "$name")"
  if [ -n "$item" ]; then
    echo "== $name (single item)"
    link_item "$item"
  else
    echo "Unknown capability or skill: $name (try: ./install.sh list)"; exit 1
  fi
}

# remove only links that point back into this repo's payload — never real files
uninstall() {
  local removed=0
  for kind in agents commands skills; do
    local d="$CLAUDE_DIR/$kind"
    [ -d "$d" ] || continue
    for entry in "$d"/*; do
      [ -e "$entry" ] || [ -L "$entry" ] || continue
      if [ -L "$entry" ] && [[ "$(readlink "$entry")" == "$SRC/"* ]]; then
        rm "$entry"; echo "  removed $kind/$(basename "$entry")"; removed=$((removed+1))
      fi
    done
    rmdir "$d" 2>/dev/null || true   # drop the dir if now empty
  done
  echo "Removed $removed link(s)."
}

mkdir -p "$CLAUDE_DIR"
[ $# -eq 0 ] && { list_bundles; exit 0; }
case "$1" in
  list)      list_bundles ;;
  uninstall) uninstall ;;
  *)         for t in "$@"; do install_target "$t"; done ;;
esac
