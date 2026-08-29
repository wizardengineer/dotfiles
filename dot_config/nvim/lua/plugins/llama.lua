return {
  'ggml-org/llama.vim',
  event = 'InsertEnter',
  init = function()
    vim.g.llama_config = {
      show_info = false,
      auto_fim = true,
      endpoint_fim = 'http://127.0.0.1:8012/infill',
      n_prefix = 256,
      n_suffix = 64,
      -- Latency vs length tradeoff: shorter, faster suggestions feel more
      -- Cursor-like than long ones that arrive late (defaults: 128 / 1000ms).
      n_predict = 64,
      t_max_predict_ms = 600,
      ring_n_chunks = 16,
      ring_chunk_size = 64,
      ring_scope = 1024,

      -- FIM keys. llama.vim creates the accept maps BUFFER-LOCALLY and only
      -- while a hint is displayed (s:fim_render), then `iunmap <buffer>`s them
      -- in llama#fim_hide(). That means:
      --   * outside of a visible hint these keys keep their normal behavior;
      --   * they must NEVER collide with blink.cmp's buffer-local maps
      --     (preset 'default': <Tab>/<S-Tab>/<C-y>/<C-e>/<C-p>/<C-n>/<C-b>/
      --     <C-f>/<C-k>/<C-space>), because llama's iunmap-on-hide would
      --     delete blink's map and blink never re-applies (it skips buffers
      --     that already contain any 'blink.cmp: '-desc mapping).
      -- <Tab> "accept" is therefore NOT configured here — see the global
      -- expr map in config() below, which routes through blink's fallback.
      keymap_fim_trigger = '<C-F>', -- llama re-maps <C-F> buffer-locally on
      -- InsertEnter after blink, so blink's scroll_documentation_down is
      -- unreachable — acceptable with documentation.auto_show = false.
      keymap_fim_accept_full = '<C-l>', -- backup accept (Tab is primary)
      keymap_fim_accept_line = '<C-j>', -- native i_CTRL-J (newline) is
      -- redundant with <CR>; only shadowed while a hint is visible.
      keymap_fim_accept_word = '<C-t>', -- native i_CTRL-T (indent line) is
      -- only shadowed while a hint is visible; blink does not map it.

      -- This first pass is FIM-only.
      keymap_inst_trigger = '',
      keymap_inst_rerun = '',
      keymap_inst_continue = '',
      keymap_inst_accept = '',
      keymap_inst_cancel = '',
    }
  end,
  config = function()
    -- Hide llama's ghost text when blink.cmp's completion menu opens so the
    -- two suggestions never overlap (blink emits User BlinkCmpShow/BlinkCmpHide).
    -- After the menu closes, auto_fim re-triggers on CursorMovedI (s:on_move),
    -- so the ghost text comes back on its own as you keep typing.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'BlinkCmpShow',
      group = vim.api.nvim_create_augroup('llama_blink_cmp', { clear = true }),
      callback = function()
        vim.fn['llama#fim_hide']()
      end,
    })

    -- Cursor-style <Tab>: accept the whole llama suggestion when ghost text
    -- is visible, otherwise behave exactly as before.
    --
    -- Why a GLOBAL map works: blink.cmp maps <Tab> buffer-locally on
    -- InsertEnter (keymap/apply.lua: nvim_buf_set_keymap), so its map wins in
    -- insert mode. Its 'default' preset runs { 'snippet_forward', 'fallback' }
    -- and 'fallback' resolves the first non-blink GLOBAL <Tab> map at press
    -- time (keymap/fallback.lua: fallback.wrap), invoking our expr callback
    -- and feeding its return value. In buffers where blink is disabled, this
    -- map fires directly. Either way: hint visible -> accept; else literal
    -- <Tab>. Detection uses the public llama#is_fim_hint_shown() (llama.vim
    -- PR #85) — no fragile extmark/maparg proxies needed.
    vim.keymap.set('i', '<Tab>', function()
      local ok, shown = pcall(vim.fn['llama#is_fim_hint_shown'])
      if ok and (shown == true or shown == 1) then
        -- Same RHS llama.vim binds for its own accept keys (s:fim_render).
        return [[<C-O>:call llama#fim_accept('full')<CR>]]
      end
      return '<Tab>'
    end, {
      expr = true,
      silent = true,
      desc = 'llama.vim: accept FIM suggestion (else literal <Tab>)',
    })
  end,
}
