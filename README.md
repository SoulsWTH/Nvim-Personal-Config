# Neovim configuration

A modular, non-AI Neovim 0.12+ configuration built around native LSP APIs, iNiR-aware theming with an Oxocarbon fallback, Blink completion, Snacks and Trouble.

## Requirements

- Neovim 0.12 or newer
- Git, a C compiler, Make and Cargo
- A Nerd Font with glyph support
- `rg` and `fd` for searching
- Language runtimes required by your servers, including Node.js for web tooling
- Bun 1.3.14 or newer for Bun/TypeScript debugging
- A Rust toolchain for Rust builds and tests
- Optional: `lazygit` for `<leader>gl`

## Install

```sh
./scripts/install.sh
```

To install the same configuration for Linux's root user as well, run the installer a second time with explicit root mode:

```sh
sudo ./scripts/install.sh --root
```

The default command links the repository to the current user's Neovim configuration directory. Root mode resolves root's home directory independently and links it to `<root-home>/.config/nvim`. Existing non-symlink configurations are moved to a timestamped backup before either link is created.

On first launch, `lazy.nvim` installs plugins and Mason installs only the core Lua and Tree-sitter tools. Mason-managed language servers are installed explicitly from `:Mason` and are enabled automatically once installed. This avoids downloading runtimes for languages you do not use.

## Theme

The configuration follows iNiR's wallpaper-generated Material palette when either of these files exists:

```text
~/.local/state/quickshell/user/generated/palette.json
~/.local/state/quickshell/user/generated/colors.json
```

`inir.nvim` also watches `palette.json` and `terminal.json`, so changing the iNiR wallpaper updates Neovim's editor, terminal, completion, Snacks and lualine colors without restarting. If the generated palette is unavailable, Neovim falls back to Oxocarbon automatically. This also keeps the configuration usable outside iNiR and for the root user.

The active mode can be changed without restarting:

```vim
:ThemeToggle
:ThemeUse inir
:ThemeUse oxocarbon
:ThemeUse auto
```

The choice is saved under Neovim's state directory, so it survives restarts. `auto` restores the default behavior: use the live iNiR palette when it exists and Oxocarbon otherwise. Switching explicitly to iNiR is refused when no generated iNiR palette can be found.

`<leader>ut` runs the toggle and appears in the WhichKey UI group.

Do not enable iNiR's **Neovim / LazyVim** generated-config toggle for this repository. That integration writes `lua/plugins/neovim.lua` and includes a LazyVim-specific specification; the equivalent integration is already maintained directly in `lua/config/theme.lua` and `lua/plugins/ui.lua`. iNiR's general wallpaper theming can remain enabled because it produces the shared palette independently.

## Language servers

Shared LSP capabilities and servers that cannot be managed automatically by Mason are declared in `lua/config/lsp.lua`. Server-specific overrides belong in `after/lsp/<server>.lua`; this keeps activation separate from individual server settings.

To add a language server:

1. Install it with `:Mason` when Mason supports it. `mason-lspconfig.nvim` enables installed servers automatically.
2. For a server provided externally or embedded in another application, add its name to `manually_enabled_servers` in `lua/config/lsp.lua`.
3. Add `after/lsp/<server>.lua` only when the server needs settings that differ from the `nvim-lspconfig` defaults.

### GDScript

GDScript is explicitly enabled because its language server is built into Godot rather than installed by Mason. The `gdtoolkit` and `gdscript-formatter` Mason packages provide linting and formatting tools; they do not provide the GDScript LSP.

See Godot's [external editor documentation](https://docs.godotengine.org/en/latest/tutorials/editor/external_editor.html) for its LSP and port settings.

For navigation, completion and diagnostics in a `.gd` buffer:

1. Open the same project in Godot and keep the Godot editor running.
2. Ensure the project contains `project.godot`.
3. Keep Godot's language-server port at its default, `6005`.
4. Open a project `.gd` file in Neovim. The configuration enables `gdscript` automatically and connects to Godot.

If Godot uses a different language-server port, start Neovim with the matching environment variable:

```sh
GDScript_Port=6007 nvim
```

With Neovim 0.12+, use these commands to inspect or control LSP state:

```vim
:checkhealth vim.lsp
:lsp enable gdscript
:lsp restart gdscript
:lua =vim.lsp.get_clients({ bufnr = 0 })
```

`:LspInfo` is a legacy `nvim-lspconfig` command and is not registered when Neovim's built-in `:lsp` command is available.

Configuration changes do not require a build step; restart Neovim or reload `nvim-lspconfig` through `:Lazy`.

## Debugging

