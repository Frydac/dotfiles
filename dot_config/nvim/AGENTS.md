# Repository Guidelines

## Project Structure & Module Organization
This repository is a personal Neovim configuration rooted at [init.lua](/home/emile/.config/nvim/init.lua). Core editor behavior lives in `lua/user/`:

- `globals.lua`, `options.lua`, `keymaps.lua`, and `autocommands.lua` define startup behavior.
- `lua/user/plugins/` contains one plugin spec per file, grouped further where needed (`lsp/`, `dap/`, `luasnip/`, `mini/`).
- `ftplugin/` holds filetype-specific overrides for C, C++, Lua, and Rust.
- `spell/` stores custom spelling additions.
- `lazy-lock.json` pins plugin versions; update it only when intentionally changing plugin state.

## Build, Test, and Development Commands
Use Neovim itself as the development entrypoint:

- `nvim` starts the full config locally.
- `nvim --headless "+Lazy! sync" +qa` installs or updates plugins from the current specs.
- `nvim --headless "+MasonToolsInstall" +qa` installs configured LSP/formatter tooling such as `stylua`, `clangd`, and `lua-language-server`.
- `nvim --headless "+checkhealth" +qa` is the quickest smoke test after config changes.

If a change affects startup, plugin loading, or keymaps, validate it in a real Neovim session as well.

## Coding Style & Naming Conventions
All code is Lua. Follow the existing style:

- Use 4-space indentation and keep lines readable rather than aggressively compact.
- Name modules in `snake_case`, for example `lua/user/plugins/markdown_preview.lua`.
- Keep plugin specs isolated to one file per plugin or feature area, each returning a Lua table.
- Prefer small, composable modules over adding more logic to `init.lua`.

`stylua` is installed through Mason in the LSP setup; use it when reformatting Lua files.

## Testing Guidelines
There is no dedicated test suite in this checkout. Treat validation as layered manual verification:

- Run `:checkhealth`.
- Start `nvim` and confirm startup is clean.
- Exercise the affected filetype or plugin workflow directly.

For Rust-specific test helpers, `neotest` is configured but currently optional rather than always loaded.

## Commit & Pull Request Guidelines
Git history is not available in this workspace snapshot, so no local convention can be inferred. Use concise, imperative commit subjects such as `Add clangd fallback flags` or `Split telescope config`.

Pull requests should explain user-visible behavior, list affected modules, and include screenshots or short recordings for UI changes. Mention any required external tools, paths, or host-specific assumptions.
