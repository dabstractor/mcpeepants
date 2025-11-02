#!/bin/bash

# MCP Server Config Extractor
# Usage: ./get-server-config.sh key1 key2 key3 ...
# Example: ./get-server-config.sh sequential-thinking desktop-commander

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVERS_FILE="$SCRIPT_DIR/servers.json"

if [ ! -f "$SERVERS_FILE" ]; then
    echo "Error: $SERVERS_FILE not found" >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <server-key1> [server-key2] ..." >&2
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
