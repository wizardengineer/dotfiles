---@brief
---
--- https://github.com/python-lsp/python-lsp-server
---
--- python-lsp-server (pylsp) is a Python Language Server, the server can be installed via pip
---
--- ```sh
--- pip install python-lsp-server
--- ```
---
--- For additional features, install optional dependencies:
---
--- ```sh
--- pip install python-lsp-server[all]
--- ```
---
--- Settings to the server can be passed through the `settings` option or through
--- a local configuration file. For more information
--- see the pylsp [documentation](https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md).

---@type vim.lsp.Config
return {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
  root_markers = { 
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git'
  },
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = true },
        pyflakes = { enabled = true },
        pylint = { enabled = false },
        autopep8 = { enabled = true },
        yapf = { enabled = false },
        black = { enabled = false },
      }
    }
  },
}
