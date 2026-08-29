# Prior art: making Zed behave like an existing Neovim setup

Research date: 2026-08-06. Zed's vim mode moves fast (monthly releases); anything sourced
from before ~mid-2025 is flagged stale below.

## 1. Published keymap.json ports of LazyVim / kickstart.nvim

- **Yeshwanthyk's "zed lazyvim keymaps" gist**
  https://gist.github.com/Yeshwanthyk/5c723b518a385edbf80c19d46e0d5fed
  A single `keymap.json` mapping LazyVim's leader-key bindings onto Zed actions. Comments
  report it "works perfectly" and "really makes zed so much more nicer." Scope: leader-key
  file nav, buffer/window management. Not a full LazyVim port (no plugin-equivalent
  behavior, just keybindings to existing Zed actions).

- **oca159's "zed keymap.json with same lazyvim keymaps" gist**
  https://gist.github.com/oca159/0b480ed6555056418905b6e59af33674
  Similar scope, praised in comments for better use of Zed's keybinding *contexts* than
  competing gists. Comment thread documents a real conflict: binding `shift-g z z` to
  center-on-scroll broke the `dG` (delete-to-end-of-file) operator — a good illustration of
  how naive keymap ports can silently break unrelated vim operators in Zed's binding engine.
  Thread also covers wiring `lazygit` in via `tasks.json`.

- **makyinmars/zed-config** — https://github.com/makyinmars/zed-config
  A full config repo (not just keymap.json), explicitly aimed at LazyVim muscle-memory
  parity: `]d`/`[d` diagnostics nav, `<leader>w` window prefix, `jk`/`kj` insert-mode escape,
  `<leader>z` folding prefix. Most complete LazyVim-parity repo found; still keybinding-only,
  no plugin behavior ported.

- **jellydn/zed-101-setup** — https://github.com/jellydn/zed-101-setup
  Broader "setup guide" repo (not LazyVim-specific) with a ready-made keymap.json covering
  git actions, inlay hints, soft-wrap, zen mode, markdown preview toggles bound under vim
  contexts.

- **zed-industries/zed discussion #8485** (lazygit integration via keymap.json + tasks.json)
  https://github.com/zed-industries/zed/discussions/8485 — the canonical example people copy
  for `<leader>gg` → lazygit, a common LazyVim habit.

- Baseline reference: Zed's own shipped default vim keymap —
  `assets/keymaps/vim.json` in zed-industries/zed —
  https://github.com/zed-industries/zed/blob/main/assets/keymaps/vim.json

**Assessment:** All of these are keybinding remaps onto Zed's *existing* action set, not
behavioral ports. None reproduce LazyVim/kickstart plugin behavior (e.g., real
which-key popups, Telescope pickers, actual `gcc`/`gc` comment operators with count/motion
support — see §3). They get you familiar keystrokes for actions Zed already has; they do
not add capabilities Zed lacks. I found no kickstart.nvim-specific port as thorough as the
LazyVim ones — kickstart's minimalism means fewer people bother productizing a port.

## 2. Bridging to a real Neovim process (vscode-neovim / IdeaVim model)

**Does not exist, and the Zed team has explicitly ruled it out.** Confirmed from two
official sources:

- Zed blog, "Why not just embed Neovim?" — https://zed.dev/blog/zed-decoded-vim
- GitHub issue response, zed-industries/community #186 ("Neovim API support for vim users")
  — https://github.com/zed-industries/community/issues/186

Reasoning given: embedding/bridging to Neovim (via `neovim-rs`, RPC/`libvim`, etc.) would
require either (a) letting Neovim own buffer text, which conflicts with Zed's CRDT-based
text data structures that underpin its performance and real-time collaboration, or (b)
maintaining two parallel copies of buffer state, which the team judged unworkable and bad
for building Zed's own extension ecosystem. They also note Zed's keybinding system
(command palette integration, context-scoped bindings) is architecturally different from
Vim's, so a straight bridge wouldn't compose well with the rest of the editor.

Community discussion asking for exactly the vscode-neovim/IdeaVim model:
- zed-industries/zed discussion #17500, "Embedding Neovim as an extension/plugin for Zed"
  — https://github.com/zed-industries/zed/discussions/17500

Instead, Zed built a from-scratch native vim emulation layer, which they test for
edge-case parity by running **headless Neovim side-by-side** as a test oracle during
development (not at runtime for users) — mentioned in the Vim Roadmap 2025 post (§5).

**Extension API angle:** Zed's extension API (WASM-based) does not currently expose the
level of buffer/keystroke interception needed to implement a vscode-neovim-style bridge
even if someone wanted to build one as a third party. No evidence of anyone attempting it.

**Assessment:** this approach is a dead end for Zed today, by explicit design decision, not
merely unimplemented.

## 3. Top complaints porting from Neovim (ranked by frequency/persistence)

From zed-industries/zed issues/discussions and HN threads:

