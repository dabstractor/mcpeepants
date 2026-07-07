# Tab Completion Installation for mcpeepants

This guide shows you how to install and use tab completions for the mcpeepants tool.

## Quick Installation

### Option 1: System-wide Installation (Recommended)

1. **Copy the completion file to bash completion directory:**
   ```bash
   sudo cp completion.sh /etc/bash_completion.d/mcpeepants
   ```

2. **Reload bash completions:**
   ```bash
   source ~/.bashrc
   # Or restart your terminal
   ```

### Option 2: User-only Installation

1. **Create bash completion directory if it doesn't exist:**
   ```bash
   mkdir -p ~/.local/share/bash-completion/completions
   ```

2. **Copy the completion file:**
   ```bash
   cp completion.sh ~/.local/share/bash-completion/completions/mcpeepants
   ```

3. **Add to your .bashrc (if not already configured):**
   ```bash
   echo 'if [[ -d ~/.local/share/bash-completion/completions ]]; then' >> ~/.bashrc
   echo '    source ~/.local/share/bash-completion/completions/*' >> ~/.bashrc
   echo 'fi' >> ~/.bashrc
   ```

4. **Reload bash:**
   ```bash
   source ~/.bashrc
   ```

### Option 3: Manual Sourcing (Temporary)

1. **Source the completion file directly:**
   ```bash
   source /path/to/mcpeepants/completion.sh
   ```

2. **Add to .bashrc for persistence:**
   ```bash
   echo 'source /path/to/mcpeepants/completion.sh' >> ~/.bashrc
   ```

## Usage Examples

Once installed, you can use tab completion:

### Basic Server Completion
```bash
./get-server-config.sh <TAB>
# Shows: desktop-commander playwright zai-mcp-server sequential-thinking chrome-devtools serena context7 video-processing mermaid-mcp-server brave-search tavily z-ai-web-search-prime

./get-server-config.sh play<TAB>
# Completes to: playwright

./get-server-config.sh seq<TAB>
# Completes to: sequential-thinking
```

### Multiple Server Completion
```bash
./get-server-config.sh playwright <TAB>
# Shows all available servers again for second argument

./get-server-config.sh playwright <TAB><TAB>
# Shows: desktop-commander playwright zai-mcp-server sequential-thinking chrome-devtools serena context7 video-processing mermaid-mcp-server brave-search tavily z-ai-web-search-prime
```

### Option Completion
```bash
./get-server-config.sh -<TAB>
# Shows: --all --help --list --search

./get-server-config.sh --<TAB>
# Shows: --all --help --list --search
```

### Mixed Usage
```bash
./get-server-config.sh playwright --<TAB>
# Shows options that can be used after servers

./get-server-config.sh --search <TAB>
# No completion for search query (user types their own search term)
```

## Shell Compatibility

### Bash (✅ Full Support)
**Features:**
- All completion features work
- Dynamic server discovery from `servers.json`
- Multiple server argument completion
- Option completion (--help, --all, --list, --search)
- Fallback to grep if `jq` is not available

**Installation:**
```bash
# System-wide
sudo cp completion.sh /etc/bash_completion.d/mcpeepants
source ~/.bashrc

# User-only
mkdir -p ~/.local/share/bash-completion/completions
cp completion.sh ~/.local/share/bash-completion/completions/mcpeepants
source ~/.bashrc
```

### Zsh (✅ Native Support)
**Features:**
- Native Zsh completion system (no bash compatibility layer needed)
- Intelligent argument parsing
- Descriptive help text for completions
- Dynamic server discovery

**Installation:**
```bash
# System-wide (requires sudo)
sudo cp _mcpeepants /usr/share/zsh/site-functions/
sudo chmod 644 /usr/share/zsh/site-functions/_mcpeepants

# User-only
mkdir -p ~/.zsh/completions
cp _mcpeepants ~/.zsh/completions/
chmod 644 ~/.zsh/completions/_mcpeepants

# Add to ~/.zshrc if not already present
echo 'fpath+=~/.zsh/completions' >> ~/.zshrc
echo 'autoload -U compinit && compinit' >> ~/.zshrc
```

**Alternative (Bash compatibility):**
```bash
# Add to ~/.zshrc
echo 'autoload -U bashcompinit' >> ~/.zshrc
echo 'bashcompinit' >> ~/.zshrc
echo 'source /path/to/mcpeepants/completion.sh' >> ~/.zshrc
```

### Fish (✅ Native Support)
**Features:**
- Native Fish completion system
- Descriptive help text for each server
- Proper command argument handling
- Support for both `mcpeepants` and `get-server-config.sh`

**Installation:**
```bash
# Create completions directory
mkdir -p ~/.config/fish/completions

# Copy completion file
cp mcpeepants.fish ~/.config/fish/completions/

# Reload Fish completions (or restart Fish)
fish_update_completions
```

### Other Shells

#### PowerShell
Create a PowerShell completion script:
```powershell
# Save as ~/.local/share/powershell/Modules/McPeepants/McPeepants.psm1
Register-ArgumentCompleter -Native -CommandName 'get-server-config.sh' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $servers = @('desktop-commander', 'playwright', 'zai-mcp-server', 'sequential-thinking',
                 'chrome-devtools', 'serena', 'context7', 'video-processing', 'mermaid-mcp-server',
                 'brave-search', 'tavily', 'z-ai-web-search-prime')
    $options = @('--help', '--all', '--list', '--search')

    $completions = $servers + $options
    $completions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
```

#### Nu Shell (nushell)
Add to your Nushell config (`~/.config/nushell/config.nu`):
```nushell
let external_completer = {|spans|
    $spans | skip 1 | take 1 | each {|span|
        if $span == "get-server-config.sh" {
            ["desktop-commander", "playwright", "zai-mcp-server", "sequential-thinking",
             "chrome-devtools", "serena", "context7", "video-processing", "mermaid-mcp-server",
             "brave-search", "tavily", "z-ai-web-search-prime", "--help", "--all", "--list", "--search"]
        } else { [] }
    } | flatten
}
```

## Troubleshooting

### Completion Not Working
1. **Check if completion file is sourced:**
   ```bash
   complete -p | grep mcpeepants
   ```

2. **Verify bash completion is enabled:**
   ```bash
   echo $BASH_COMPLETION_COMPAT_DIR
   ```

3. **Check if completion script is loaded:**
   ```bash
   type _mcpeepants_completion
   ```

### Server Names Not Completing
1. **Check if servers.json exists:**
   ```bash
   ls -la servers.json
   ```

2. **Verify jq is installed:**
   ```bash
   which jq
   # Install with: sudo apt install jq  # Debian/Ubuntu
   # Install with: sudo yum install jq  # RHEL/CentOS
   # Install with: brew install jq      # macOS
   ```

### Performance Issues
- Completion queries `servers.json` each time
- For large server lists, ensure `jq` is installed for better performance
- Consider caching the server list if completion is slow

## Customization

### Adding Custom Server Aliases
Edit the completion script and add your aliases:
```bash
# In the _mcpeepants_completion function, add:
local custom_aliases="web=playwright term=desktop-commander"
```

### Changing Completion Behavior
- Modify the `COMPREPLY` generation logic
- Add filtering based on server keywords
- Implement fuzzy matching with tools like `fzf`

## Testing Your Installation

Test the completion with these commands:
```bash
# Test basic completion
./get-server-config.sh <TAB><TAB>

# Test option completion
./get-server-config.sh -<TAB>

# Test search option
./get-server-config.sh --search

# Test help
./get-server-config.sh --help
```

All should work without errors and show appropriate completions.