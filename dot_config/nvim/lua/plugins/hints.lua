return {
    {
        "chrisgrieser/nvim-lsp-endhints",
        event = "LspAttach",
        opts = {
            icons = {
                type = "󰜁 ",
                parameter = "󰏪 ",
                offspec = " ", -- hint kind not defined in official LSP spec
                unknown = " ", -- hint kind is nil
            },
            label = {
                truncateAtChars = 50,
                padding = 1,
                marginLeft = 0,
                sameKindSeparator = ", ",
            },
            extmark = {
                priority = 50,
            },
            autoEnableHints = true,
        }, -- required, even if emptyj
    }
}
