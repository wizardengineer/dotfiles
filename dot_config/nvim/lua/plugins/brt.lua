return {
  {
    "badumbatish/brt.nvim",
    -- Use local dev version with fixes for glob, leader key, and SSH
    -- dir = "~/GitDownloads/brt.nvim",
    -- dev = true,
    dependencies = {
      "ibhagwan/fzf-lua", -- add fzf-lua as a dependency
      "kkharji/sqlite.lua"
    },
    -- @t
    config = function()
      local brt = require("brt")
      brt.setup()
    end
  }
}
