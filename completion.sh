#!/bin/bash

# Bash completion for mcpeepants get-server-config.sh script
# Install by sourcing this file in your .bashrc or .bash_profile:
# source /path/to/mcpeepants/completion.sh

_mcpeepants_completion() {
    local cur prev words cword script_dir servers_file
    _init_completion || return

    # Get script directory and servers file location
    script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[1]}" 2>/dev/null || echo "${BASH_SOURCE[1]}")")"
    servers_file="$script_dir/servers.json"

    # If servers.json doesn't exist, fallback to basic completion
    if [[ ! -f "$servers_file" ]]; then
        COMPREPLY=($(compgen -W "--help --all --list --search" -- "$cur"))
        return 0
    fi

    # Available options
    local options="--help -h --all --list -l --search"

    case "$prev" in
        --search)
            # For --search, don't provide any completion - let user type their query
            COMPREPLY=()
            return 0
            ;;
        *)
            ;;
    esac

    # If current word starts with -, complete options
    if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "$options" -- "$cur"))
        return 0
    fi

    # Get available server names from servers.json
    local available_servers
    if command -v jq >/dev/null 2>&1; then
        available_servers=$(jq -r 'keys[]' "$servers_file" 2>/dev/null)
    else
        # Fallback if jq is not available
        available_servers=$(grep -oE '"[^"]+":\s*\{' "$servers_file" | grep -oE '"[^"]+"' | tr -d '"' 2>/dev/null)
    fi

    # Combine server names with options
    local completions="$available_servers $options"

    COMPREPLY=($(compgen -W "$completions" -- "$cur"))
    return 0
}

# Register the completion function
complete -F _mcpeepants_completion get-server-config.sh
complete -F _mcpeepants_completion ./get-server-config.sh

# Also complete if user has created a symlink or alias
complete -F _mcpeepants_completion mcpeepants