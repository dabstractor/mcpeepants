#!/bin/bash

# MCP Server Config Extractor
# Usage: ./get-server-config.sh key1 key2 key3 ...
#        ./get-server-config.sh --list (or -l) to show available servers
#        ./get-server-config.sh --search query to search servers
#        ./get-server-config.sh --completions [--shell bash|zsh|fish]
# Example: ./get-server-config.sh sequential-thinking desktop-commander

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVERS_FILE="$SCRIPT_DIR/servers.json"

# Handle --completions / --shell: emit the shell-completion script for eval
# (mirrors skilldozer --completions). bash/fish are emitted verbatim; zsh gets an
# eval-safe wrapper — the autoload file's trailing `_mcpeepants "$@"` self-call
# is stripped and an explicit compdef + compinit bootstrap is appended, because
# the `#compdef` header is inert under eval. --shell forces a shell; otherwise
# detect from $MCPEEPANTS_SHELL, then basename($SHELL). --shell alone implies
# --completions (parity with skilldozer). Runs BEFORE the servers.json check so
# it works even in a partial checkout (the scripts resolve servers.json later, at
# completion time).
_emit_completions=0
_force_shell=""
_prev=""
for _arg in "$@"; do
    case "$_arg" in
        --completions) _emit_completions=1 ;;
        --shell)       _emit_completions=1 ;;
        --shell=*)     _emit_completions=1; _force_shell="${_arg#--shell=}" ;;
    esac
    if [[ "$_prev" == "--shell" && -z "$_force_shell" ]]; then
        _force_shell="$_arg"
    fi
    _prev="$_arg"
done

if [[ $_emit_completions -eq 1 ]]; then
    # Resolve shell: --shell value > $MCPEEPANTS_SHELL > basename($SHELL).
    _target_shell="$_force_shell"
    if [[ -z "$_target_shell" ]]; then
        _target_shell="${MCPEEPANTS_SHELL:-}"
        [[ -z "$_target_shell" && -n "${SHELL:-}" ]] && _target_shell="${SHELL##*/}"
    fi
    if [[ -z "$_target_shell" ]]; then
        echo "Error: could not detect shell. Pass --shell <bash|zsh|fish>, set \$MCPEEPANTS_SHELL, or \$SHELL." >&2
        exit 1
    fi

    # Resolve the completions/ directory: sibling of this script, else $MCPEEPANTS_HOME.
    _compdir=""
    for _d in "$SCRIPT_DIR/completions" "${MCPEEPANTS_HOME:-}/completions"; do
        [[ -n "$_d" && -d "$_d" ]] && { _compdir="$_d"; break; }
    done
    if [[ -z "$_compdir" ]]; then
        echo "Error: completions/ not found (looked in $SCRIPT_DIR/completions and \$MCPEEPANTS_HOME/completions)." >&2
        exit 1
    fi

    # Bake the repo location into the emitted script as the default MCPEEPANTS_HOME.
    # The on-disk completion files resolve servers.json via $MCPEEPANTS_HOME -> script
    # on PATH -> cwd. But a user who invokes the script through an ALIAS (not on PATH)
    # from an unrelated cwd hits NONE of those tiers and gets zero keys (the function
    # still binds via zsh alias resolution, so the menu goes blank rather than falling
    # back to files). --completions runs from the repo (SCRIPT_DIR = repo root), so it
    # records that location here. Self-heals on repo move: rc files re-run --completions
    # at every startup, rebaking the current path.
    case "$_target_shell" in
        bash)
            printf '# Default manifest location: repo this completion was emitted from.\n[[ -z "${MCPEEPANTS_HOME:-}" ]] && MCPEEPANTS_HOME=%q\n' "$SCRIPT_DIR"
            cat "$_compdir/mcpeepants.bash"
            ;;
        fish)
            printf '# Default manifest location: repo this completion was emitted from.\nif test -z "$MCPEEPANTS_HOME"\n    set -gx MCPEEPANTS_HOME %s\nend\n' "$SCRIPT_DIR"
            cat "$_compdir/mcpeepants.fish"
            ;;
        zsh)
            # Strip the autoload self-call line and everything after, then append the
            # eval-safe registration. awk exits at the self-call so only the header +
            # function body (ending at '}') is emitted.
            awk '/^_mcpeepants "\$@"$/{exit} {print}' "$_compdir/_mcpeepants"
            printf '\n# Default manifest location: repo this completion was emitted from.\n# Self-heals on repo move (rc files re-run --completions at startup).\n(( ${+MCPEEPANTS_HOME} )) || MCPEEPANTS_HOME=%s\n' "$SCRIPT_DIR"
            cat <<'__MCPEEPANTS_ZSH_EVAL__'

