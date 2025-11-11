# Debugging with my Neovim Setup

## Keymaps
- Space-5 : start/continue debugging session
- Space-6 : terminate the debugging session
- Space-7 : step over
- Space-8 : step in
- Space-9 : step out



- Space-b : toggle breakpoints
- Space-B : toggle breakpoints

- Space-lp : toggle logging breakpoints


## Debuggers

### C/C++/Rust

Please install lldb-vscode and configure the absolute path of the lldb debugger adapter in nvim_dap.lua. You can type *Space-ff* to activate telescope to find the file quickly

### Python

You are better off install the Python debugger adapter in a seperate python virtual environment and provide the absolute path in nvim_dap.lua. 
