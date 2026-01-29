local function map(mode, key, action)
	vim.api.nvim_set_keymap(mode, key, action, {noremap = true, silent = true})
end

local function unmap(mode, key)
    vim.api.nvim_set_keymap(mode, key, '<Nop>', {noremap = true, silent = true})
end

vim.keymap.set('n', '<C-l>', ':bnext<CR>', {silent = true})
vim.keymap.set('n', '<C-h>', ':bprevious<CR>', {silent = true})

vim.cmd('cd /home/fe/Documents/Programming/')

vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4

vim.o.number = true
vim.o.relativenumber = true

-- Colemak bindings (failed to configure)
--[[
for _, k in pairs({'h', 'j', 'k', 'l', 'e', 'y', 'd'}) do
	unmap('n', k)
	unmap('v', k)
end

unmap('n', 'i')
unmap('n', 'o')
unmap('n', 'I')
unmap('n', 'O')

unmap('n', 'gg')
unmap('n', 'G')

unmap('n', 'dd')
unmap('n', 's')

unmap('n', 'u')

map('n', 'n', 'h')
map('n', 'e', 'j')
map('n', 'i', 'k')
map('n', 'o', 'l')
map('n', 'f', 'e')

map('v', 'n', 'h')
map('v', 'e', 'j')
map('v', 'i', 'k')
map('v', 'o', 'l')
map('v', 'f', 'e')

map('n', 'u', 'i')
map('n', 'y', 'o')
map('n', 'U', 'I')
map('n', 'Y', 'O')

map('n', 'dd', 'gg')
map('n', 'D', 'G')

map('n', 's', 'd')
map('n', 'ss', 'dd')
map('n', 'r', 's')

map('n', 'l', 'u')
]]

-- ~/.config/lvim/config.lua

-- Everthing under this is written by AI, I don't understand a thing here lol

lvim.builtin.nvimtree.setup = {
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
    update_cwd = false
  },
  view = {
    adaptive_size = false,
    side = "left",
    width = 30,
  },
  renderer = {
    root_folder_modifier = ":t",
    icons = {
      show = {
        folder = true,
        file = true,
        git = true,
      }
    }
  },
  filters = {
    dotfiles = false,
    custom = {}
  }
}

vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function(data)
    local is_directory = vim.fn.isdirectory(data.file) == 1
    
    if is_directory then
      vim.cmd.cd(data.file)
      vim.defer_fn(function()
        require("nvim-tree.api").tree.open()
      end, 50)
    elseif data.file ~= "" and vim.fn.argc() > 0 then
      local file_dir = vim.fn.fnamemodify(data.file, ":h")
      if file_dir ~= "." and vim.fn.isdirectory(file_dir) == 1 then
        vim.cmd.cd(file_dir)
      end
      vim.defer_fn(function()
        require("nvim-tree.api").tree.open()
        require("nvim-tree.api").tree.find_file({ open = true, focus = true })
      end, 100)
    end
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
      local file_dir = vim.fn.fnamemodify(buf_name, ":h")
      if file_dir ~= "." and vim.fn.isdirectory(file_dir) == 1 then
        -- Проверяем, что это не специальный буфер
        local buftype = vim.bo.buftype
        if buftype == "" then
          vim.cmd("silent lcd " .. vim.fn.fnameescape(file_dir))
        end
      end
    end
  end,
})

local function toggle_nvim_tree()
  local nvim_tree = require("nvim-tree.api")
  if nvim_tree.tree.is_visible() then
    nvim_tree.tree.close()
  else
    -- Перед открытием обновляем корневую директорию на текущую CWD
    nvim_tree.tree.open()
    -- Фокусируемся на текущем файле если он есть
    local current_buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(current_buf)
    if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
      nvim_tree.tree.find_file({ open = true, focus = false })
    end
  end
end

lvim.keys.normal_mode["<leader>e"] = "<cmd>lua toggle_nvim_tree()<CR>"
lvim.keys.normal_mode["<leader>E"] = ":NvimTreeFocus<CR>"
lvim.keys.normal_mode["<leader>ff"] = ":NvimTreeFindFile<CR>"

vim.api.nvim_create_user_command("CDCurrent", function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name ~= "" then
    local file_dir = vim.fn.fnamemodify(buf_name, ":h")
    if file_dir ~= "." and vim.fn.isdirectory(file_dir) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(file_dir))
      print("Changed CWD to: " .. file_dir)
    end
  end
end, {})
