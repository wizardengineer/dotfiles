-- Advanced DAP configuration for LLVM/CMake projects
local M = {}

-- Helper function to find CMake build directory
M.find_cmake_build_dir = function()
  local possible_dirs = {
    vim.fn.getcwd() .. '/build',
    vim.fn.getcwd() .. '/build/Debug',
    vim.fn.getcwd() .. '/build/Release',
    vim.fn.getcwd() .. '/cmake-build-debug',
    vim.fn.getcwd() .. '/cmake-build-release',
  }
  
  for _, dir in ipairs(possible_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      return dir
    end
  end
  
  return vim.fn.getcwd() .. '/build'
end

-- Helper function to parse CMakePresets.json
M.get_cmake_presets = function()
  local presets_file = vim.fn.getcwd() .. '/CMakePresets.json'
  if vim.fn.filereadable(presets_file) == 0 then
    return nil
  end
  
  local file = io.open(presets_file, 'r')
  if not file then
    return nil
  end
  
  local content = file:read('*all')
  file:close()
  
  local ok, presets = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end
  
  return presets
end

-- Get build directory from CMakePresets.json
M.get_preset_build_dir = function(preset_name)
  local presets = M.get_cmake_presets()
  if not presets or not presets.configurePresets then
    return nil
  end
  
  for _, preset in ipairs(presets.configurePresets) do
    if preset.name == preset_name then
      local build_dir = preset.binaryDir or ('${sourceDir}/build/' .. preset.name)
      -- Replace ${sourceDir} with current working directory
      build_dir = build_dir:gsub('${sourceDir}', vim.fn.getcwd())
      return build_dir
    end
  end
  
  return nil
end

-- Select CMake preset interactively
M.select_cmake_preset = function()
  local presets = M.get_cmake_presets()
  if not presets or not presets.configurePresets then
    vim.notify('No CMakePresets.json found or no configure presets defined', vim.log.levels.WARN)
    return nil
  end
  
  local preset_names = {}
  for _, preset in ipairs(presets.configurePresets) do
    table.insert(preset_names, preset.name)
  end
  
  if #preset_names == 0 then
    vim.notify('No configure presets found in CMakePresets.json', vim.log.levels.WARN)
    return nil
  end
  
  -- Use vim.ui.select for preset selection
  local selected_preset = nil
  vim.ui.select(preset_names, {
    prompt = 'Select CMake Preset:',
  }, function(choice)
    selected_preset = choice
  end)
  
  return selected_preset
end

-- Find executables in build directory
M.find_executables = function(build_dir)
  local executables = {}
  local handle = io.popen('find "' .. build_dir .. '" -type f -perm +111 2>/dev/null')
  if handle then
    for file in handle:lines() do
      -- Filter out libraries and only include actual executables
      if not file:match('%.so$') and not file:match('%.dylib$') and not file:match('%.a$') then
        table.insert(executables, file)
      end
    end
    handle:close()
  end
  return executables
end

-- Select executable interactively
M.select_executable = function()
  local build_dir = M.find_cmake_build_dir()
  local executables = M.find_executables(build_dir)
  
  if #executables == 0 then
    return vim.fn.input('Path to executable: ', build_dir .. '/', 'file')
  end
  
  local selected = nil
  vim.ui.select(executables, {
    prompt = 'Select executable:',
    format_item = function(item)
      return vim.fn.fnamemodify(item, ':t') .. ' (' .. vim.fn.fnamemodify(item, ':h') .. ')'
    end,
  }, function(choice)
    selected = choice
  end)
  
  return selected or vim.fn.input('Path to executable: ', build_dir .. '/', 'file')
end

-- Setup additional DAP configurations
M.setup = function()
  local dap = require('dap')
  
  -- Add LLVM-specific configuration
  table.insert(dap.configurations.cpp, {
    name = "Launch LLVM tool",
    type = "codelldb",
    request = "launch",
    program = M.select_executable,
    args = function()
      local args_string = vim.fn.input('Arguments (e.g., input.ll -o output.s): ')
      return vim.split(args_string, " +")
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    runInTerminal = false,
    env = function()
      -- You can add LLVM-specific environment variables here
      return {
        LLVM_PROFILE_FILE = "default.profraw",
      }
    end,
  })
  
  -- Add configuration for CMake preset-based debugging
  table.insert(dap.configurations.cpp, {
    name = "Launch with CMake Preset",
    type = "codelldb",
    request = "launch",
    program = function()
      local preset = M.select_cmake_preset()
      if preset then
        local build_dir = M.get_preset_build_dir(preset)
        if build_dir then
          return vim.fn.input('Path to executable: ', build_dir .. '/', 'file')
        end
      end
      return M.select_executable()
    end,
    args = function()
      local args_string = vim.fn.input('Arguments: ')
      return vim.split(args_string, " +")
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  })
end

return M

