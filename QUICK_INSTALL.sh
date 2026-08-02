#!/bin/bash

# Quick installation script for mcpeepants tab completions
# Automatically detects your shell and installs the appropriate completion

echo "🚀 mcpeepants Tab Completion - Quick Install"
echo "==========================================="
echo

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Detected shell: $CURRENT_SHELL"
echo "mcpeepants directory: $SCRIPT_DIR"
echo

case "$CURRENT_SHELL" in
    "bash")
        echo "📦 Installing Bash completion..."

        # Check if we can install system-wide
        if [[ -w "/etc/bash_completion.d" ]]; then
            sudo cp "$SCRIPT_DIR/completions/mcpeepants.bash" "/etc/bash_completion.d/mcpeepants"
            echo "✅ Installed system-wide: /etc/bash_completion.d/mcpeepants"
        else
            # User-only installation
            mkdir -p ~/.local/share/bash-completion/completions
            cp "$SCRIPT_DIR/completions/mcpeepants.bash" ~/.local/share/bash-completion/completions/mcpeepants
            echo "✅ Installed for user: ~/.local/share/bash-completion/completions/mcpeepants"
        fi

        echo "💡 Reload your shell or run: source ~/.bashrc"
        ;;

    "zsh")
        echo "📦 Installing Zsh completion (native)..."

        # Check if we can install system-wide
        if [[ -w "/usr/share/zsh/site-functions" ]]; then
            sudo cp "$SCRIPT_DIR/completions/_mcpeepants" "/usr/share/zsh/site-functions/"
            sudo chmod 644 "/usr/share/zsh/site-functions/_mcpeepants"
            echo "✅ Installed system-wide: /usr/share/zsh/site-functions/_mcpeepants"
        else
            # User-only installation
            mkdir -p ~/.zsh/completions
            cp "$SCRIPT_DIR/completions/_mcpeepants" ~/.zsh/completions/
            chmod 644 ~/.zsh/completions/_mcpeepants

            # Ensure fpath is set in .zshrc
            if ! grep -q "fpath+=~/.zsh/completions" ~/.zshrc 2>/dev/null; then
                echo 'fpath+=~/.zsh/completions' >> ~/.zshrc
                echo 'autoload -U compinit && compinit' >> ~/.zshrc
                echo "📝 Added completion path to ~/.zshrc"
            fi

            echo "✅ Installed for user: ~/.zsh/completions/_mcpeepants"
        fi

        echo "💡 Reload your shell or run: exec zsh"
        ;;

    "fish")
        echo "📦 Installing Fish completion..."

        mkdir -p ~/.config/fish/completions
        cp "$SCRIPT_DIR/completions/mcpeepants.fish" ~/.config/fish/completions/
        echo "✅ Installed: ~/.config/fish/completions/mcpeepants.fish"

        echo "💡 Reload Fish or run: fish_update_completions"
        ;;

    *)
        echo "❌ Unsupported shell: $CURRENT_SHELL"
        echo "🔧 Manual installation required. See the README \"Shell completions\" section."
        exit 1
        ;;
esac

echo
echo "🎉 Installation complete!"
echo
echo "Test it:"
echo "  cd $SCRIPT_DIR"
echo "  ./get-server-config.sh <TAB>"
echo "  ./get-server-config.sh --<TAB>"
echo
echo "For more details, see the README \"Shell completions\" section."