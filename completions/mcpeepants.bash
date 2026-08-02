# Bash completion for mcpeepants (get-server-config.sh).
#
# Install (one of):
#   source /path/to/mcpeepants/completions/mcpeepants.bash
#   cp completions/mcpeepants.bash ~/.local/share/bash-completion/completions/mcpeepants
#   cp completions/mcpeepants.bash /etc/bash_completion.d/mcpeepants
#
# Server keys are derived DYNAMICALLY from servers.json at completion time
# (jq, with a grep fallback), so the menu never goes stale as servers are added.
# There is no embedded catalog — servers.json is the single source of truth
# (the inverse of skilldozer, which is manifest-free; mcpeepants *is* its manifest).
#
# LOCKSTEP: the flag set below is frozen to the arg parsing in get-server-config.sh.
# If a future task adds/renames a flag there, update this list — and the zsh/fish
# files — identically. There is no shared source of truth the shells can import.
# Flags are advertised in long form; the -h/-l short aliases stay valid at runtime
# but are not advertised (mirrors skilldozer decision 20).
_mcpeepants_completion() {
    local cur prev words cword
    # _init_completion (from the bash-completion package) sets cur/prev/words/cword.
    # Fall back to COMP_WORDS when the package is absent (minimal Linux, macOS
    # default bash) — otherwise `_init_completion || return` silently offers NOTHING.
    # SC2317 flags the fallback branch as "unreachable"; it is a false positive
    # (the branch runs whenever the helper is missing).
    _init_completion 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        cword=$COMP_CWORD
        COMPREPLY=()
    }

    # Value-taking flags: route the value slot away from server-key completion.
    #   --search <query> -> free-text query -> offer NOTHING (return 0, empty COMPREPLY).
    #   --shell <name>    -> closed enum      -> offer "bash zsh fish" (the supported shells).
    # --completions is a boolean toggle (no value). --shell implies --completions at runtime.
    case "$prev" in
        --search) return 0 ;;
        --shell) COMPREPLY=($(compgen -W "bash zsh fish" -- "$cur")); return 0 ;;
    esac

    # Flag completion when the current token starts with '-' (long-form only —
    # decision 20). -h/-l are valid at runtime but deliberately not advertised.
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--all --list --search --help --completions --shell" -- "$cur"))
        return 0
    fi

    # Server keys straight from servers.json (canonical keys, one per line).
    # Errors swallowed: a missing/unreadable servers.json or absent jq degrades to
    # "no keys" (flags still complete) instead of spewing into the completion menu.
    # Positionals are ALWAYS server keys, and servers are never mutually exclusive —
    # offer them on every positional <tab>, first or later.
    local servers_file keys
    servers_file="$(_mcpeepants_servers_file)"
    if [[ -n "$servers_file" ]]; then
        if command -v jq >/dev/null 2>&1; then
            keys=$(jq -r 'keys[]' "$servers_file" 2>/dev/null)
        else
            # grep fallback when jq is absent: top-level keys are the lines
            # indented exactly two spaces (servers.json is pretty-printed that
            # way). Anchoring on '^  "' avoids matching nested "config"/"env"/
            # "headers" objects. Keys hold no spaces or quotes, so tr -d ' "'
            # strips the leading indent and surrounding quotes safely.
            keys=$(grep -oE '^  "[^"]+"' "$servers_file" | tr -d ' "')
        fi
    fi
    # SC2207 (mapfile preferred) is acceptable here: server keys never contain
    # spaces, so word-splitting is safe.
    COMPREPLY=($(compgen -W "$keys" -- "$cur"))
    return 0
}

# Resolve the path to servers.json. Mirrors how get-server-config.sh itself finds
# it (SCRIPT_DIR sibling lookup), generalized so it works whether this file is
# sourced in place, copied to a completion dir, or the script is on PATH.
# Prints the servers.json path on stdout; prints nothing on miss.
_mcpeepants_servers_file() {
    local d bin src
    # 1. Explicit override (recommended for fish/zsh copied installs).
    if [[ -n "${MCPEEPANTS_HOME:-}" && -f "$MCPEEPANTS_HOME/servers.json" ]]; then
        printf '%s/servers.json' "$MCPEEPANTS_HOME"
        return
    fi
    # 2. Sibling of get-server-config.sh on PATH (resolve symlinks).
    if bin="$(command -v get-server-config.sh 2>/dev/null)" && [[ -n "$bin" ]]; then
        d="$(cd "$(dirname "$bin")" && pwd)"
        [[ -f "$d/servers.json" ]] && { printf '%s/servers.json' "$d"; return; }
    fi
    # 3. Repo root — sibling of this completion file when sourced in place from
    #    /path/to/mcpeepants/completions/mcpeepants.bash. BASH_SOURCE[0] is the file
    #    the function is defined in, so this works after `source` even though it
    #    misses (harmlessly) after `cp` to a completion dir.
    src="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null)"
    if [[ -n "$src" ]]; then
        d="$(cd "$(dirname "$src")/.." 2>/dev/null && pwd)"
        [[ -f "$d/servers.json" ]] && { printf '%s/servers.json' "$d"; return; }
    fi
    # 4. Current working directory (last resort).
    [[ -f "./servers.json" ]] && printf '%s/servers.json' "$PWD"
    return 0
}

# Register for both invocation styles: the script name and the `mcpeepants` alias.
complete -F _mcpeepants_completion get-server-config.sh
complete -F _mcpeepants_completion mcpeepants

# --- listing behavior ---------------------------------------------------------
# mcpeepants wants every ambiguous match listed on the FIRST Tab — server keys
# are derived from servers.json and completion is the primary discovery path, so
# candidates hidden behind a silent common-prefix halt are a UX defect. bash
# defaults to show-all-if-ambiguous OFF: the first Tab completes the common prefix
# and beeps, and the full list appears only on the second Tab. Set it ON so all
# prefix matches list on the first Tab.
#
# This is a READLINE SESSION-GLOBAL option: it changes listing for EVERY command
# in this shell, not just mcpeepants (there is no per-command scope). The
# `[[ $- == *i* ]] &&` guard keeps this quiet when the file is sourced
# non-interactively (e.g. an eval test harness). The trailing `|| true` ensures
# `source`/`eval` returns exit 0 even in a non-interactive shell, so it won't
# abort a `.bashrc` under `set -e`.
{ [[ $- == *i* ]] && bind 'set show-all-if-ambiguous on'; } || true
# Opt-out — restore bash's stock (second-Tab) listing:
#   bind 'set show-all-if-ambiguous off'