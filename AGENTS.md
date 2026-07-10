# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

mcpeepants is a CLI helper for generating MCP (Model Context Protocol) server configurations. It provides a simple way to combine multiple MCP server configurations into a single configuration that can be used with Claude Code.

## Key Commands

### Generate MCP Configuration
```bash
./get-server-config.sh <server-key1> [server-key2] ...
```

Examples:
```bash
# Generate config with browser automation and sequential thinking
claude --mcp-config "$(./get-server-config.sh playwright sequential-thinking)"

# Use desktop-commander and playwright servers
claude --mcp-config "$(./get-server-config.sh desktop-commander playwright)"
```

### Test Server Configuration
Run the script to see the JSON output format:
```bash
./get-server-config.sh desktop-commander
```

## Architecture

The project consists of three main files:

- **`get-server-config.sh`**: Bash script that extracts specified server configurations from `servers.json` and formats them for MCP consumption
- **`servers.json`**: Configuration database containing available MCP servers, their launch parameters, descriptions, and use cases
- **`README.md`**: User documentation and examples

### Script Behavior

The `get-server-config.sh` script:
1. Takes server keys as command line arguments
2. Looks up each server in `servers.json`
3. Extracts the `.config` object from each server
4. Outputs a compact JSON object with the format `{"mcpServers": {...}}`

### Server Configuration Structure

Each server in `servers.json` contains:
- `config`: MCP server launch configuration (command, args, env variables)
- `description`: What the server does
- `keywords`: Searchable terms for the server's capabilities
- `useCases`: Appropriate usage scenarios
- `notGoodFor`: Inappropriate usage scenarios
- `limitations`: Known limitations
- `examplePrompt`: Example of when to use this server

## Available Servers

- `desktop-commander`: Filesystem access, terminal execution, process management
- `playwright`: Browser automation and web scraping
- `zai-mcp-server`: Z AI model access for text analysis (requires `Z_AI_API_KEY` environment variable)
- `sequential-thinking`: Reasoning scaffolding for multi-step tasks

## Adding New Servers

To add a new MCP server:
1. Add an entry to `servers.json` following the existing structure
2. Include the required `.config` section with the command/args to launch the server
3. Provide descriptive metadata for users