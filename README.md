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

## Example

```bash
# Generate config with browser automation and sequential thinking
claude --mcp-config "$(./get-server-config.sh playwright sequential-thinking)"
```