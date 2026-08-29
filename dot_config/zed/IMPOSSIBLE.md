# What did not port from Neovim to Zed

Source: `research/nvim-config-inventory.md` section 4a, rows classified **X** (IMPOSSIBLE).
33 of 113 classified mappings (29.2%) have no Zed equivalent and are not present in
`keymap.json`.

The three root causes, in order of how much they cost you:

1. Zed has **no quickfix list**. Nine mappings depend on it.
2. Zed has **no scripting layer** — no Vimscript, no Lua, no `init.lua`, no plugin API.
   Extensions are WASM modules limited to languages, debuggers, themes, icon themes,
   snippets and MCP servers. They cannot register keybindings, run on buffer events, or
   shell out. Every mapping whose right-hand side was a Lua function dies here.
3. Zed's `:` commands **accept no arguments**, so the user-command layer cannot be
   rebuilt even in a degraded form.

---

## The 33 mappings

### Quickfix (9)

| Row | Mode | Key | What it did | Why Zed cannot |
|---|---|---|---|---|
| 13 | n | `n` | Next quickfix entry, wrapping at the end | No quickfix list. `editor::GoToDiagnostic` walks LSP diagnostics, a different data source you do not populate |
| 14 | n | `m` | Previous quickfix entry, wrapping | Same |
| 20 | n | `qq` | Append the cursor location to the quickfix list | No quickfix list, and no API to append to any list |
| 83 | n | `dd` (qf buffer) | Delete the quickfix entry under the cursor | No quickfix buffer to attach a buffer-local map to |
| 84 | x | `d` (qf buffer) | Delete the selected range of entries | Same |
| 85 | n | `u` (qf buffer) | Undo the last quickfix edit | Same, plus it drives `lua/quickfix.lua` |
| 86 | n | `<C-r>` (qf buffer) | Redo the last quickfix edit | Same |
| 87 | n | `<Space>s` (qf buffer) | Pseudo-save the edited quickfix list | Same |
| 45 | n | `<leader>fm` | fzf-lua marks picker | Zed vim has marks but no picker over them, and no `:marks` |

### Lua functions and shell-outs (7)

| Row | Mode | Key | What it did | Why Zed cannot |
|---|---|---|---|---|
| 15 | x | `<leader>lr` | Project-wide string replace by shelling out to `fd \| xargs sd` | No subprocess execution from a keybinding, and no input prompt |
| 18 | n | `<leader>ps` | Write the `+` register into `scratch/<name>` and `:tabedit` it | Creates a file, prompts for a name, then opens it — three things a keybinding cannot do |
| 19 | x | `<leader>ys` | Same, but writing the visual selection | Same |
| 24 | n | `<leader>yc` | Compose `path`, line number and `<cword>` into an lldb `breakpoint set --condition` string | String composition in Lua; no equivalent |
| 66 | n,x | `go` | Custom operator-pending map adding the operated range to opencode | Zed has no user-defined operators |
| 67 | n | `goo` | Line variant of the above | Same |
| 93 | n | `<leader>gh` | Diffview file history for the current file | Zed has no per-file commit history view |

### LSP features Zed does not expose (5)

| Row | Mode | Key | What it did | Why Zed cannot |
|---|---|---|---|---|
| 32 | n | `<leader>c` | `LspClangdSwitchSourceHeader` — jump `.h` ⇄ `.cpp` | Zed exposes no action for clangd's `textDocument/switchSourceHeader` extension |
| 35 | n | `<leader>lt` | `vim.lsp.buf.typehierarchy` | Zed has no type-hierarchy UI |
| 43 | n | `<leader>fi` | Incoming call hierarchy | Zed has no call hierarchy at all |
| 44 | n | `<leader>fo` | Outgoing call hierarchy | Same |
| 52 | n | `<leader>yh` | `GitBlameCopySHA` — copy the blame SHA | Zed can show blame but has no copy-SHA action |

### External agent integrations (7)

These are plugin runtimes. Zed has its own agent, so the capability exists, but none of
these specific integrations transfer.

| Row | Mode | Key | What it did | Why Zed cannot |
|---|---|---|---|---|
| 63 | n,x | `<leader>A` | Ask opencode about `@this` | Bridge to an external TUI; no extension point |
| 64 | n,x | `<leader>x` | opencode action picker | Same |
| 68 | n | `<leader>u` | Scroll the opencode session half a page up | Drives a remote session, not the editor |
| 69 | n | `<leader>d` | Scroll the opencode session half a page down | Same |
| 70 | v | `<leader>9v` | `99` visual edit request | Plugin runtime |
| 71 | v | `<leader>9s` | `99` stop all requests | Plugin runtime |
| 73 | i | `<C-F>` | Trigger llama.cpp FIM completion | Zed's edit-prediction providers do not include a llama.cpp FIM backend |