# Register the completion for eval. The #compdef header above only binds this as
# an autoload file on fpath; under eval it is inert, so bind the function
# explicitly. compsys (_arguments/_files/compadd) is bootstrapped only if not
# already loaded (oh-my-zsh / prezto / a manual compinit all define compdef).
# The autoload file's trailing self-call is intentionally omitted: it would fire
# the function at eval time, before _arguments is guaranteed to exist.
autoload -Uz compinit
(( $+functions[compdef] )) || compinit
(( $+functions[compdef] )) && compdef _mcpeepants get-server-config.sh mcpeepants

# List every ambiguous match on the first Tab (session-global zsh option).
# Opt-out: setopt LIST_AMBIGUOUS
setopt NO_LIST_AMBIGUOUS
__MCPEEPANTS_ZSH_EVAL__
            ;;
        *)
            echo "Error: unsupported shell '$_target_shell' (expected bash, zsh, or fish)." >&2
            exit 1
            ;;
    esac
    exit 0
fi

if [ ! -f "$SERVERS_FILE" ]; then
    echo "Error: $SERVERS_FILE not found" >&2
    exit 1
fi

# Handle --help/-h flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "\033[1;36mMCP Server Config Extractor\033[0m"
    echo "A CLI helper for generating MCP server configurations"
    echo
    echo -e "\033[1mUSAGE:\033[0m"
    echo "  $0 <server-key1> [server-key2] ..."
    echo "  $0 --all"
    echo "  $0 --list"
    echo "  $0 --search <query>"
    echo "  $0 --completions [--shell bash|zsh|fish]"
    echo "  $0 --help"
    echo
    echo -e "\033[1mEXAMPLES:\033[0m"
    echo "  claude --mcp-config \"\$($0 playwright sequential-thinking)\""
    echo "  claude --mcp-config \"\$($0 desktop-commander playwright)\""
    echo "  claude --mcp-config \"\$($0 --all)\""
    echo "  $0 --list"
    echo "  $0 --search browser"
    echo "  eval \"\$($0 --completions --shell zsh)\"   # load tab completions"
    echo
    echo -e "\033[1mOPTIONS:\033[0m"
    echo "  --all            Generate configuration with all available MCP servers"
    echo "  --list, -l       List all available MCP servers"
    echo "  --search <query> Search servers by name, keyword, or description"
    echo "  --completions    Emit the shell completion script for eval"
    echo "  --shell <name>   Force a shell for --completions (bash, zsh, fish)"
    echo "  --help, -h       Show this help message"
    echo
    echo -e "\033[1mFILES:\033[0m"
    echo "  servers.json     Configuration database containing available MCP servers"
    exit 0
fi

# Handle --all flag
if [[ "$1" == "--all" ]]; then
    jq -c '{
      "mcpServers": (
        . |
        to_entries |
        map({key: .key, value: .value.config}) |
        from_entries
      )
    }' "$SERVERS_FILE"
    exit 0
fi

