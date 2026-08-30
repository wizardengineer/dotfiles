---@brief
---
--- https://rust-analyzer.github.io/
---
--- rust-analyzer is the official LSP server for Rust.
--- Install via rustup: `rustup component add rust-analyzer`
--- Or standalone: https://rust-analyzer.github.io/manual.html#installation

return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = {
        'Cargo.toml',
        'rust-project.json',
        '.git',
    },
    capabilities = {
        experimental = {
            serverStatusNotification = true,
        },
    },
    settings = {
        ['rust-analyzer'] = {
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
            },
            -- `checkOnSave` is a bool in current rust-analyzer; the command
            -- moved to `check.command`. The old nested form is rejected at
            -- startup ("invalid type: map, expected a boolean") and clippy
            -- then never runs.
            checkOnSave = true,
            check = {
                command = 'clippy',
            },
            procMacro = {
                enable = true,
            },
            inlayHints = {
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true },
                closureReturnTypeHints = { enable = 'always' },
                lifetimeElisionHints = { enable = 'skip_trivial' },
                parameterHints = { enable = true },
                typeHints = { enable = true },
            },
        },
    },
}
