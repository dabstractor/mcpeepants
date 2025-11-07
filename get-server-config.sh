#!/bin/bash

# MCP Server Config Extractor
# Usage: ./get-server-config.sh key1 key2 key3 ...
#        ./get-server-config.sh --list (or -l) to show available servers
#        ./get-server-config.sh --search query to search servers
# Example: ./get-server-config.sh sequential-thinking desktop-commander

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVERS_FILE="$SCRIPT_DIR/servers.json"

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
    echo "  $0 --help"
    echo
    echo -e "\033[1mEXAMPLES:\033[0m"
    echo "  claude --mcp-config \"\$($0 playwright sequential-thinking)\""
    echo "  claude --mcp-config \"\$($0 desktop-commander playwright)\""
    echo "  claude --mcp-config \"\$($0 --all)\""
    echo "  $0 --list"
    echo "  $0 --search browser"
    echo
    echo -e "\033[1mOPTIONS:\033[0m"
    echo "  --all            Generate configuration with all available MCP servers"
    echo "  --list, -l       List all available MCP servers"
    echo "  --search <query> Search servers by name, keyword, or description"
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
' "$SERVERS_FILE"
