# Zed Vim Mode: Capabilities, Configuration, and Neovim Migration Limits

Research date: 2026-08-06
Local Zed version: **1.14.2** (from `/Applications/Zed.app/Contents/Info.plist`, `CFBundleShortVersionString`)
Latest stable Zed: **1.14.2, released 2026-08-05** (<https://zed.dev/releases/stable/latest>) — the local install is current.

Primary sources:
- <https://zed.dev/docs/vim> (mirror: <https://raw.githubusercontent.com/zed-industries/zed/main/docs/src/vim.md>)
- <https://zed.dev/docs/key-bindings>
- <https://zed.dev/docs/configuring-zed>
- <https://raw.githubusercontent.com/zed-industries/zed/main/crates/vim/src/vim.rs>
- <https://raw.githubusercontent.com/zed-industries/zed/main/assets/keymaps/vim.json>
- <https://zed.dev/blog/zed-decoded-vim> (2024-06-13)
- <https://zed.dev/blog/vim-2025> (2025-01-22)

> **Drift caveat:** source files were read from the `main` branch, not the `v1.14.2` tag. Settings names and
> default keymap contents are stable enough that this is low risk, but anything marked from source could in
> principle be slightly ahead of 1.14.2. Marked **UNVERIFIED-DRIFT** where it matters.

---

## 1. Enabling vim mode and the `vim` settings block

### Enabling

Vim mode is a **top-level boolean**, not a member of the `vim` block:

```json
{
  "vim_mode": true
}
```

Default is `"vim_mode": false` (`assets/settings/default.json`). It can also be toggled from the welcome
screen checkbox or via the command palette action `workspace: toggle vim mode` (<https://zed.dev/docs/vim>).

Your current `/Users/juliusalexandre/.config/zed/settings.json` already sets `"vim_mode": true` at line 13.

There is a sibling top-level setting `"helix_mode": false`. Per `assets/settings/default.json`, **enabling
helix mode automatically enables vim mode**. It is a distinct modal scheme, not a vim tweak.

### The `vim` block — every key

Field list taken from the `VimSettings` struct in `crates/vim/src/vim.rs` cross-checked against the settings
table in `docs/src/vim.md`.

| Key | Type | Accepted values | Default | Notes |
|---|---|---|---|---|
| `default_mode` | enum | `"normal"`, `"insert"`, `"replace"`, `"visual"`, `"visual_line"`, `"visual_block"`, `"helix_normal"` | `"normal"` | Mode new buffers open in |
| `use_system_clipboard` | enum | `"always"`, `"never"`, `"on_yank"` | `"always"` | `"on_yank"` is the closest thing to a working blackhole-register workflow |
| `use_smartcase_find` | bool | `true` / `false` | `false` | Lowercase target in `f`/`t`/`F`/`T` matches case-insensitively |
| `use_regex_search` | bool | `true` / `false` | `true` | `/` and `?` use regex |
| `gdefault` | bool | `true` / `false` | `false` | `:s` replaces all matches on a line without `/g` |
| `toggle_relative_line_numbers` | bool | `true` / `false` | `false` | Relative in normal mode, absolute in insert mode |
| `highlight_on_yank_duration` | integer (ms) | `0` disables | `200` | |
| `custom_digraphs` | object `{string: string}` | e.g. `{"fz": "🧟‍♀️"}` | `{}` | Used by `ctrl-k` in insert mode |
| `cursor_shape` | object | per-mode cursor shapes | — | See note below |
| `show_edit_predictions_in_normal_mode` | bool | `true` / `false` | — (source-only) | Not in the docs settings table; present in `VimSettings`. **UNVERIFIED-DRIFT** |
| `use_multiline_find` | — | — | — | **DEPRECATED.** See below |

Documented example (<https://zed.dev/docs/vim>):

```json
{
  "vim": {
    "default_mode": "insert",
    "use_system_clipboard": "never",
    "use_smartcase_find": true,
    "use_regex_search": true,
    "gdefault": true,
    "toggle_relative_line_numbers": true,
    "highlight_on_yank_duration": 50,
    "custom_digraphs": {
      "fz": "🧟‍♀️"
    }
  }
}
```

#### `use_multiline_find` is deprecated — do not use it

The docs settings table lists `use_multiline_find` as **deprecated**, and the field is **absent** from the
`VimSettings` struct in `crates/vim/src/vim.rs`. The behaviour moved into **action arguments** on the
find-motion bindings. The default keymap now binds:

```json
"f": ["vim::PushFindForward", { "before": false, "multiline": false }]
```

To get multiline `f`/`t` behaviour today you rebind with `"multiline": true` rather than setting a flag:

```json
{
  "context": "vim_mode == normal || vim_mode == visual",
  "bindings": {
    "f": ["vim::PushFindForward", { "before": false, "multiline": true }],
    "t": ["vim::PushFindForward", { "before": true,  "multiline": true }],
    "shift-f": ["vim::PushFindBackward", { "after": false, "multiline": true }],
    "shift-t": ["vim::PushFindBackward", { "after": true,  "multiline": true }]
  }
}
```

**UNVERIFIED:** the exact argument key names for `PushFindBackward` (`after` vs `before`) were not read
directly out of `vim.json`; confirm against `zed: open default keymap` before relying on them.

#### `cursor_shape`

`cursor_shape` in the `vim` block is typed `CursorShapeSettings` (a per-mode struct), distinct from the
global top-level `"cursor_shape": "bar"` setting in `assets/settings/default.json`. The valid shapes are the
standard Zed set (`"bar"`, `"block"`, `"underline"`, `"hollow"`).

**UNVERIFIED:** the exact per-mode field names inside `CursorShapeSettings` (presumably `normal`, `insert`,
`replace`, `visual`) were not confirmed — `crates/settings/src/settings_content/vim.rs` returned 404, so the
struct definition was not located. Confirm with `zed: open default settings` and search for `cursor_shape`
inside the `vim` block, or use the settings-file JSON schema autocomplete in Zed itself.

### Related settings that are NOT inside the `vim` block

- `"relative_line_numbers": "disabled"` — global, separate from `vim.toggle_relative_line_numbers`.
- `"command_aliases"` — **top level**, not under `vim`. This is the mechanism for `:` command mnemonics,
  since Zed ships none by default:

```json
{
  "command_aliases": {
    "zlog": "zed::OpenLog",
    "newf": "workspace::NewFile"
  }
}
```

- `"base_keymap"` — see §6, it changed in 1.14.2.

---

## 2. `~/.config/zed/keymap.json` schema

Source: <https://zed.dev/docs/key-bindings>. File does not currently exist in your config dir; create it.

### Top-level shape

An array of context blocks:

```json
[
  {
    "context": "Editor && vim_mode == normal && !menu",
    "use_key_equivalents": true,
    "bindings": {
      "g d": "editor::GoToDefinition",
      "space f f": "file_finder::Toggle",
      "cmd-r": null
    }
  }
]
```

### Context predicate operators

| Operator | Meaning |
|---|---|
| `&&` | AND |
| `\|\|` | OR |
| `!` | NOT |
| `==` | attribute equality, e.g. `vim_mode == normal` |
| `>` | ancestor/descendant: `A > B` matches when an ancestor layer matches `A` and the current layer matches `B` |
| `( )` | grouping, e.g. `(X \|\| Y) && Z` |

### Context nodes and attributes

Structural nodes: `Workspace` (root), `Pane`, `Editor`, `Terminal`, `ProjectPanel`, `Dock`, `Picker`,
`OutlinePanel`, `GitPanel`, `GitGraph`, `BufferSearchBar`, `MarkdownPreview`, `NotebookEditor`, and others.
Attributes: `mode` (e.g. `mode == full`, `mode == auto_height`), `extension`, `vim_mode`, `vim_operator`,
`os` (e.g. `os == windows`), `keyboard_layout`.

### Vim-specific contexts

From `docs/src/vim.md` and the shipped `assets/keymaps/vim.json`:

| Context | Meaning |
|---|---|
| `VimControl` | Shorthand for normal-ish control: normal, visual, or operator-pending |
| `vim_mode == normal` | Normal mode |
| `vim_mode == visual` | Visual (any visual variant) |
| `vim_mode == insert` | Insert mode |
| `vim_mode == replace` | Replace mode |
| `vim_mode == waiting` | Waiting for an arbitrary keypress (e.g. after `f`, `r`, `m`) |
| `vim_mode == operator` | Operator-pending, waiting for a further binding |
| `vim_mode == literal` | Literal-insert (`ctrl-v` style) |
| `vim_mode == helix_normal` / `helix_select` | Helix modes |
| `vim_operator == <op>` | The pending operator: `c`, `d`, `y`, `a`, `i`, `ys`, `cs`, `gu`, `gU`, `g~`, `g?`, `gq`, `gc`, `gb`, `gR`, `cx`, `>`, `<`, `eq`, `sh`, and helix variants |
| `VimCount` | A numeric count is being accumulated |

Non-vim contexts you will need constantly when remapping: `!menu`, `showing_completions`,
`showing_code_actions`, `showing_signature_help`, `in_replace`, `not_editing`, `editing`, `edit_prediction`.

Real predicate strings pulled from the shipped `assets/keymaps/vim.json` — copy these shapes rather than
inventing your own:

```
VimControl && !menu
vim_mode == normal
vim_mode == visual
vim_mode == insert && !(showing_code_actions || showing_completions)
(vim_mode == normal || vim_mode == helix_normal) && !menu
Editor && vim_mode == waiting && (vim_operator == ys || vim_operator == cs)
(vim_mode == insert || vim_mode == normal) && showing_signature_help && !showing_completions
Editor && mode == full && VimControl && vim_mode == normal && !menu && os == windows
VimControl && !menu || !Editor && !Terminal
Picker > Editor
GitCommit > Editor && VimControl && vim_mode == normal
ProjectPanel && not_editing
```

### Multi-key sequences and leader bindings

Keystrokes in a sequence are **separated by spaces**. There is no separate "leader" concept — a leader is
simply a prefix key in a sequence. `<space>` is written as the literal word `space`.

```json
{
  "context": "VimControl && !menu",
  "bindings": {
    "g s": "editor::GoToSymbol",
    "space f f": "file_finder::Toggle",
    "space w v": "pane::SplitRight",
    "] ]": "vim::NextSectionStart",
    "ctrl-w h": "workspace::ActivatePaneLeft",
    "ctrl-w ctrl-]": "editor::GoToDefinitionSplit",
    "z enter": ["workspace::SendKeystrokes", "z t ^"]
  }
}
```

Notes:
- Neovim's `<space>ff` / `<leader>ff` becomes `"space f f"`.
- Shifted keys use the `shift-` prefix: `<S-g>` → `"shift-g"`, `<S-w>` → `"shift-w"`.
- A prefix conflict (a binding that is a prefix of another) causes a **~1 second wait** before resolving.
- `workspace::SendKeystrokes` is the escape hatch for macro-like remaps: it replays a keystroke string, which
  is the nearest available stand-in for a vim `:map` to a key sequence.

### Action argument syntax

| Form | Example |
|---|---|
| No args (string) | `"ctrl-a": "language_selector::Toggle"` |
| Positional arg (array) | `"cmd-1": ["workspace::ActivatePane", 0]` |
| Object arg | `"ctrl-a": ["pane::DeploySearch", { "replace_enabled": true }]` |

Vim examples from the default keymap:

```json
"i": ["vim::PushObject", { "around": false }]
"shift-w": ["vim::NextWordStart", { "ignore_punctuation": true }]
"%": ["vim::Matching", { "match_quotes": true }]
"g j": ["vim::Down", { "display_lines": true }]
"shift-p": ["vim::Paste", { "preserve_clipboard": true }]
"g ctrl-a": ["vim::Increment", { "step": true }]
"shift-z shift-z": ["pane::CloseActiveItem", { "save_intent": "save_all" }]
```

### `use_key_equivalents`

A per-block boolean. On macOS with a non-QWERTY layout, `"use_key_equivalents": true` remaps the block's
bindings to match **physical key positions** rather than produced characters.

### Unbinding

Set the action to `null`:

```json
{ "context": "Editor", "bindings": { "cmd-r": null } }
```

This both disables the binding and lets the keystroke fall through to character input. This is the analogue
of `:unmap`.

### Precedence

1. Lower (more specific / deeper) context-tree nodes override higher ones.
2. Later definitions beat earlier ones — the user keymap is loaded after defaults, so user bindings win.
3. Prefix conflicts resolve after the ~1s timeout.

---

## 3. What Zed vim mode genuinely does NOT support

### Hard, categorical limits

- **No Vimscript.** No interpreter exists anywhere in Zed.
- **No Lua.** Zed has no Lua runtime for editor config.
- **No `init.vim` / `init.lua` / `.vimrc` loading of any kind.** Verified two ways: (a) the vim docs never
  mention `vimrc`, `init.vim`, `init.lua`, `vimscript`, `lua`, or `plugin manager`; (b) a `strings` scan of
  `/Applications/Zed.app/Contents/MacOS/zed` for `init\.vim|init\.lua|vimrc|vimscript` returned **zero
  matches**. There is no code path that could read such a file.
- **No vim plugin API.** Vim/Neovim plugins cannot be installed, ported, or shimmed. Features "inspired by"
  plugins are reimplemented in Rust inside the `vim` crate and shipped in core.
- **No `:map`/`:nnoremap` at runtime.** All remapping is static JSON in `keymap.json`. There is no way to
  define a binding from inside the editor session.
- **No `which-key`.** Nothing displays pending-prefix hints. The docs never mention which-key. The only
  related behaviour is the ~1s prefix-conflict timeout, which shows nothing. **UNVERIFIED:** no open upstream
  feature request was checked for this.

### Partial / different-by-design

| Feature | Status |
|---|---|
| **Macros** (`q`, `@`) | Supported, but built on **Zed's recording system**, not vim's. Docs: *"vim mode uses Zed's recording system for vim macros. So, you can capture and replay more complex actions, like autocompletion."* Behaviour will differ from vim on edge cases. |
| **Marks** | Buffer-local `'a`–`'z` plus builtins `'<`, `'>`, `'[`, `']`, `'{`, `'}`, `^`. **Global marks are not supported** (open issue [#13111](https://github.com/zed-industries/zed/issues/13111)). **No persistence to disk across restarts** — called out as an explicit gap in the [2025 vim roadmap](https://zed.dev/blog/vim-2025). No `:marks` command. |
| **Registers** | Named registers supported (landed via [#11511](https://github.com/zed-industries/zed/issues/11511)); stored as a `HashMap<char, Register>` in `VimGlobals`. **No persistence across restarts.** No `:registers` command. Known bug [#14311](https://github.com/zed-industries/zed/issues/14311) around the `+` register leaking into the system clipboard. Prefer `vim.use_system_clipboard` over register gymnastics. |
| **Jumplist** (`ctrl-o`/`ctrl-i`) | Implemented, but not vim-faithful. [#30183](https://github.com/zed-industries/zed/issues/30183): a `MIN_NAVIGATION_HISTORY_ROW_DELTA` constant means jumps under 10 rows (including some `GoToDefinition` jumps) never enter the jumplist. |
| **Changelist** (`g;` / `g,`) | Present but described in the roadmap as needing work to be vim-consistent. |
| **Folds** | Zed folding is **Tree-sitter/syntax-tree based**, not vim's manual/indent/marker fold model. `cmd-alt-{` / `cmd-alt-}` fold and unfold. Vim's `zf`/`zM`/`zR`/`foldmethod` semantics are **not** reproduced. **UNVERIFIED:** which of `za`/`zc`/`zo` are bound in 1.14.2 — the vim docs have no fold section; check `zed: open default keymap`. |
| **`:` command line** | Docs: *"We don't emulate the full power of Vim's command line yet. In particular, commands currently do not support arguments."* So `:w newname.txt`, `:e path/to/file`, `:norm ...`, and command history are all unavailable. Ranges work only for the specific forms listed below. |
| **Text objects** | Good coverage, in some ways beyond vim: `ac`/`ic` (class), `af`/`if` (function), `ia`/`aa` (argument), `at`/`it` (tag), `ai`/`aI`/`ii` (indent), plus Zed-only `AnyQuotes`, `AnyBrackets`, `MiniQuotes`, `MiniBrackets`. |
| **Visual block** | Implemented on top of Zed multi-cursors. Mostly equivalent; edge cases differ. |

### Supported `:` commands (complete documented list)

- Files/windows: `:[e]x[it][!]`, `:w[rite][!]`, `:wq[!]`, `:q[uit][!]`, `:wa[ll][!]`, `:wqa[ll][!]`,
  `:qa[ll][!]`, `:up[date]`, `:cq`, `:bd[elete][!]`, `:vs[plit]`, `:sp[lit]`, `:new`, `:vne[w]`, `:tabedit`,
  `:tabnew`, `:tabn[ext]`, `:tabp[rev]`, `:tabc[lose]`, `:ls`
- Panels: `:E[xplore]`, `:C[ollab]`, `:Ch[at]`, `:A[I]`, `:G[it]`, `:D[ebug]`, `:No[tif]`, `:fe[edback]`,
  `:cl[ist]`, `:te[rm]`, `:Ext[ensions]`
- Diagnostics: `:cn[ext]`, `:ln[ext]`, `:cp[rev]`, `:lp[rev]`, `:cc`, `:ll`
- Editing: `:j[oin]`, `:d[elete][l][p]`, `:s[ort] [i]`, `:y[ank]`, `:[range]s/foo/bar/[g]`
- Navigation: `:<number>`, `:$`, `:/foo`, `:?foo`
- Git: `:dif[fupdate]`, `:rev[ert]`
- Options: `:se[t] [no]wrap`, `:se[t] [no]nu[mber]`, `:se[t] [no]r[elative]nu[mber]`,
  `:se[t] [no]i[gnore]c[ase]`

Anything not on this list does not exist. Note the absence of `:map`, `:source`, `:let`, `:function`,
`:autocmd`, `:registers`, `:marks`, `:norm`.

### Plugin-equivalents that ARE built in

No installation needed; these ship in core:

| Neovim plugin | Zed equivalent |
|---|---|
| `vim-surround` | `ys`, `cs`, `ds` — built in |
| `vim-commentary` / `Comment.nvim` | `gc`, `gcc` — built in |
| `ReplaceWithRegister` | `gR` — built in |
| `vim-exchange` | `cx` — built in |
| `vim-indentwise` | indent-wise motions — built in |
| `nvim-treesitter-textobjects` | `af`/`if`, `ac`/`ic`, `ia`/`aa` — built in |
| `vim-sneak` | `vim::PushSneak` — **opt-in binding required** |
| `hop.nvim` / `leap.nvim` / easymotion | `vim::HelixJumpToWord` — **opt-in binding required** |
| `nvim-spider` (subword motions) | `vim::NextSubwordStart` etc. — **opt-in binding required** |
| `which-key.nvim` | **none** |
| `telescope.nvim` | not a vim binding; use `file_finder::Toggle`, `project_symbols::Toggle`, `command_palette::Toggle` |

Opt-in snippets, verbatim from the docs:

```json
{
  "context": "VimControl && !menu && vim_mode != operator",
  "bindings": {
    "w": "vim::NextSubwordStart",
    "b": "vim::PreviousSubwordStart",
    "e": "vim::NextSubwordEnd",
    "g e": "vim::PreviousSubwordEnd"
  }
}
```

```json
{
  "context": "vim_mode == normal || vim_mode == visual",
  "bindings": {
    "s": "vim::PushSneak",
    "shift-s": "vim::PushSneakBackward"
  }
}
```

```json
{
  "context": "vim_mode == normal || vim_mode == visual",
  "bindings": {
    "g w": "vim::HelixJumpToWord"
  }
}
```

---

## 4. Can you load a vimrc, or embed Neovim? — Definitively no

This is settled by explicit vendor statements plus the shape of the extension API.

**4a. No config-file compatibility.** There is no `source`, no `:source` command, and no startup file
lookup. Verified by binary string scan (zero hits for `vimrc`/`init.vim`/`init.lua`/`vimscript`) and by the
absence of any such command from the supported `:` command list. Migration from Neovim is a **manual
rewrite** of `init.lua` mappings into `keymap.json` JSON, plus a mapping of `set` options into
`settings.json`. There is no converter shipped by Zed. **UNVERIFIED:** no exhaustive search was done for a
third-party community `init.lua` → `keymap.json` converter; assume none is reliable.

**4b. Zed will not embed Neovim, by design.** From <https://zed.dev/blog/zed-decoded-vim> (2024-06-13):

> "if you were to embed Neovim into Zed, you'd end up doing exactly that: you would throw away Zed's
> foundations and replace them with Neovim."

> "the CRDTs, the Rope, the SumTree, the text models — that's Zed's DNA"

> "we'd have to do a lot of things twice: once in Zed and once in the embedded Neovim... Building it twice in
> two different codebases is... well, at least twice as hard."

The team has stated they evaluated `neovim-rs` and `libvim` and rejected both, because either approach
requires handing buffer-text ownership to Neovim or maintaining two parallel copies of buffer data —
incompatible with Zed's CRDT-based collaborative editing.

Long-standing requests, all still unimplemented:
- [zed#5513 — Neovim API support for vim users](https://github.com/zed-industries/zed/issues/5513)
- [community#186 — same request](https://github.com/zed-industries/community/issues/186)
- [zed#17500 — Embedding Neovim as an extension/plugin for Zed](https://github.com/zed-industries/zed/discussions/17500)

**4c. No extension could implement it either.** Zed extensions are **WASM modules** with a narrow
capability surface. Per <https://zed.dev/docs/extensions> and
`docs/src/extensions/developing-extensions.md`, extensions can provide exactly:

> "Languages / Debuggers / Themes / Icon Themes / Snippets / MCP Servers"

There is **no** extension capability for keybindings, keymaps, custom editor actions, keystroke
interception, buffer mutation, or rendering. The docs additionally state extensions "must in no way attempt
to read nor modify the environment outside of the environment designated to them by Zed." A
`vscode-neovim`-style integration is architecturally impossible in an extension: VS Code's JS extension host
exposes deep document/text-editing control, Zed's WASM extension host does not.

**Bottom line:** if you need real Neovim semantics plus real Neovim plugins, Zed cannot provide it now or on
any announced roadmap. Zed's own vim mode is the only path, and migration is a rewrite.

---

## 5. Action namespaces and how to discover the full action list

### Namespaces seen in the shipped vim keymap

`vim::`, `editor::`, `workspace::`, `pane::`, `menu::`, `buffer_search::`, `command_palette::`,
`file_finder::`, `tab_switcher::`, `outline::`, `outline_panel::`, `project_panel::`, `project_symbols::`,
`git::`, `git_panel::`, `git_graph::`, `debugger::`, `settings_editor::`, `markdown::`, `notebook::`,
`assistant::`, `agents_sidebar::`, `multi_workspace::`, `skill_creator::`, `zed::`, `language_selector::`.

The namespace always matches the Rust crate that owns the action, and appears in JSON as
`"namespace::ActionName"`.

### Highest-value actions for Neovim-style remapping

- Motion/mode: `vim::NextWordStart`, `vim::PreviousWordEnd`, `vim::EndOfDocument`, `vim::PushObject`,
  `vim::PushFindForward`, `vim::PushSneak`, `vim::HelixJumpToWord`, `vim::Paste`, `vim::Increment`,
  `vim::Number`, `vim::Matching`, `vim::WrappingLeft`, `vim::WrappingRight`
- LSP (replaces most of your Neovim LSP mappings): `editor::GoToDefinition`, `editor::GoToDefinitionSplit`,
  `editor::GoToTypeDefinition`, `editor::FindAllReferences`, `editor::Rename`, `editor::ToggleCodeActions`,
  `editor::Hover`, `editor::GoToDiagnostic`, `editor::OpenExcerpts`
- Pickers (replaces Telescope): `file_finder::Toggle`, `project_symbols::Toggle`, `outline::Toggle`,
  `command_palette::Toggle`, `tab_switcher::Toggle`, `pane::DeploySearch`
- Windows/panes: `pane::SplitRight`, `pane::SplitDown`, `workspace::ActivatePaneLeft`/`Right`/`Up`/`Down`,
  `pane::CloseActiveItem`, `pane::ActivateItem`
- Escape hatch: `workspace::SendKeystrokes` (replay a keystroke string)

### Where the user finds the complete list at runtime

1. **Keymap editor UI** — `cmd-k cmd-s`, action `zed: open keymap`. Has autocomplete over all actions and a
   shortcut recorder. Known limitation: searching by *keystroke* rather than action name does not work
   ([#48914](https://github.com/zed-industries/zed/issues/48914)).
2. **`zed: open default keymap`** from the command palette (`cmd-shift-p`) — read-only JSON of every
   built-in binding with its action name. This is the most reliable full inventory, and the way to confirm
   anything marked UNVERIFIED in this document.
3. **Command palette** (`cmd-shift-p`) — searchable list of actions with their current bindings.
4. **`dev: open key context view`** — shows the live context stack at the cursor. Essential when a context
   predicate is not matching.
5. **`zed: open default settings`** — full annotated defaults, for confirming the `vim` block schema.

---

## 6. Version-specific caveats (1.14.2, 2026-08-05)

- **Local install is the current stable.** 1.14.2, released 2026-08-05.
- **Zed reached 1.0.0 on 2026-04-29.** Any guide or blog post using `0.x` version numbers predates that and
  may be stale — notably the 2024 "Zed Decoded: Vim" and Jan-2025 "Vim Roadmap" posts cited here. Their
  architectural claims (no embedded Neovim) still hold; their feature-gap lists are partly outdated.
- **Breaking change in 1.14.2: the default `base_keymap` switched from VSCode to Zed.** Users without an
  explicit `"base_keymap"` in settings get changed bindings — the inline assistant moved to `cmd-i` (macOS) /
  `ctrl-i`, and `f5` now starts the debugger. Your `settings.json` does **not** set `base_keymap`, so you are
  on the new Zed default. If bindings feel unfamiliar versus older docs, this is why. Pin it explicitly if
  you want stability:
  ```json
  { "base_keymap": "Zed" }
  ```
- Other 1.14.x vim/helix fixes: auto-indent when inserting a line above in vim mode; cursor placement after
  leaving insert mode via a multi-key binding; visual/helix-select behaviour with trailing newlines in the
  selection; git panel bindings intercepting input in vim mode; tab/shift-tab focus return from the git
  commit editor in normal mode; IME interference with helix jump-to-word labels.
- **`use_multiline_find` is deprecated** (see §1). If you copy an older config that sets it, it will be
  silently inert.
- Helix mode is a first-class, actively developed sibling of vim mode in this release line. Many recent vim
  crate changes are helix-related; do not assume a changelog entry mentioning "helix" affects your setup.

---

## 7. Practical migration summary for a Neovim user

| Neovim concept | Zed equivalent |
|---|---|
| `init.lua` / `.vimrc` | **Nothing.** Manual rewrite into `settings.json` + `keymap.json` |
| `set <option>` | `settings.json` (global) or the `vim` block (vim-specific) |
| `nnoremap <leader>ff ...` | `keymap.json` block with `"context": "vim_mode == normal"`, binding `"space f f"` |
| `:unmap` | `"key": null` |
| lazy.nvim / packer | **Nothing.** Extensions cover languages/themes/debuggers/MCP only |
| which-key | **Nothing** |
| Telescope | `file_finder::Toggle`, `project_symbols::Toggle`, `command_palette::Toggle` |
| LSP config | Automatic; language extensions + `lsp` settings block |
| Treesitter textobjects | Built in |
| surround / commentary / exchange | Built in |
| sneak / leap / spider | Built in but **opt-in binding** |
| Autocmds, custom Lua functions | **Nothing.** Hard limit |
| Persistent marks/registers (shada) | **Not supported** |

The realistic ceiling: keybindings and options port over well; anything that was *logic* in your `init.lua`
does not port at all.
