# mcpeepants

CLI helper for generating MCP server configurations.

## Usage

```bash
claude --mcp-config "$(./get-server-config.sh server1 server2)"
```

## Available Servers

- `desktop-commander` - Filesystem access, terminal execution, process management
- `playwright` - Browser automation and web scraping
- `zai-mcp-server` - Z AI model access for text analysis
- `sequential-thinking` - Reasoning scaffolding for multi-step tasks
- `context7` - Real-time documentation search for 50,000+ libraries
- `chrome-devtools` - Direct Chrome DevTools Protocol access
- `serena` - Advanced coding agent toolkit with semantic editing

## Examples

```bash
# Generate config with browser automation and sequential thinking
claude --mcp-config "$(./get-server-config.sh playwright sequential-thinking)"

# Use Context7 for real-time documentation search
claude --mcp-config "$(./get-server-config.sh context7)"

# Combine desktop-commander and playwright servers
claude --mcp-config "$(./get-server-config.sh desktop-commander playwright)"

# Development environment with documentation and browser tools
claude --mcp-config "$(./get-server-config.sh context7 playwright chrome-devtools)"
```