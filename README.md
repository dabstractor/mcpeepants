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

## Shell completions

mcpeepants ships dynamic completions for bash, zsh, and fish. Server-key
completion is **not a static list**: the shell reads `servers.json` at completion
time (via `jq`, with a `grep` fallback), so it never goes stale as you add servers.

The easiest way to load them is the `--completions` flag, which prints the script
for your shell to `eval`. It works without copying any file.

**bash / zsh** — add to `~/.bashrc` or `~/.zshrc`:

```bash
eval "$(get-server-config.sh --completions)"
```

**fish** — add to `~/.config/fish/config.fish`:

```bash
get-server-config.sh --completions --shell fish | source
```

`--shell <bash|zsh|fish>` makes the eval deterministic; otherwise
`get-server-config.sh --completions` auto-detects from `$MCPEEPANTS_SHELL`, then
`$SHELL`. (`get-server-config.sh --shell zsh` is shorthand for
`--completions --shell zsh`.)

Prefer to copy the file instead? `./QUICK_INSTALL.sh` detects your shell and
installs the right one, or copy it manually out of `completions/`:

**bash** (one of):

```bash
source /path/to/mcpeepants/completions/mcpeepants.bash
cp completions/mcpeepants.bash ~/.local/share/bash-completion/completions/mcpeepants
cp completions/mcpeepants.bash /etc/bash_completion.d/mcpeepants
```

**zsh** (one of):

```bash
cp completions/_mcpeepants ~/.zsh/completions/_mcpeepants
cp completions/_mcpeepants /usr/local/share/zsh/site-functions/_mcpeepants
```

then ensure this is in your `.zshrc`:

```bash
autoload -U compinit && compinit
```

**fish**:

```bash
cp completions/mcpeepants.fish ~/.config/fish/completions/mcpeepants.fish
```

Once loaded, completions are **server-keys-first and long-form-only**:

- `get-server-config.sh <tab>` lists every server key in `servers.json` (the
  default, most-used action) — recomputed on every keystroke, so a newly-added
  server is completable immediately. Keys are offered on every positional, since
  servers are never mutually exclusive.
- `get-server-config.sh -<tab>` lists the **long-form flags only** — `--all`,
  `--completions`, `--help`, `--list`, `--search`, `--shell` — narrowed by what
  you type after the dash. The `-h`/`-l` short aliases stay valid for typing but
  are deliberately not advertised.
- `get-server-config.sh --search <tab>` offers nothing — it takes a free-text
  query. `get-server-config.sh --shell <tab>` offers the three supported shells —
  `bash`, `zsh`, and `fish`.

The bash script also sets a shell option so that when a prefix matches two or
more keys or flags, **every** match lists on the first `<tab>` instead of the
shell freezing at the common prefix. This is a **session-global** option: it
changes tab-completion listing for *every* command in that shell, not just
mcpeepants. (zsh and fish list all matches by default; no option is set.) Restore
bash's stock behavior with:

```bash
bind 'set show-all-if-ambiguous off'
```

**Finding `servers.json`.** The `eval "$(get-server-config.sh --completions)"`
path **bakes the repo location** into the emitted script, so completion works via
an alias from any directory — no setup needed. (It self-heals on repo move, since
your rc file re-runs `--completions` at every startup and rebakes.)

The on-disk files (the copy/manual path) resolve the manifest in this order:
`$MCPEEPANTS_HOME/servers.json` → the directory of `get-server-config.sh` on
`PATH` → `./servers.json`. If none match (e.g. you copied a completion to an
fpath dir without the script on `PATH`), set `MCPEEPANTS_HOME`:

```bash
export MCPEEPANTS_HOME=/path/to/mcpeepants
```

**Aliases** like `alias mcpp=.../get-server-config.sh` get completion
automatically: zsh/bash/fish all resolve the alias to the bound command at
completion time, so the script name doesn't have to be on `PATH`.