# Handle --list/-l flag
if [[ "$1" == "--list" || "$1" == "-l" ]]; then
    echo -e "\033[1;36mAvailable MCP Servers:\033[0m"
    echo

    # Get servers and calculate column widths
    servers=$(jq -r 'to_entries[] | "\(.key):\(.value.description)"' "$SERVERS_FILE")

    # Find the longest server name for formatting
    max_name_length=0
    while IFS=: read -r name desc; do
        if [[ ${#name} -gt $max_name_length ]]; then
            max_name_length=${#name}
        fi
    done <<< "$servers"

    # Set minimum width and add padding
    name_width=$((max_name_length + 2))

    # Print header
    printf "\033[1m%-${name_width}s\033[0m %s\n" "Server" "Description"
    printf "%-${name_width}s %s\n" "$(printf '%*s' $name_width | tr ' ' '-')" "$(printf '%*s' 50 | tr ' ' '-')"

    # Print server list with proper formatting
    while IFS=: read -r name desc; do
        printf "\033[1;36m%-${name_width}s\033[0m " "$name"
        echo "$desc" | fold -w $((80 - name_width)) -s | {
            first_line=true
            while IFS= read -r line; do
                if $first_line; then
                    echo "$line"
                    first_line=false
                else
                    printf "%-${name_width}s %s\n" "" "$line"
                fi
            done
        }
        echo  # Add blank line between servers
    done <<< "$servers"

    echo
    echo -e "\033[1;33mUsage:\033[0m $0 <server1> <server2> ..."
    exit 0
fi

# Handle --search flag
if [[ "$1" == "--search" ]]; then
    if [ $# -eq 1 ]; then
        echo "Error: --search requires a query argument" >&2
        echo "Usage: $0 --search <query>" >&2
        exit 1
    fi

    query="$2"
    echo -e "\033[1;36mSearch results for '\033[1;33m$query\033[1;36m':\033[0m"
    echo

    # Search servers by name, keywords, and description
    results=$(jq -r --arg query "$query" '
    to_entries[] |
    select(
        (.key | test($query; "i")) or
        (.value.description | test($query; "i")) or
        (.value.keywords[]? | test($query; "i"))
    ) |
    "\(.key):\(.value.description)"
    ' "$SERVERS_FILE")

    if [ -z "$results" ]; then
        echo -e "\033[1;31mNo servers found matching '\033[1;33m$query\033[1;31m'.\033[0m"
        echo
        echo -e "\033[1;33mTip:\033[0m Use $0 --list to see all available servers."
        exit 0
    fi

    # Find the longest server name for formatting
    max_name_length=0
    while IFS=: read -r name desc; do
        if [[ ${#name} -gt $max_name_length ]]; then
            max_name_length=${#name}
        fi
    done <<< "$results"

    # Set minimum width and add padding
    name_width=$((max_name_length + 2))

    # Print header
    printf "\033[1m%-${name_width}s\033[0m %s\n" "Server" "Description"
    printf "%-${name_width}s %s\n" "$(printf '%*s' $name_width | tr ' ' '-')" "$(printf '%*s' 50 | tr ' ' '-')"

    # Print search results with proper formatting
    while IFS=: read -r name desc; do
        printf "\033[1;36m%-${name_width}s\033[0m " "$name"
        echo "$desc" | fold -w $((80 - name_width)) -s | {
            first_line=true
            while IFS= read -r line; do
                if $first_line; then
                    echo "$line"
                    first_line=false
                else
                    printf "%-${name_width}s %s\n" "" "$line"
                fi
            done
        }
        echo  # Add blank line between servers
    done <<< "$results"

    echo
    echo -e "\033[1;33mUsage:\033[0m $0 <server1> <server2> ..."
    exit 0
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <server-key1> [server-key2] ..." >&2
    echo "       $0 --list (or -l) to show available servers" >&2
    echo "       $0 --search <query> to search servers" >&2
    echo "Example: $0 sequential-thinking desktop-commander" >&2
    exit 1
fi

# Convert arguments to JSON array for jq
keys_json=$(printf '%s\n' "$@" | jq -R . | jq -s .)

# Extract specified keys and transform to mcpServers format
# Takes the .config object from each server and places it under mcpServers
# Interpolate shell variables in environment values and headers
# Output as single line compact JSON
jq -c --argjson keys "$keys_json" '
{
  "mcpServers": (
    . |
    to_entries |
    map(select(.key as $k | $keys | index($k) != null)) |
    map({key: .key, value: .value.config}) |
    from_entries
  )
}
' "$SERVERS_FILE" | envsubst
