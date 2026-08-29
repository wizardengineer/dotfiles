# Neovim Config Inventory & Zed Vim-Mode Portability Classification

Source: `/Users/juliusalexandre/.config/nvim` (read-only survey, 2026-08-06)
Legacy vim: `/Users/juliusalexandre/.vim` contains only `.netrwhist`. No `~/.vimrc`. **No legacy vimrc to port.**

---

## 1. Distribution & Plugin Manager

**Hand-rolled config on raw `lazy.nvim`.** Not LazyVim, not kickstart, not NvChad/AstroNvim/LunarVim.

Evidence:
- `init.lua` bootstraps `folke/lazy.nvim` directly and calls `require('lazy').setup({ { import = 'plugins' } })` — no `LazyVim/LazyVim` spec, and `lazy-lock.json` contains **no `LazyVim` entry**.
- `lazyvim.json` exists but is vestigial (`"extras": []`) — a leftover from a past LazyVim trial. It has no effect because LazyVim is never imported.
- Own `lua/configs/{options,keymaps,folding,commands}.lua` module tree, own `lua/lsp/` per-server tree, own `ftdetect/`/`syntax/`/`indent/`/`ftplugin/` runtime files.
- `init.lua` also sources `~/.config/nvim/vimrc` — a **verbatim copy of the LLVM project's `utils/vim/vimrc`** (LLVM coding-style vimscript).

Consequence: there is no upstream keymap layer to inherit. Almost every mapping is either user-written or a plugin's own default. This makes the surface smaller and more auditable than a LazyVim port would be.

### Leader keys
- `vim.g.mapleader = " "` (Space) — set twice: `init.lua:1` and `lua/configs/keymaps.lua:11`
- `vim.g.maplocalleader = " "` (Space) — `lua/configs/keymaps.lua:12`
- The `<Space> -> <Nop>` mapping was deliberately **removed** (comment cites input lag).

### Enabled plugins (50 in `lazy-lock.json`)

| Plugin | Role | Ports to Zed? |
|---|---|---|
| `lazy.nvim` | plugin manager | n/a |
| `ibhagwan/fzf-lua` | **primary picker** (files/grep/LSP/marks/tabs) | partial → Zed file finder + project search |
| `nvim-treesitter` (+`-context`, `-textobjects`) | syntax, folds, textobjects, sticky context | mostly native in Zed |
| `neovim/nvim-lspconfig` | LSP wiring | Zed has own LSP |
| `SmiteshP/nvim-navbuddy` + `nvim-navic` + `nui.nvim` | symbol breadcrumb navigator | ≈ `outline::Toggle` |
| `saghen/blink.cmp` (+`blink.compat`, `friendly-snippets`, `lspkind`) | completion | Zed native |
| `folke/lazydev.nvim` | lua LSP types | n/a |
| `lewis6991/gitsigns.nvim` | hunk signs/stage/reset/preview | Zed git gutter + git panel |
| `f-person/git-blame.nvim` | inline blame + copy SHA | partial |
| `tpope/vim-fugitive` | git porcelain | no equivalent |
| `dlyongemallo/diffview.nvim` | diff/file-history review surface | partial |
| `christoomey/vim-tmux-navigator` | **`<C-hjkl>` across nvim⇄tmux** | Zed panes only |
| `stevearc/oil.nvim` | editable-buffer file manager | ≈ project panel (different model) |
| `kevinhwang91/nvim-ufo` (+`promise-async`) | folds | Zed native folds |
| `kylechui/nvim-surround` | surround ops | Zed vim native |
| `windwp/nvim-autopairs` | autopairs | Zed native |
| `chrisgrieser/nvim-lsp-endhints` | inline hints | ≈ `inlay_hints` |
| `coder/claudecode.nvim` | Claude Code IDE protocol (WebSocket) | Zed has own agent |
| `ldelossa/pi-ide.nvim` | pi CLI IDE protocol | none |
| `NickvanDyke/opencode.nvim` | opencode TUI bridge | none |
| `ThePrimeagen/99` | AI edit agent | none |
| `ggml-org/llama.vim` | **local llama.cpp FIM ghost text** | Zed has own inline completion providers |
| `badumbatish/brt.nvim` + `sqlite.lua` | build/run tasks w/ sqlite history (`brt_commands.db`) | Zed tasks (rework needed) |
| `badumbatish/easyedit.nvim` | (setup body commented out — inert) | n/a |
| `folke/which-key.nvim` | **`enabled = false`** — inactive | n/a |
| `folke/snacks.nvim` | utility lib (dependency) | n/a |
| `mini.nvim` | pulled only as `render-markdown` icon dep; **no mini modules configured** | n/a |
| `MeanderingProgrammer/render-markdown.nvim` | markdown render | Zed native md preview |
| `iamcco/markdown-preview.nvim` | browser md preview | Zed native |
| `OXY2DEV/helpview.nvim` | prettier `:help` | n/a (no vim help in Zed) |
| `nvim-lualine/lualine.nvim`, `nvim-tabline`, `dropbar.nvim` | statusline/tabline/breadcrumb | Zed native chrome |
| `Shatur/neovim-ayu` | colorscheme | Zed theme |
| `HiPhish/rainbow-delimiters.nvim` | bracket colors | ≈ Zed setting |
| `folke/todo-comments.nvim` | TODO highlight | no default keymaps |
| `vyfor/cord.nvim` | Discord presence | none |
| `nvim-web-devicons`, `plenary.nvim`, `nvim-nio` | libs | n/a |