Debugging uses `nvim-dap` with the modern `nvim-dap-view` interface. Its scopes, watches, breakpoints and stack views open in a VS Code-style left sidebar, while program terminal output opens below the editor. The DAP client, interface, signs and keymaps are shared by every language. Only the adapter process and its language-specific launch fields differ.

CodeLLDB is installed through Mason because Rust debugging is explicitly enabled in this configuration. Other Mason adapters remain opt-in: open `:Mason`, or use `:DapInstall`, to install only the ones you need. `mason-nvim-dap` automatically configures supported adapters after they are explicitly installed; common adapter names include `python` (debugpy), `delve` (Go), and `js` (Node.js JavaScript and TypeScript).

Press `<leader>dc` in a supported file to select a launch configuration and start debugging. The debug panel opens for the session and closes when it ends. A project may put its custom executable, arguments and environment in `.vscode/launch.json`; `nvim-dap` reads that file automatically. This is preferable to adding project-specific values to the dotfiles.

Godot is the one built-in custom adapter. Keep the Godot editor open, leave its Debug Adapter port at `6006`, and press `<leader>dc` in a GDScript buffer. To use another port:

```sh
GODOT_DAP_PORT=6007 nvim
```

### TypeScript with Bun

Bun uses WebKit Inspector rather than Node's V8 inspector, so the Node `js-debug-adapter` is not used for Bun programs. The locked `bun-dap-x` bridge is built by Lazy with Bun and exposes three configurations for JavaScript, JSX, TypeScript and TSX buffers:

- `Bun: Current file`
- `Bun: Current file with arguments`
- `Bun: Test current file`

Press `<leader>dc` and select one. Bun handles TypeScript source maps itself, while the adapter maps breakpoints and stack frames back to the source. Project-specific Bun launches can use the `bun-dap-x` type in `.vscode/launch.json`.

`bun-dap-x` is a young community adapter because Bun does not yet publish an official standalone DAP. Its core launch, attach, breakpoint and source-map flows work, but bleeding-edge Bun releases may still expose adapter edge cases; update both Bun and the locked plugin together when troubleshooting stepping or test-file paths.

### Rust

The Rust adapter uses Mason's CodeLLDB package and CodeLLDB's native Cargo support. `<leader>dc` offers Cargo build, Cargo test, a manually selected executable, and process attachment. Cargo builds retain debug symbols in the normal development/test profiles, and `sourceLanguages = { "rust" }` enables CodeLLDB's Rust data formatters.

Custom adapters live in `lua/config/debug/adapters/`. Bun, Godot and Rust each have a focused module registered in `lua/config/debug/adapters/init.lua`; shared DAP behavior stays in `lua/config/debug/init.lua` and the plugin/UI specification stays in `lua/plugins/debug.lua`. Java is a notable special case: launch debugging is normally integrated through `nvim-jdtls`, because JDTLS supplies the dynamic classpath and starts the Java debug server.

## Keymap layout

Press `<leader>` and wait for WhichKey, or press `<leader>?` for buffer-local mappings.

| Prefix | Purpose |
| --- | --- |
| `<leader>f` | Find files, text, commands and keymaps |
| `<leader>c` | Code actions, formatting, symbols and diagnostics |
| `<leader>d` | Debug sessions, breakpoints, evaluation and UI |
| `<leader>g` | Git actions and definition navigation |
| `<leader>m` | Persistent project marks |
| `<leader>u` | UI toggles |
| `<leader>x` | Trouble diagnostics and LSP lists |

Global mappings live in `lua/config/keymaps.lua`. LSP mappings live in `lua/config/keymaps/lsp.lua`, and plugin mappings remain beside their plugin specification under `lua/plugins/`.

With an LSP attached, `<leader>gd` jumps directly to the symbol's definition, including in another file. If the server reports several definitions, it follows the first result without opening quickfix; plain `gd` opens a picker so you can choose another. `<leader>gD` opens the Git diff against the index (moved from `<leader>gd`). Use `<C-o>` to return to the previous location after a definition jump.

Debugging is designed for compact keyboards: `<leader>dc` starts or continues, `<leader>do` steps over, `<leader>di` steps into and `<leader>dO` steps out. Press `<leader>` and then `d` to see every debug binding in WhichKey.

## Maintenance

- `:Lazy` manages plugins; `lazy-lock.json` keeps installations reproducible.
- `:Mason` manages language servers and external tools.
- `:checkhealth vim.lsp` shows enabled configurations and active LSP clients.
- `:ConformInfo` shows the formatter selected for the current buffer.
- `:Trouble symbols toggle` opens the document-symbol tree.
- `:DapInstall` and `:DapUninstall` manage opt-in debugger adapters.
- `:DapViewToggle` opens or closes the debugging panel.
