# Fish completion for mcpeepants get-server-config.sh
# Place this file in ~/.config/fish/completions/

complete -c mcpeepants -f
complete -c mcpeepants -n "__fish_use_subcommand" -l help -s h -d "Show help message"
complete -c mcpeepants -n "__fish_use_subcommand" -l all -d "Generate configuration with all available MCP servers"
complete -c mcpeepants -n "__fish_use_subcommand" -l list -s l -d "List all available MCP servers"
complete -c mcpeepants -n "__fish_use_subcommand" -l search -x -d "Search servers by name, keyword, or description"

# Server completions
complete -c mcpeepants -n "__fish_use_subcommand" -a "desktop-commander" -d "Terminal and filesystem operations"
complete -c mcpeepants -n "__fish_use_subcommand" -a "playwright" -d "Browser automation and web scraping"
complete -c mcpeepants -n "__fish_use_subcommand" -a "zai-mcp-server" -d "Vision and video analysis with GLM-4.5V"
complete -c mcpeepants -n "__fish_use_subcommand" -a "sequential-thinking" -d "Reasoning scaffolding for multi-step tasks"
complete -c mcpeepants -n "__fish_use_subcommand" -a "chrome-devtools" -d "Direct Chrome DevTools Protocol access"
complete -c mcpeepants -n "__fish_use_subcommand" -a "serena" -d "Advanced coding agent toolkit with semantic editing"
complete -c mcpeepants -n "__fish_use_subcommand" -a "context7" -d "Real-time documentation search for 50,000+ libraries"
complete -c mcpeepants -n "__fish_use_subcommand" -a "video-processing" -d "Comprehensive video processing with FFmpeg"
complete -c mcpeepants -n "__fish_use_subcommand" -a "mermaid-mcp-server" -d "Convert Mermaid diagrams to PNG/SVG"
complete -c mcpeepants -n "__fish_use_subcommand" -a "brave-search" -d "Web search with AI summarization"
complete -c mcpeepants -n "__fish_use_subcommand" -a "tavily" -d "Comprehensive web access with real-time search"
complete -c mcpeepants -n "__fish_use_subcommand" -a "z-ai-web-search-prime" -d "Cloud-based web search for GLM subscribers"

# Allow multiple server completions
complete -c mcpeepants -n "not __fish_seen_subcommand_from --help --all --list --search" -a "desktop-commander playwright zai-mcp-server sequential-thinking chrome-devtools serena context7 video-processing mermaid-mcp-server brave-search tavily z-ai-web-search-prime"

# Also complete for get-server-config.sh directly
complete -c get-server-config.sh -f
complete -c get-server-config.sh -n "__fish_use_subcommand" -l help -s h -d "Show help message"
complete -c get-server-config.sh -n "__fish_use_subcommand" -l all -d "Generate configuration with all available MCP servers"
complete -c get-server-config.sh -n "__fish_use_subcommand" -l list -s l -d "List all available MCP servers"
complete -c get-server-config.sh -n "__fish_use_subcommand" -l search -x -d "Search servers by name, keyword, or description"

complete -c get-server-config.sh -n "__fish_use_subcommand" -a "desktop-commander" -d "Terminal and filesystem operations"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "playwright" -d "Browser automation and web scraping"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "zai-mcp-server" -d "Vision and video analysis with GLM-4.5V"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "sequential-thinking" -d "Reasoning scaffolding for multi-step tasks"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "chrome-devtools" -d "Direct Chrome DevTools Protocol access"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "serena" -d "Advanced coding agent toolkit with semantic editing"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "context7" -d "Real-time documentation search for 50,000+ libraries"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "video-processing" -d "Comprehensive video processing with FFmpeg"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "mermaid-mcp-server" -d "Convert Mermaid diagrams to PNG/SVG"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "brave-search" -d "Web search with AI summarization"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "tavily" -d "Comprehensive web access with real-time search"
complete -c get-server-config.sh -n "__fish_use_subcommand" -a "z-ai-web-search-prime" -d "Cloud-based web search for GLM subscribers"

complete -c get-server-config.sh -n "not __fish_seen_subcommand_from --help --all --list --search" -a "desktop-commander playwright zai-mcp-server sequential-thinking chrome-devtools serena context7 video-processing mermaid-mcp-server brave-search tavily z-ai-web-search-prime"