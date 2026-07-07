#!/bin/bash

# Demo script to show mcpeepants tab completions in action
# This script simulates the tab completion behavior

echo "🚀 mcpeepants Tab Completion Demo"
echo "================================="
echo

# Simulate the available servers from servers.json
AVAILABLE_SERVERS=(
    "desktop-commander"
    "playwright"
    "zai-mcp-server"
    "sequential-thinking"
    "chrome-devtools"
    "serena"
    "context7"
    "video-processing"
    "mermaid-mcp-server"
    "brave-search"
    "tavily"
    "z-ai-web-search-prime"
)

OPTIONS="--help --all --list --search"

echo "Available servers:"
printf '  %s\n' "${AVAILABLE_SERVERS[@]}"
echo

echo "Available options:"
printf '  %s\n' $OPTIONS
echo

echo "Demo 1: Basic server completion"
echo "Command: ./get-server-config.sh <TAB>"
echo "Shows: All available servers and options"
echo

echo "Demo 2: Partial server name completion"
echo "Command: ./get-server-config.sh play<TAB>"
echo "Completes to: playwright"
echo

echo "Demo 3: Multiple server completion"
echo "Command: ./get-server-config.sh playwright <TAB>"
echo "Shows: All servers again for second selection"
echo

echo "Demo 4: Option completion"
echo "Command: ./get-server-config.sh -<TAB>"
echo "Shows: --all --help --list --search"
echo

echo "Demo 5: Search option"
echo "Command: ./get-server-config.sh --search <query>"
echo "Lets you type search term freely"
echo

echo "Demo 6: Real-world usage examples"
echo

echo "Example 1: Browser automation setup"
echo "  ./get-server-config.sh playwright <TAB>"
echo "  # Select playwright, then TAB again for more servers"
echo "  ./get-server-config.sh playwright sequential-thinking"
echo

echo "Example 2: Development environment"
echo "  ./get-server-config.sh <TAB>"
echo "  # Complete 'desktop-commander'"
echo "  ./get-server-config.sh desktop-commander <TAB>"
echo "  # Complete 'context7'"
echo "  ./get-server-config.sh desktop-commander context7 <TAB>"
echo "  # Complete 'playwright'"
echo "  ./get-server-config.sh desktop-commander context7 playwright"
echo

echo "Example 3: Using options"
echo "  ./get-server-config.sh --<TAB>"
echo "  # Complete '--list'"
echo "  ./get-server-config.sh --list"
echo "  # Shows all available servers with descriptions"
echo

echo "Example 4: Search functionality"
echo "  ./get-server-config.sh --search <TAB>"
echo "  # Type your search (no completion for search term)"
echo "  ./get-server-config.sh --search browser"
echo "  # Shows servers matching 'browser'"
echo

echo "Installation Instructions:"
echo "========================"
echo "1. System-wide: sudo cp completion.sh /etc/bash_completion.d/mcpeepants"
echo "2. User-only: cp completion.sh ~/.local/share/bash-completion/completions/"
echo "3. Manual: source completion.sh in your .bashrc"
echo
echo "See INSTALL_COMPLETIONS.md for detailed instructions."
echo

echo "Shell-specific Features:"
echo "======================"
echo

echo "✅ Bash Features:"
echo "  • Dynamic server discovery from servers.json"
echo "  • Multiple server argument completion"
echo "  • Option completion with --help, --all, --list, --search"
echo "  • Fallback to grep if jq is not available"
echo

echo "✅ Zsh Features:"
echo "  • Native Zsh completion system (no bash compatibility needed)"
echo "  • Intelligent argument parsing"
echo "  • Descriptive help text for each completion"
echo "  • Enhanced completion with descriptions"
echo

echo "✅ Fish Features:"
echo "  • Native Fish completion system"
echo "  • Descriptive help text for each server"
echo "  • Support for both 'mcpeepants' and 'get-server-config.sh'"
echo "  • Proper command argument handling"
echo

echo "Shell Detection:"
echo "==============="
echo "Current shell: $SHELL"
echo "Recommended completion file:"
case "$SHELL" in
    */bash)
        echo "  → completion.sh (Bash native)"
        ;;
    */zsh)
        echo "  → _mcpeepants (Zsh native)"
        ;;
    */fish)
        echo "  → mcpeepants.fish (Fish native)"
        ;;
    *)
        echo "  → completion.sh (Bash compatibility)"
        ;;
esac
echo

echo "✨ Enjoy your enhanced mcpeepants experience!"