---

## 2. Complete Keymap Surface

**93 explicit user-written keymaps** + **~20 inherited plugin defaults** = **113 classified mappings.**
(Commented-out blocks excluded: the entire nvim-dap set at `keymaps.lua:186-211`, the telescope-era LSP set at `navigations.lua:767-772`, and `which-key`'s `<leader>?` since the plugin is `enabled = false`.)

### 2a. `lua/configs/keymaps.lua` — 31 mappings

| Mode | LHS | RHS / action | Intent |
|---|---|---|---|
| v | `<` | `<gv^` | outdent, keep selection |
| v | `<BS>` | `<gv^` | outdent alias |
| v | `>` | `>gv^` | indent, keep selection |
| v | `<Tab>` | `>gv^` | indent alias |
| n | `<S-l>` | `:tabnext` | next tabpage |
| n | `<S-h>` | `:tabprevious` | prev tabpage |
| n | `<leader>s` | `:w` | save |
| n | `<leader>q` | `:w` | save (note: **not** quit) |
| n | `<leader>S` | `:w` | save |
| n | `zz` | `:qa!` | **quit-all, overrides center-cursor** |
| n | `<leader>n` | `:Navbuddy` | symbol navigator |
| i | `jk` | `<Esc>` | leave insert |
| n | `n` | lua: smart quickfix next w/ wraparound | **overrides search-next** |
| n | `m` | lua: smart quickfix prev w/ wraparound | **overrides set-mark** |
| x | `<leader>lr` | shell `fd \| xargs sd` mass rename | project-wide string replace |
| n | `cp` | lua: `search("(")` then `lcw` | change first arg after paren |
| t | `<esc>` | `<C-\><C-N>` (via `vim.cmd tnoremap`) | terminal → normal mode |
| n | `<leader>ps` | lua: write `"+` reg to `scratch/<name>` + tabedit | paste clipboard to scratch file |
| x | `<leader>ys` | lua: write selection to `scratch/<name>` + tabedit | yank selection to scratch file |
| n | `qq` | lua: append cursor location to quickfix | build a quickfix by hand |
| n | `<leader>/` | `gcc` (remap) | toggle comment line |
| v | `<leader>/` | `gc` (remap) | toggle comment selection |
| n | `<leader>o` | `:Oil` | file manager |
| n | `<leader>yc` | `utils.yank_for_conditional_break` | build lldb `breakpoint set --condition` string |
| n | `<leader>yf` | `utils.yank_full_file` | copy absolute path |
| n | `<leader>yr` | `utils.yank_rel_file` | copy relative path |
| n | `<leader>yl` | `utils.yank_file_with_location` | copy `path:line` |
| n | `<leader>yg` | `utils.yank_all_in_buffer` | yank whole buffer, restore cursor |
| n | `<leader>ya` | `utils.yank_all_in_buffer` | duplicate of `<leader>yg` |
| n | `<leader>va` | `ggVG` | select whole file |
| t | `<leader>gx` | `stopinsert` + `utils.jump_to_file` | open `<cfile>` from terminal, reusing existing tab/window |

### 2b. `lua/lsp/init.lua` — 4 mappings

| Mode | LHS | Action | Intent |
|---|---|---|---|
| n | `<leader>c` | `LspClangdSwitchSourceHeader` | toggle .h/.cpp |
| n | `gd` | `vim.lsp.buf.definition` | go to definition |
| n | `<leader>lr` | `vim.lsp.buf.rename` | rename symbol |
| n | `<leader>lt` | `vim.lsp.buf.typehierarchy` | type hierarchy |

### 2c. `lua/plugins/navigations.lua` (fzf-lua) — 16 mappings

| Mode | LHS | Action | Intent |
|---|---|---|---|
| n | `<leader>ff` | `files` | file picker |
| n | `<leader>fg` | `live_grep_native` | project grep |
| n | `<leader>fb` | `oldfiles` | recent files |
| n | `<leader>e` | `oldfiles` | recent files (fast alias) |
| n | `<leader>fh` | `help_tags` | vim help |
| n | `/` | `blines` | **fuzzy in-buffer search, overrides `/`** |
| n | `<leader>fr` | `resume` | resume last picker |
| n | `<leader>fi` | `lsp_incoming_calls` | call hierarchy in |
| n | `<leader>fo` | `lsp_outgoing_calls` | call hierarchy out |
| n | `<leader>fm` | `marks` | marks picker |
| n | `<leader>fd` | `lsp_finder` | combined ref/def/decl/typedef/impl/calls |
| n | `<leader>gw` | `grep_cword` | grep word under cursor |
| n | `<leader>gr` | `lsp_references` | references |
| x | `<leader>g` | `grep_visual` | grep selection |
| n | `<leader>fs` | `treesitter` | symbols in buffer |
| n | `<leader>la` | `vim.lsp.buf.code_action` | code action |

### 2d. `lua/plugins/gits.lua` (gitsigns + git-blame) — 7 unique

| Mode | LHS | Action | Intent |
|---|---|---|---|
| n | `<leader>yh` | `GitBlameCopySHA` | copy blame SHA (registered twice: L64 and L107) |
| n | `<leader>hb` | `Gitsigns blame` | blame current file |
| n | `<leader>hs` | `stage_hunk` | stage hunk |
| n | `<leader>hr` | `reset_hunk` | reset hunk |
| v | `<leader>hs` | stage selected range | stage hunk (visual) |
| v | `<leader>hr` | reset selected range | reset hunk (visual) |
| n | `<leader>hp` | `preview_hunk` | preview hunk diff |

### 2e. AI/agent plugin maps — 17

| Source | Mode | LHS | Intent |
|---|---|---|---|
| claudecode | x | `<leader>as` | send selection to Claude |
| claudecode | n | `<leader>ab` | add buffer to Claude context |
| claudecode | n | `<leader>aa` | accept Claude diff |
| claudecode | n | `<leader>ad` | deny Claude diff |
| opencode | n,x | `<leader>A` | ask opencode about `@this` |
| opencode | n,x | `<leader>x` | opencode action picker |
| opencode | n,t | `<leader>.` | toggle opencode |
| opencode | n,x | `go` | operator: add range to opencode |
| opencode | n | `goo` | add line to opencode |
| opencode | n | `<leader>u` | opencode half-page up |
| opencode | n | `<leader>d` | opencode half-page down |
| 99 | v | `<leader>9v` | 99 visual edit request |
| 99 | v | `<leader>9s` | 99 stop all requests |
| llama.vim | i | `<Tab>` | accept FIM suggestion, else literal Tab (expr wrapper) |
| llama.vim | i | `<C-F>` | trigger FIM |
| llama.vim | i | `<C-l>` | accept full suggestion |
| llama.vim | i | `<C-j>` | accept one line |
| llama.vim | i | `<C-t>` | accept one word |

(18 rows; `<Tab>` is the user-written expr wrapper at `llama.lua:72`, the other four come from the `keymap_fim_*` opts.)

### 2f. Treesitter textobjects & context — 6

| Mode | LHS | Intent |
|---|---|---|
| x,o | `af` / `if` | function outer / inner |
| x,o | `ac` / `ic` | class outer / inner |
| x,o | `as` | local scope |
| n | `[c` | jump up one treesitter context layer |

### 2g. Buffer-local / filetype maps — 9

| Source | Mode | LHS | Intent |
|---|---|---|---|
| `ftplugin/qf.lua` | n | `dd` | delete quickfix item (with undo stack) |
| `ftplugin/qf.lua` | x | `d` | delete quickfix range |
| `ftplugin/qf.lua` | n | `u` | undo quickfix edit |
| `ftplugin/qf.lua` | n | `<C-r>` | redo quickfix edit |
| `ftplugin/qf.lua` | n | `<Space>s` | pseudo-save quickfix list |
| oil buffer | n | `<C-h>/<C-j>/<C-k>/<C-l>` | window nav inside oil (4 maps) |

### 2h. Lazy `keys =` specs — 2

| Mode | LHS | Intent |
|---|---|---|
| n | `<leader>gv` | Diffview toggle working-tree diff |
| n | `<leader>gh` | Diffview file history for current file |

### 2i. Inherited plugin defaults (~20, not written by the user)

| Source | Keys | Count |
|---|---|---|
| `vim-tmux-navigator` | `<C-h>` `<C-j>` `<C-k>` `<C-l>` (nvim⇄tmux aware) | 4 |
| `nvim-surround` | `ys` `yss` `yS` `ds` `cs` `cS` visual `S` `gS` | 8 |
| `blink.cmp` preset `default` | `<C-space>` `<C-e>` `<C-y>` `<C-n>` `<C-p>` `<C-k>` `<Up>` `<Down>` | 8 |

Note `nvim-autopairs`, `todo-comments`, `nvim-ufo`, `render-markdown` and `treesitter-context` add **no** default keymaps here. `za`/`zo`/`zc` are native vim fold keys, not plugin bindings.

### 2j. Mappings that override built-in vim motions (highest breakage risk)

| LHS | Built-in meaning lost | Replaced with |
|---|---|---|
| `/` | incremental search | fzf-lua fuzzy buffer-line picker |
| `n` | repeat search forward | quickfix next (cycling) |
| `m` | set mark | quickfix prev (cycling) |
| `zz` | center cursor line | `:qa!` |
| `cp` | (unused `c`+`p` motion) | jump-to-paren then change word |
| `qq` | start macro record into reg `q` | append location to quickfix |
| `go` | goto byte N | opencode operator |
| `<S-h>` / `<S-l>` | top/bottom of screen | tabprevious / tabnext |
| `<Tab>` (visual) | — | indent |
| `m`+`n` together | mark/search pair | quickfix stepper pair |

This is a genuinely aggressive remap of core motions. `qq` losing macro-record and `m` losing mark-set are the two most likely to bite in an editor that will *not* have those overrides.

---

## 3. Non-Keymap Behavior

### 3a. Options (`lua/configs/options.lua`)
| Option | Value |
|---|---|
| `hlsearch` | true |
| `incsearch` | true |
| `mouse` | `a` |
| `clipboard` | `+=unnamedplus` (system clipboard for all yanks) |
| `relativenumber` / `number` | true / true (hybrid line numbers) |
| `scrolloff` | 10 |
| `tabstop` | 8 |
| `softtabstop` | 4 |
| `shiftwidth` | 2 |
| `expandtab` | **commented out globally** (set true by the sourced LLVM vimrc, and per-ft in ftplugins) |
| `spell` | false |
| `jumpoptions` | `stack,view` |
| `termguicolors` | true |
| `syntax` | on |
| `autoread` | true |
| `cursorline` | true (`init.lua:31`) |
| `foldmethod` / `foldexpr` / `foldlevel` | `expr` / `nvim_treesitter#foldexpr()` / 99 |
| `foldlevelstart` | 99 (ufo `init`) |
| diagnostics | `virtual_text = true` |
| `ignorecase` / `smartcase` | **never set** — vim defaults (case-sensitive); fzf-lua's rg uses `--smart-case` |

From the sourced LLVM `vimrc`: `nocompatible`, `softtabstop=2`, `shiftwidth=2`, `expandtab`, `smarttab`, `cinoptions=:0,g0,(0,Ws,l1`, `smartindent`/`cindent` per filetype, `omnifunc=ClangComplete`.

Note the ordering conflict: `init.lua` sources the LLVM vimrc **after** `require("configs")`, so LLVM's `softtabstop=2`/`shiftwidth=2`/`expandtab` win over `options.lua`'s `softtabstop=4`.

### 3b. Autocmds
| Event(s) | Behavior |
|---|---|
| `FocusGained,BufEnter,CursorHold,CursorHoldI` | `checktime` — reload files changed on disk (paired with terminal coding agents) |
| `BufReadPost` | restore cursor to last edit position via `"` mark |
| `TextYankPost` | highlight yanked region, 300ms |
| `InsertEnter,CmdlineEnter` | `nohlsearch` |
| `InsertLeave,WinEnter` | `set cursorline` (active window only) |
| `InsertEnter,WinLeave` | `set nocursorline` |
| `User OilEnter` | auto-open oil preview in `botright` split |
| `BufWritePre` | format-on-save hook present but **entirely commented out** |
| LLVM vimrc `BufWinEnter` | `matchadd` highlight of >80-column text and trailing whitespace |
| LLVM vimrc `InsertEnter/InsertLeave` | suppress trailing-whitespace highlight while typing |
| LLVM vimrc `filetype` group | `*Makefile*`→make, `*.ll`→llvm, `*.td`→tablegen, `*.rst`→rest; `noexpandtab` in make |

### 3c. Custom commands & functions
| Name | Source | Purpose |
|---|---|---|
| `:Format` | `configs/commands.lua` | `vim.lsp.buf.format{async=true}` |
| `:DeleteTrailingWs` | LLVM vimrc | `%s/\s\+$//` |
| `:Untab` | LLVM vimrc | `%s/\t/  /g` |
| `:LLVMDoc` | `after/ftplugin/llvm.lua` | buffer-local; opens bundled `llvm-langref.rst.txt` and searches for the keyword under cursor; wired to `keywordprg` so `K` works |
| `ClangComplete()` | LLVM vimrc | vimscript `omnifunc` shelling out to `clang -cc1 -code-completion-at` |
| `utils.lua` (9 fns) | `lua/utils.lua` | visual-text extraction, jasmine escaping, yank helpers, `jump_to_file` tab/window reuse |
| `quickfix.lua` | `lua/quickfix.lua` | per-list undo/redo stack for quickfix edits |
| `meta_configs.lua` | `lua/meta_configs.lua` | OS-branching absolute paths to LLVM build dirs, clangir repo, prebuilt LLVM |

### 3d. Filetype/syntax runtime files (LLVM toolchain work)
- `ftdetect/`: `llvm.vim`, `llvm-lit.vim`, `mir.vim`, `mlir.vim`, `tablegen.vim`, `rst.vim`
- `syntax/`: `llvm.vim`, `mlir.vim`, `mir.vim`, `machine-ir.vim`, `tablegen.vim`, `cir.vim`
- `indent/`: `llvm.vim`, `mlir.vim`
- `ftplugin/`: `c.lua` (2-space, expandtab), `go.lua` (8-wide, expandtab), `llvm.vim`, `mir.vim`, `mlir.vim`, `tablegen.vim`, `qf.lua`, `empty_cpp.lua`
- `lua/filetype.lua`: registers `.cir` → `cir`

### 3e. LSP servers configured (`lua/lsp/`)
Enabled: `lua_ls`, `pylsp`, `clangd`, `tblgen_lsp_server`, `mlir_lsp_server`, `rust_analyzer`.
Disabled/commented: `cir_lsp_server`, `fortls`, `gleam`, `esbonio`, `cmake-language-server`.
`vim.lsp.log.set_level(DEBUG)` is on.

---

## 4. Full Classification Table

Legend: **D** = DIRECT, **A** = APPROXIMATE, **Z** = ZED-NATIVE, **X** = IMPOSSIBLE.

### 4a. Keymaps (113)

| # | Mode | LHS | Intent | Bucket | Zed target / why not |
|---|---|---|---|---|---|
| 1 | v | `<` | outdent keep selection | Z | Zed vim already preserves the selection after `<` |
| 2 | v | `>` | indent keep selection | Z | same |
| 3 | v | `<BS>` | outdent alias | D | `"vim::Outdent"` |
| 4 | v | `<Tab>` | indent alias | D | `"vim::Indent"` |
| 5 | n | `<S-l>` | next tabpage | A | `pane::ActivateNextItem` — Zed tabs are buffers, nvim tabpages are window layouts |
| 6 | n | `<S-h>` | prev tabpage | A | `pane::ActivatePreviousItem`, same caveat |
| 7 | n | `<leader>s` | save | D | `workspace::Save` |
| 8 | n | `<leader>q` | save | D | `workspace::Save` |
| 9 | n | `<leader>S` | save | D | `workspace::Save` |
| 10 | n | `zz` | `:qa!` | D | `zed::Quit` (must explicitly override Zed's center-cursor `zz`) |
| 11 | n | `<leader>n` | Navbuddy | A | `outline::Toggle` — flat fuzzy list, not a hierarchical drill-down panel |
| 12 | i | `jk` | escape insert | D | `{"j k": "vim::NormalBefore"}` in `Editor && vim_mode == insert` |
| 13 | n | `n` | quickfix next, cycling | X | Zed has no quickfix list; `editor::GoToDiagnostic` is a different data source |
| 14 | n | `m` | quickfix prev, cycling | X | same |
| 15 | x | `<leader>lr` | shell mass rename | X | needs `fd`+`sd` subprocess + input prompt; `workspace::NewSearch` replace is manual and non-equivalent |
| 16 | n | `cp` | search `(` then `cw` | A | `workspace::SendKeystrokes` with `f ( l c w` — **same-line only**; the lua `search("(")` scans forward across lines |
| 17 | t | `<esc>` | terminal → normal mode | X | Zed's terminal has no vim modal layer |
| 18 | n | `<leader>ps` | clipboard → scratch file | X | file creation + prompt + tabedit from a keymap |
| 19 | x | `<leader>ys` | selection → scratch file | X | same |
| 20 | n | `qq` | append loc to quickfix | X | no quickfix |
| 21 | n | `<leader>/` | comment line | D | `editor::ToggleComments` |
| 22 | v | `<leader>/` | comment selection | D | `editor::ToggleComments` |
| 23 | n | `<leader>o` | Oil | A | `project_panel::ToggleFocus` — tree panel, not an editable-buffer filesystem |
| 24 | n | `<leader>yc` | lldb conditional-breakpoint string | X | composes path+line+cword into a shell string |
| 25 | n | `<leader>yf` | copy absolute path | D | `editor::CopyPath` |
| 26 | n | `<leader>yr` | copy relative path | D | `editor::CopyRelativePath` |
| 27 | n | `<leader>yl` | copy `path:line` | D | `editor::CopyFileLocation` |
| 28 | n | `<leader>yg` | yank buffer, restore cursor | D | `workspace::SendKeystrokes` with `m z g g V G y \`z` — reproduces the yank *and* the cursor restore (buffer-local mark is sufficient here) |
| 29 | n | `<leader>ya` | duplicate of #28 | D | same |
| 30 | n | `<leader>va` | select whole file | D | `editor::SelectAll` |
| 31 | t | `<leader>gx` | open `<cfile>` from terminal | A | Zed terminal cmd-click opens paths; no tab/window-reuse logic |
| 32 | n | `<leader>c` | clangd switch source/header | X | Zed exposes no `clangd/switchSourceHeader` action |
| 33 | n | `gd` | go to definition | Z | Zed vim binds `g d` by default |
| 34 | n | `<leader>lr` | rename symbol | D | `editor::Rename` |
| 35 | n | `<leader>lt` | type hierarchy | X | Zed has no type-hierarchy UI |
| 36 | n | `<leader>ff` | file picker | D | `file_finder::Toggle` |
| 37 | n | `<leader>fg` | project grep | D | `pane::DeploySearch` / `workspace::NewSearch` |
| 38 | n | `<leader>fb` | recent files | A | `file_finder::Toggle` shows recents when empty; not a dedicated MRU picker |
| 39 | n | `<leader>e` | recent files alias | A | same |
| 40 | n | `<leader>fh` | vim help tags | X | Zed has no `:help` corpus |
| 41 | n | `/` | fuzzy buffer-line picker | A | `buffer_search::Deploy` is incremental regex, not fuzzy line-select |
| 42 | n | `<leader>fr` | resume last picker | A | Zed reopens search with the previous query, but pickers don't resume state |
| 43 | n | `<leader>fi` | incoming calls | X | no call hierarchy in Zed |
| 44 | n | `<leader>fo` | outgoing calls | X | no call hierarchy in Zed |
| 45 | n | `<leader>fm` | marks picker | X | Zed vim has marks, no picker over them |
| 46 | n | `<leader>fd` | combined LSP finder | A | `editor::FindAllReferences` covers one of seven providers |
| 47 | n | `<leader>gw` | grep word under cursor | A | search can be deployed, but doesn't seed `<cword>` in one action |
| 48 | n | `<leader>gr` | LSP references | D | `editor::FindAllReferences` |
| 49 | x | `<leader>g` | grep selection | A | `pane::DeploySearch` picks up selection, different UX |
| 50 | n | `<leader>fs` | buffer symbols | D | `outline::Toggle` |
| 51 | n | `<leader>la` | code action | D | `editor::ToggleCodeActions` |
| 52 | n | `<leader>yh` | copy blame SHA | X | Zed shows blame; no copy-SHA action |
| 53 | n | `<leader>hb` | blame file | A | `editor::ToggleGitBlame` — inline gutter blame, not a blame buffer |
| 54 | n | `<leader>hs` | stage hunk | D | `git::StageAndNext` / `git::ToggleStaged` |
| 55 | n | `<leader>hr` | reset hunk | D | `git::Restore` |
| 56 | v | `<leader>hs` | stage selected range | D | same action honors selection |
| 57 | v | `<leader>hr` | reset selected range | D | same |
| 58 | n | `<leader>hp` | preview hunk | A | `editor::ToggleSelectedDiffHunks` — inline expansion, not a float |
| 59 | x | `<leader>as` | send selection to Claude | A | `agent::QuoteSelection` into Zed's own agent panel |
| 60 | n | `<leader>ab` | add buffer to Claude ctx | A | Zed agent context add; different protocol |
| 61 | n | `<leader>aa` | accept Claude diff | A | Zed agent has its own accept; not the claudecode WebSocket flow |
| 62 | n | `<leader>ad` | deny Claude diff | A | same |
| 63 | n,x | `<leader>A` | ask opencode | X | external TUI agent bridge |
| 64 | n,x | `<leader>x` | opencode picker | X | same |
| 65 | n,t | `<leader>.` | toggle opencode | A | `terminal_panel::ToggleFocus` gets you a terminal, not the integration |
| 66 | n,x | `go` | opencode operator | X | custom operator-pending over an external agent |
| 67 | n | `goo` | opencode line | X | same |
| 68 | n | `<leader>u` | opencode half-page up | X | drives a remote session, not the editor |
| 69 | n | `<leader>d` | opencode half-page down | X | same |
| 70 | v | `<leader>9v` | 99 visual edit | X | plugin runtime |
| 71 | v | `<leader>9s` | 99 stop requests | X | plugin runtime |
| 72 | i | `<Tab>` | accept FIM else literal Tab | Z | Zed's Tab already accepts inline completion and falls through otherwise |
| 73 | i | `<C-F>` | trigger FIM | X | llama.cpp FIM backend unsupported (Zed: Copilot/Supermaven/Zeta only) |
| 74 | i | `<C-l>` | accept full suggestion | A | `editor::AcceptInlineCompletion`, different provider |
| 75 | i | `<C-j>` | accept one line | X | Zed has no accept-one-line granularity |
| 76 | i | `<C-t>` | accept one word | A | `editor::AcceptPartialInlineCompletion` ≈ word granularity |
| 77 | x,o | `af` | function outer | Z | Zed vim ships `a f` |
| 78 | x,o | `if` | function inner | Z | Zed vim ships `i f` |
| 79 | x,o | `ac` | class outer | Z | Zed vim ships `a c` |
| 80 | x,o | `ic` | class inner | Z | Zed vim ships `i c` |
| 81 | x,o | `as` | local scope | X | no scope textobject in Zed |
| 82 | n | `[c` | jump to treesitter context | X | Zed has sticky scroll, no jump-to-context action |
| 83 | n | `dd` (qf) | delete qf item | X | no quickfix |
| 84 | x | `d` (qf) | delete qf range | X | no quickfix |
| 85 | n | `u` (qf) | undo qf edit | X | no quickfix |
| 86 | n | `<C-r>` (qf) | redo qf edit | X | no quickfix |
| 87 | n | `<Space>s` (qf) | pseudo-save qf | X | no quickfix |
| 88 | n | `<C-h>` (oil) | window left | D | `workspace::ActivatePaneLeft` |
| 89 | n | `<C-j>` (oil) | window down | D | `workspace::ActivatePaneDown` |
| 90 | n | `<C-k>` (oil) | window up | D | `workspace::ActivatePaneUp` |
| 91 | n | `<C-l>` (oil) | window right | D | `workspace::ActivatePaneRight` |
| 92 | n | `<leader>gv` | Diffview toggle | A | `git::Diff` / `git_panel::ToggleFocus` — project diff, not diffview's layout |
| 93 | n | `<leader>gh` | Diffview file history | X | Zed has no per-file commit history view |
| 94 | n | `<C-h>` (tmux-nav) | pane left across nvim⇄tmux | A | `workspace::ActivatePaneLeft` works inside Zed; the tmux boundary hop is gone |
| 95 | n | `<C-j>` (tmux-nav) | pane down | A | same |
| 96 | n | `<C-k>` (tmux-nav) | pane up | A | same |
| 97 | n | `<C-l>` (tmux-nav) | pane right | A | same |
| 98 | n | `ys` (surround) | add surround | Z | Zed vim native surround |
| 99 | n | `yss` | surround line | Z | native |
| 100 | n | `yS` | surround to new lines | Z | native |
| 101 | n | `ds` | delete surround | Z | native |
| 102 | n | `cs` | change surround | Z | native |
| 103 | n | `cS` | change surround to new lines | Z | native |
| 104 | x | `S` | surround selection | Z | native |
| 105 | x | `gS` | surround selection new lines | Z | native |
| 106 | i | `<C-space>` (blink) | open completion menu | Z | Zed has its own completion keys |
| 107 | i | `<C-e>` | cancel completion | Z | native |
| 108 | i | `<C-y>` | accept completion | Z | native |
| 109 | i | `<C-n>` | next item | Z | native |
| 110 | i | `<C-p>` | prev item | Z | native |
| 111 | i | `<C-k>` | signature/docs toggle | Z | native |
| 112 | i | `<Up>` | prev item | Z | native |
| 113 | i | `<Down>` | next item | Z | native |

### 4b. Options & settings

| Item | Bucket | Zed target |
|---|---|---|
| `clipboard=unnamedplus` | D | `"vim": {"use_system_clipboard": "always"}` |
| `relativenumber` + `number` | D | `"relative_line_numbers": true` |
| `scrolloff=10` | D | `"vertical_scroll_margin": 10` |
| `cursorline` | D | `"current_line_highlight": "line"` |
| diagnostics `virtual_text` | D | `"diagnostics": {"inline": {"enabled": true}}` |
| yank highlight 300ms | D | `"vim": {"highlight_on_yank_duration": 300}` |
| `:Format` command | D | `editor::Format` |
| ftplugin `c.lua` 2-space | D | `"languages": {"C": {"tab_size": 2, "hard_tabs": false}}` |
| ftplugin `go.lua` 8-wide | D | `"languages": {"Go": {"tab_size": 8}}` |
| lsp inlay/endhints | D | `"inlay_hints": {"enabled": true}` |
| `tabstop=8` + `softtabstop=4` + `shiftwidth=2` (three different widths) | A | Zed has one `tab_size` per language — the three-way split cannot be represented |
| 80-column `matchadd` overflow highlight | A | `"wrap_guides": [80], "show_wrap_guide": true` — a guide line, not highlighted overflow text |
| trailing-whitespace highlight | A | `"show_whitespaces": "trailing"` + `"remove_trailing_whitespace_on_save": true` |
| `:DeleteTrailingWs` | A | covered by the on-save setting, no on-demand command |
| `InsertEnter` → `nohlsearch` | A | Zed clears search highlight on its own schedule |
| clangd / pylsp / rust-analyzer configs | A | Zed `"lsp": {...}` via extensions; option shapes differ |
| `hlsearch` / `incsearch` | Z | Zed vim default |
| `ignorecase`/`smartcase` (never set; rg smart-case) | Z | `"use_smartcase_search"` default |
| `termguicolors`, `syntax on` | Z | Zed theme system |
| `mouse=a` | Z | default |
| `autoread` + `checktime` autocmd | Z | Zed auto-reloads externally-changed files |
| `BufReadPost` cursor restore | Z | Zed restores editor state per file |
| treesitter folds, `foldlevel=99` | Z | Zed folds via tree-sitter; `za`/`zo`/`zc` work |
| `smartindent`/`cindent`/`cinoptions` | Z | Zed auto-indents from tree-sitter |
| `spell=false` | Z | Zed has no spellcheck to disable |
| nvim-autopairs | Z | `"use_autoclose": true` default |
| rainbow-delimiters | Z | Zed colors matching brackets natively |
| `jumpoptions=stack,view` | X | Zed's jump list is not configurable |
| cursorline only in active window (autocmd pair) | X | no per-window conditional highlight |
| `:Untab` | X | no equivalent command |
| `:LLVMDoc` + `keywordprg` | X | needs buffer-local command + doc-file search |
| `ClangComplete()` omnifunc | X | vimscript function shelling to `clang -cc1` |
| `quickfix.lua` undo/redo stack | X | no quickfix |
| `utils.lua` (9 helper fns) | X | lua runtime |
| `meta_configs.lua` OS path branching | X | lua runtime |
| `ftdetect/` (6 files) | X | Zed filetype mapping can't run vimscript detection logic |
| `syntax/` llvm, mlir, mir, machine-ir, tablegen, cir (6 files) | X | Zed needs tree-sitter grammars; vim syntax files are unusable |
| `indent/` llvm, mlir | X | same |
| `mlir_lsp_server`, `tblgen_lsp_server` | X | no Zed extension exists for these |
| `brt.nvim` sqlite task history | X | Zed tasks are a different model, no history DB |
| fugitive, oil, diffview, 99, opencode, pi-ide, claudecode, llama.vim, which-key | X | plugin runtimes |

---

## 5. Quantification

**Total classified keymaps: 113** (93 user-written + 20 plugin defaults)

| Bucket | Count | % of 113 |
|---|---|---|
| DIRECT | 29 | **25.7%** |
| ZED-NATIVE | 24 | **21.2%** |
| APPROXIMATE | 27 | **23.9%** |
| IMPOSSIBLE | 33 | **29.2%** |

Derived figures:
- **Clean carry-over (DIRECT + ZED-NATIVE): 53 / 113 = 46.9%**
- **Usable with behavior drift (+ APPROXIMATE): 80 / 113 = 70.8%**
- **Lost outright: 33 / 113 = 29.2%**

Counting only the **93 user-written** mappings (excluding inherited plugin defaults), the picture is worse, because the plugin defaults are exactly the part Zed reimplements natively:

| Bucket | Count | % of 93 |
|---|---|---|
| DIRECT | 29 | 31.2% |
| ZED-NATIVE | 8 | 8.6% |
| APPROXIMATE | 23 | 24.7% |
| IMPOSSIBLE | 33 | 35.5% |

So **35.5% of what this user actually typed into their config cannot be reproduced in Zed at all**, and only 39.8% survives without semantic drift.

### Corrections applied after the Zed capabilities review

Three items moved bucket once `workspace::SendKeystrokes` (chained keystroke sequences in `keymap.json`) was confirmed available:

| Item | Was | Now | Reason |
|---|---|---|---|
| n `cp` | IMPOSSIBLE | APPROXIMATE | `f ( l c w` via SendKeystrokes; same-line only, so semantics drift |
| n `<leader>yg` | APPROXIMATE | DIRECT | `m z g g V G y \`z` reproduces yank + cursor restore exactly |
| n `<leader>ya` | APPROXIMATE | DIRECT | same |

Constraints confirmed that did **not** move anything, but tighten the reasoning:
- **No lua/vimscript/`init.lua` loading and no plugin API.** Extensions are WASM and may supply only languages, debuggers, themes, snippets, and MCP servers — never keybindings or buffer hooks. This confirms every autocmd, `utils.lua` helper, `quickfix.lua` module and plugin-runtime mapping in the IMPOSSIBLE bucket; none of them have a hook point to attach to.
- **Zed `:` commands accept no arguments.** Confirms `:Untab`, `:DeleteTrailingWs`, `:LLVMDoc` and the whole user-command layer are IMPOSSIBLE, not merely awkward.
- **Marks are buffer-local only.** `<leader>fm` (marks picker) stays IMPOSSIBLE, and this additionally means global marks `A`–`Z` do not exist in Zed at all — a loss beyond the mapping table, worsened by `m` being rebound in nvim so the user may not yet realize how much they rely on marks.
- **Built-in `gc`, `gR`, `cx`, indentwise, treesitter textobjects, opt-in `sneak`/`HelixJumpToWord`** confirm the ZED-NATIVE bucket (surround ×8, `af`/`if`/`ac`/`ic`, `gd`) and confirm `<leader>/` → `editor::ToggleComments` as DIRECT. `as` (local scope) remains IMPOSSIBLE — indentwise and the shipped textobject set contain no scope object.

**One reclassification note outside the keymap table:** LLVM/MLIR/TableGen/MIR/CIR language support is still IMPOSSIBLE *to port*, but it is not unreachable — Zed's WASM extension API can supply languages and language servers, so the `.ll`/`.mlir`/`.td`/`.mir`/`.cir` filetypes plus `mlir_lsp_server` and `tblgen_lsp_server` could be delivered by **writing a new Zed extension from scratch** (tree-sitter grammars, not the existing vim syntax files). That is a separate project, not a config migration, and nothing in `~/.config/nvim` carries over into it.

Non-keymap items break down roughly as: 10 DIRECT, 6 APPROXIMATE, 11 ZED-NATIVE, 16 IMPOSSIBLE — the IMPOSSIBLE side dominated by the LLVM/MLIR filetype+syntax+indent runtime (14 files) and the lua helper modules.

---

## 6. Highest-Value Mappings (missed within five minutes)

Ordered by how fast the absence would register:

1. **`/` → fzf-lua `blines`** — they have rebound the single most-pressed key in vim to a fuzzy line picker. In Zed, `/` reverts to incremental search. Instant, constant friction. *(APPROXIMATE)*
2. **`n` → quickfix-next and `m` → quickfix-prev** — `n` no longer repeats the search, `m` no longer sets a mark. These two are pressed dozens of times an hour and there is **no Zed target at all**. This is the single largest hole in the port. *(IMPOSSIBLE)*
3. **`jk` → `<Esc>`** — every exit from insert mode. Trivially portable, but catastrophic if forgotten. *(DIRECT)*
4. **`<leader>ff` / `<leader>fg`** — file finder and project grep, the two most-used leader bindings. *(DIRECT)*
5. **`<leader>s` / `<leader>q` / `<leader>S` → save** — note all three save; `<leader>q` does *not* quit. Any Zed config must preserve that or they'll expect a quit and get a write. *(DIRECT)*
6. **`<C-h/j/k/l>` tmux-aware pane navigation** — this user runs coding agents in tmux panes (claudecode, opencode, pi-ide all assume it). Inside Zed these become Zed-pane-only; the nvim⇄tmux hop is gone, which changes their whole window-management workflow. *(APPROXIMATE)*
7. **`zz` → `:qa!`** — in Zed, `zz` will silently center the cursor instead of quitting. Not an error, just a no-op where they expect an exit; mildly disorienting, and it must be explicitly overridden. *(DIRECT once bound)*
8. **`<leader>/` → toggle comment** — high-frequency editing verb. *(DIRECT)*
9. **`<leader>e` → recent files** — a two-key MRU jump they clearly use as a primary navigation path (it duplicates `<leader>fb` precisely so it can be fast). *(APPROXIMATE)*
10. **`<leader>hs` / `<leader>hr` / `<leader>hp`** — stage/reset/preview hunk. Staging maps cleanly; preview drifts. *(DIRECT / DIRECT / APPROXIMATE)*
11. **`<S-h>` / `<S-l>` → tab switching** — remaps screen-top/screen-bottom motions, so both the new behavior and the lost built-in matter. *(APPROXIMATE)*
12. **`<leader>c` → clangd switch source/header** — for a C++/LLVM developer this is a daily-dozens binding, and Zed exposes no action for it. *(IMPOSSIBLE)*

### Structural risks beyond individual keys

- **The quickfix workflow is the deepest casualty.** `n`, `m`, `qq`, the whole `ftplugin/qf.lua` editing layer (`dd`/`d`/`u`/`<C-r>`/`<Space>s`) and `lua/quickfix.lua`'s per-list undo stack form one coherent tool this user clearly built on purpose. Nine mappings plus a support module, all IMPOSSIBLE. Zed's diagnostics panel and search results are not a substitute.
- **LLVM/MLIR/TableGen/MIR/CIR language support vanishes.** Fourteen `ftdetect`/`syntax`/`indent` files plus two LSP servers (`mlir_lsp_server`, `tblgen_lsp_server`) with no Zed extension. Given `meta_configs.lua` points at an `llvm-project` build tree and a `clangir` checkout, this is the user's primary domain — Zed would show `.ll`, `.mlir`, `.td`, `.mir` and `.cir` files as plain text with no LSP.
- **Four separate AI-agent integrations** (claudecode, opencode, 99, pi-ide) plus a local llama.cpp FIM provider, 18 mappings total. Zed has its own agent, so the *capability* exists, but none of these specific integrations transfer and the local-model FIM path has no Zed equivalent.
- **The `~/.config/nvim/vimrc` LLVM style layer** (80-col highlight, trailing-whitespace highlight, `cinoptions`, `ClangComplete`) partially maps to `wrap_guides` / `show_whitespaces` but the omnifunc and the exact highlight semantics do not.
