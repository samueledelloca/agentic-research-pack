#!/usr/bin/env bash
# Agentic Research Pack - installer
#
# Usage:
#   ./setup.sh link     # symlink skills (and agents, if any) into ~/.claude/  [default]
#   ./setup.sh unlink   # remove the symlinks this pack created
#   ./setup.sh          # defaults to `link`
#
# Skills are SYMLINKED (not copied) so a later `git pull` updates them in place,
# exactly like the researcher-pack. This pack also ships a .claude-plugin/ manifest,
# so it can alternatively be installed through the Claude Code plugin system
# (see README -> Install). The two paths are independent; use either.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_TARGET="$HOME/.claude/skills"
AGENTS_TARGET="$HOME/.claude/agents"
MODE="${1:-link}"

bold()   { printf "\033[1m%s\033[0m\n" "$*"; }
info()   { printf "  [i]  %s\n" "$*"; }
action() { printf "  [+]  %s\n" "$*"; }
warn()   { printf "  [!]  %s\n" "$*"; }

link_dir() {
    # link_dir <source-parent> <target-parent>
    local src_parent="$1" tgt_parent="$2"
    [ -d "$src_parent" ] || return 0
    mkdir -p "$tgt_parent"
    for src in "$src_parent"/*/; do
        [ -d "$src" ] || continue
        local name; name="$(basename "$src")"
        local dst="$tgt_parent/$name"
        if [ -L "$dst" ]; then
            action "$name (relinked)"; ln -sfn "${src%/}" "$dst"
        elif [ -e "$dst" ]; then
            warn "$name (existing non-symlink, skipping - remove it manually to relink)"
        else
            action "$name (linked)"; ln -sfn "${src%/}" "$dst"
        fi
    done
}

unlink_dir() {
    local src_parent="$1" tgt_parent="$2"
    [ -d "$src_parent" ] || return 0
    for src in "$src_parent"/*/; do
        [ -d "$src" ] || continue
        local name; name="$(basename "$src")"
        local dst="$tgt_parent/$name"
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "${src%/}" ]; then
            rm -f "$dst"; action "$name (unlinked)"
        fi
    done
}

detect_companions() {
    # Neutral info: these are optional adapters, never required. See the skill's
    # Dependencies table. Absence is fine; the skill falls back.
    bold "Optional companions (used if present, never required)"
    if ls "$HOME"/.claude/skills/research-companion/SKILL.md >/dev/null 2>&1; then
        info "research-companion: found (ideation -> this pack executes the PURSUE idea)"
    else
        info "research-companion: not found (you can still start from a paper or an idea)"
    fi
    if ls "$HOME"/.claude/skills/*/SKILL.md 2>/dev/null | grep -qiE 'academic|writing' ; then
        info "academic-writing-agents: found (report drafting / review in Stage 7)"
    else
        info "academic-writing-agents: not found (the skill runs the same standards in a subagent)"
    fi
    info "scite MCP: configure as an MCP server for the literature audit; else WebSearch/WebFetch is the fallback"
}

run_link() {
    bold "Agentic Research Pack - link mode"
    printf "  repo: %s\n\n" "$REPO"
    bold "Skills -> $SKILLS_TARGET"
    link_dir "$REPO/skills" "$SKILLS_TARGET"
    if [ -d "$REPO/agents" ]; then
        printf "\n"; bold "Agents -> $AGENTS_TARGET"; link_dir "$REPO/agents" "$AGENTS_TARGET"
    fi
    printf "\n"; detect_companions
    printf "\n"; action "Done. Open a new session; the skill triggers on research-execution requests."
}

run_unlink() {
    bold "Agentic Research Pack - unlink mode"
    unlink_dir "$REPO/skills" "$SKILLS_TARGET"
    [ -d "$REPO/agents" ] && unlink_dir "$REPO/agents" "$AGENTS_TARGET"
    action "Removed this pack's symlinks."
}

case "$MODE" in
    link)   run_link ;;
    unlink) run_unlink ;;
    *) echo "Usage: $0 [link|unlink]" >&2; exit 2 ;;
esac