1. **No macro support was a long-standing blocker** — cited bluntly on HN: "it doesn't have
   a real vim mode if there is no macro support, plain and simple"
   (https://news.ycombinator.com/item?id=39121996, Feb 2024 — **stale, check current state**;
   macros have since shipped per later roadmap posts, but this was the #1 complaint
   historically and shaped Zed's priorities).
2. **Comment operator (`gcc`/`gc`) gaps** — most-discussed vim-labeled issues:
   - #6964 "Emulate vim-commentary" — https://github.com/zed-industries/zed/issues/6964
   - #8152 "Vim key mapping for editor::ToggleComments does not work" —
     https://github.com/zed-industries/zed/issues/8152
   - #14337 "vim comments to accept {count} and {motion} params" (e.g. `gc2j`, `gcgg`) —
     https://github.com/zed-industries/zed/issues/14337
3. **Search-in-vim-mode bugs**, e.g. backward search skipping the match under cursor when
   wrapping — #22506 — https://github.com/zed-industries/zed/issues/22506
4. **No plugin ecosystem** — the most-repeated *structural* complaint, distinct from any
   single bug: "Zed lacks an ecosystem for plugins, which is a huge drawback for me" (HN,
   Sept 2025) — https://news.ycombinator.com/item?id=45117966. Community has hand-ported
   individual plugins (vim-surround, sneak, tree-sitter text objects — per Vim Roadmap 2025)
   but there's no LSP-for-editor-extensions equivalent to Neovim's Lua plugin ecosystem.
5. **Config format downgrade** — Zed uses JSON, no programmable/dynamic config, called "a
   strict downgrade" from Neovim's Lua by one HN commenter reflecting on the switch
   (https://news.ycombinator.com/item?id=42817277 thread, on the Siddhant Goel post below).
6. **Regex dialect differences** in `:s` substitute (`$1` capture groups instead of `\1`,
   globally-scoped by default) — documented as a known divergence in Zed's own vim docs
   (https://zed.dev/docs/vim), not just a complaint.
7. **Muscle-memory key collisions** with editor-level shortcuts: `ctrl-f` (buffer search,
   not page-down), `ctrl-c` (copy, not return-to-normal), `ctrl-a` (select-all, not
   increment), `ctrl-v` (paste, not visual-block) — all documented as things you must
   manually rebind.
8. **Dock/pane navigation gap** — `ctrl-w hjkl` moves between editor panes by default but
   not into terminal/project/agent docks without adding a custom "Dock" context binding
   (noted in Zed's own vim docs).

Meta-tracking issue for overall top-liked issues (not vim-specific but vim items appear):
zed-industries/community #52 — https://github.com/zed-industries/community/issues/52.

## 4. People who bailed back to Neovim

I could **not find a single clear, sourced account** of someone trying Zed's vim mode and
explicitly reverting to Neovim full-time. This is worth flagging honestly rather than
papering over: search results skew heavily toward "I switched and stayed" posts (survivorship
bias — people who bounce off quickly are less likely to blog about it). The closest signals
of dissatisfaction that stop short of a full reversion:

- Siddhant Goel, "Trying out Zed after more than a decade of Vim/Neovim" —
  https://sgoel.dev/posts/trying-out-zed-after-more-than-a-decade-of-vim-neovim/ — opens
  admitting uncertainty whether he'd "run back to my trusty Neovim," but the post concludes
  positively; no follow-up bail-out post found.
- HN commenters (§3, items 1 and 4) express strong enough dissatisfaction (no macros
  historically, no plugin ecosystem) that they read as reasons *not to switch* rather than
  reasons people switched and reverted — i.e., the friction shows up as "I won't move," not
  "I moved and came back."
- No GitHub discussion, Reddit thread, or blog post surfaced where someone documents actually
  reverting. This may simply mean such posts don't get written/indexed well, not that it
  doesn't happen — treat the "success story" skew in my results as a real search
  limitation, not evidence that reversion is rare.

**Positive counterpoint sources** (for contrast, since they dominate the search results):
- Steve Simkins, "Leaving Neovim for Zed" — https://stevedylan.dev/posts/leaving-neovim-for-zed/
  — praises Zed's keybinding-context system specifically, notes the team "don't plan to port
  absolutely everything" but has covered "the important stuff."
- Zed's own blog quotes a 15-year Vim user who says they couldn't have switched without vim
  mode existing — obviously not neutral, treat as marketing.

## 5. Official migration guidance from the Zed team

**There is no dedicated migration guide.** Checked directly:

- https://zed.dev/docs/vim — covers vim mode configuration, the binding-context template
  (`Editor && VimControl && !VimWaiting && !menu`), `workspace::SendKeystrokes` as the
  closest equivalent to `nmap`/`vmap` for custom remaps, and plugin-behavior ports (mini.ai
  bracket-selection, vim-exchange, ReplaceWithRegister, indent-wise navigation). It
  explicitly states Zed "does not replicate Vim one-to-one" by design philosophy, not as a
  gap to be fixed. No Neovim-specific migration section; the doc assumes you're learning
  Zed's vim mode on its own terms.
- https://zed.dev/blog/vim-2025 ("Vim Roadmap 2025") — closest thing to a north star: three
  2025 priorities were (1) non-editor UX — ex-mode completion, `:norm`, `:registers`,
  `:marks`; (2) **conformance** — closing edge-case gaps found via headless-Neovim
  side-by-side testing (named remaining gaps: `zL`/`zH` motions, `d]}` edge cases); (3)
  better multi-cursor integration, explicitly drawing on Kakoune/Helix/vim-plugin ideas
  rather than Neovim itself. No stated intent to support the Neovim plugin ecosystem or Lua
  config. Discussed on HN: https://news.ycombinator.com/item?id=42871820.
- https://zed.dev/compare/neovim — Zed's own comparison page, frames vim mode as "familiar"
  but concedes Neovim retains "full Vim compatibility plus Lua extensibility that Zed's
  emulation may lack in some advanced areas" — the closest thing to an official admission of
  scope limits.

**Bottom line on official guidance:** Zed's position is "learn our vim mode, file issues for
gaps" — not "here's how to port your dotfiles." The keymap.json gists in §1 are entirely
community-driven; Zed does not endorse or maintain any of them.

---

Written by Research Engineer subagent, sourced 2026-08-06. All URLs above were retrieved via
live web search/fetch this session.
