# Fish completion for mcpeepants (get-server-config.sh).
#
# Install (one of):
#   cp completions/mcpeepants.fish ~/.config/fish/completions/mcpeepants.fish
#   source /path/to/mcpeepants/completions/mcpeepants.fish   # current shell only
#
# Server keys are derived DYNAMICALLY from servers.json at completion time
# (jq, with a grep fallback) — never a hardcoded list. servers.json is the single
# source of truth (the inverse of skilldozer, which is manifest-free).
#
# LOCKSTEP: the flag list below is frozen to the arg parsing in get-server-config.sh.
# If a future task adds/renames a flag there, update this file — and the bash/zsh
# files — identically. Long-form flags are advertised; -l short alias stays valid
# at runtime but is not advertised (mirrors skilldozer decision 20).
#
# servers.json is resolved via $MCPEEPANTS_HOME, else the sibling dir of
# get-server-config.sh on PATH, else the cwd. If neither is set, export
# MCPEEPANTS_HOME pointing at the repo so keys resolve.

# Print the path to servers.json, or nothing. Mirrors the bash/zsh resolver's
# tier order: explicit override -> script sibling on PATH -> cwd.
function _mcpeepants_servers_file
    if test -n "$MCPEEPANTS_HOME"; and test -f "$MCPEEPANTS_HOME/servers.json"
        echo "$MCPEEPANTS_HOME/servers.json"
        return
    end
    set -l bin (command -v get-server-config.sh 2>/dev/null)
    if test -n "$bin"
        # readlink -f is GNU-only; fall back to the raw path on BSD/macOS.
        set -l resolved (readlink -f $bin 2>/dev/null; or echo $bin)
        set -l d (dirname $resolved)
        if test -f "$d/servers.json"
            echo "$d/servers.json"
            return
        end
    end
    if test -f ./servers.json
        echo "./servers.json"
    end
end

# Print server keys, one per line (empty on any failure — missing file or absent
# jq degrades to "no keys" rather than an error dump).
function _mcpeepants_keys
    set -l f (_mcpeepants_servers_file)
    test -z "$f"; and return
    if command -v jq >/dev/null 2>&1
        jq -r 'keys[]' "$f" 2>/dev/null
    else
        # grep fallback: top-level keys are lines indented exactly two spaces
        # (avoids matching nested config/env/headers objects).
        grep -oE '^  "[^"]+"' "$f" 2>/dev/null | tr -d ' "'
    end
end

# --- get-server-config.sh -----------------------------------------------------

# No file completion: mcpeepants takes server keys/flags, not paths.
complete -c get-server-config.sh -f

complete -c get-server-config.sh -l all    -d 'Generate config with all available MCP servers'
complete -c get-server-config.sh -l list   -d 'List all available MCP servers'
complete -c get-server-config.sh -l help   -d 'Show the help message'
# --search takes a free-text query, so NO completion is offered after it. We
# deliberately do NOT pass -r: in fish 4.x -r switches into "complete the option's
# value" mode, which BYPASSES the global -f above and would offer files for the
# query. Without -r, --search is treated as a plain flag, so after `--search ` the
# global -f (no-files) applies and nothing is offered — exactly the free-text
# behavior. (Same reasoning as skilldozer §6.1.)
complete -c get-server-config.sh -l search -d 'Search servers by name, keyword, or description'
complete -c get-server-config.sh -l completions -d 'Emit the shell completion script for eval'
# --shell <name>: closed enum (-x requires a value and suppresses files, -a offers the shells).
complete -c get-server-config.sh -l shell -d 'Force a shell for --completions' -x -a "bash zsh fish"

# Dynamic server keys: ONE directive with command substitution (NOT a hardcoded
# line per key — the manifest changes as servers are added). Suppressed when the
# previous arg is --search (free-text query — no key completion there).
# No subcommand guard: positionals are ALWAYS server keys.
complete -c get-server-config.sh -n 'not __fish_prev_arg_in --search' \
    -a '(_mcpeepants_keys)' -d 'MCP server key'

# --- mcpeepants alias ---------------------------------------------------------
# Mirror the above for users who alias/symlink the script as `mcpeepants`.
complete -c mcpeepants -f
complete -c mcpeepants -l all    -d 'Generate config with all available MCP servers'
complete -c mcpeepants -l list   -d 'List all available MCP servers'
complete -c mcpeepants -l help   -d 'Show the help message'
complete -c mcpeepants -l search -d 'Search servers by name, keyword, or description'
complete -c mcpeepants -l completions -d 'Emit the shell completion script for eval'
complete -c mcpeepants -l shell -d 'Force a shell for --completions' -x -a "bash zsh fish"
complete -c mcpeepants -n 'not __fish_prev_arg_in --search' \
    -a '(_mcpeepants_keys)' -d 'MCP server key'