### Everything else (5)

| Row | Mode | Key | What it did | Why Zed cannot |
|---|---|---|---|---|
| 17 | t | `<esc>` | Leave terminal insert mode via `<C-\><C-N>` | Zed's terminal has no vim modal layer |
| 40 | n | `<leader>fh` | fzf-lua `help_tags` | Zed has no `:help` corpus |
| 75 | i | `<C-j>` | Accept one line of the FIM suggestion | Zed's inline completion has full and partial accept, no per-line granularity |
| 81 | x,o | `as` | Treesitter local-scope text object | Zed ships function, class, argument, tag and indent objects — no scope object |
| 82 | n | `[c` | Jump up one treesitter context layer | Zed has sticky scroll but no jump-to-context action |

---

## Deliberately not ported

**`zz` → `:qa!`** (row 10). This one is technically DIRECT — `zed::Quit` exists and the
binding would work. It is left out on purpose.

`zz` means "center the cursor line" in every vim, in Zed's default keymap, and in every
other modal editor. Binding it to quit-the-application makes an extremely common,
reflexive keystroke destructive in a way that has no undo. In Zed it will now center the
cursor. If you want it back, add this to `keymap.json`:

```json
{ "context": "Editor && vim_mode == normal", "bindings": { "z z": "zed::Quit" } }
```

---

## Structural losses beyond individual keys

### The quickfix workflow

`n`, `m`, `qq`, the five `ftplugin/qf.lua` maps and `lua/quickfix.lua`'s per-list
undo/redo stack are one tool built on purpose: collect locations by hand with `qq`, step
through them with `n`/`m`, prune the list in place with `dd`/`d`, and undo a bad prune
with `u`/`<C-r>`. Nine mappings plus a support module, all gone. Zed's diagnostics panel
and search results are read-only result views, not an editable working set. There is no
partial substitute.

Two of these keys also had their vim built-ins reclaimed: in Zed, `n` repeats the search
and `m` sets a mark again.

### Global marks

Zed's marks are buffer-local `'a`–`'z` plus the builtins. Global marks `A`–`Z` do not
exist (upstream issue #13111), and no marks persist across restarts. This is worth
flagging separately because `m` was rebound in the nvim config, so mark usage may be
lower than usual there and the gap will only show up once the habit returns.

### clangd switch-source-header

`<leader>c` toggled between `.h` and `.cpp` through clangd's `switchSourceHeader`
extension. For C++ work this is a daily-dozens binding. Zed's LSP layer speaks to clangd
but exposes no action for that request, and an extension cannot add one.

### Call hierarchy and type hierarchy

`<leader>fi`, `<leader>fo` and `<leader>lt` covered incoming calls, outgoing calls and
the type hierarchy. Zed has neither UI. `editor::FindAllReferences` is the only
navigation primitive available, and it answers a narrower question.

### LLVM / MLIR / TableGen / MIR / CIR support

Fourteen runtime files (`ftdetect/` ×6, `syntax/` ×6, `indent/` ×2) plus two language
servers (`mlir_lsp_server`, `tblgen_lsp_server`). Vim syntax files are unusable in Zed,
which needs tree-sitter grammars. `.ll`, `.mlir`, `.td`, `.mir` and `.cir` files will
open as plain text with no highlighting and no LSP.

This one is not permanently unreachable: Zed's WASM extension API can supply languages
and language servers, so an extension could deliver these filetypes and both servers.
But it means writing tree-sitter grammars from scratch. Nothing in `~/.config/nvim`
carries over into that work. It is a separate project, not a config migration.

### Other non-keymap items with no equivalent

- `jumpoptions=stack,view` — Zed's jump list is not configurable, and jumps under 10
  rows never enter it at all (upstream issue #30183).
- The cursorline-only-in-the-active-window autocmd pair — no per-window conditional
  highlight.
- `:Untab`, `:DeleteTrailingWs`, `:LLVMDoc` + `keywordprg` — user commands cannot be
  defined, and Zed's `:` commands take no arguments.
- `ClangComplete()` omnifunc shelling out to `clang -cc1 -code-completion-at`.
- `utils.lua` (9 helper functions), `meta_configs.lua` OS path branching.
- `brt.nvim`'s sqlite build/run history (`brt_commands.db`).
- Registers and macros exist but do not persist across restarts; there is no shada
  equivalent.
