table.insert(vim.opt.rtp, vim.env.HOME .. "/.fzf")

vim.g.fzf_commands_expect = "enter"
vim.g.fzf_layout = {
  window = {
    width = 1,
    height = 0.5,
    yoffset = 1,
    highlight = "Comment",
    border = "none",
  },
}

vim.g.fzf_buffers_jump = 1 -- [Buffers] Jump to the existing window if possible
vim.g.fzf_preview_window = { "right:50%:+{2}-/2,nohidden", "?" }
vim.g.fzf_commits_log_options = table.concat({
  [[ --graph --color=always                                    ]],
  [[ --format="%C(yellow)%h%C(red)%d%C(reset)                  ]],
  [[ - %C(bold green)(%ar)%C(reset) %s %C(blue)<%an>%C(reset)" ]],
}, " ")

-- stylua: ignore start
local fzf_fix_group = vim.api.nvim_create_augroup("FZF_FIX", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = fzf_fix_group,
  pattern = "fzf",
  callback = function()
    vim.keymap.set( "t", "<esc>", "<C-c>",
      { buffer = true, desc = "escape fzf with escape" }
    )
  end,
})

local defaults = {
  fzf_history_dir = vim.env.HOME .. "/.local/share/fzf-history",
  frontend = "fzf.vim",                -- default frontend. (fzf-lua|fzf.vim)

  mappings = {
    commands = "<leader>:",            -- show commands
    history  = "<leader>fh",           -- show history
    files    = "<C-p>",                -- show files in cwd
    files_location = {                 -- show files in home or given location
      loc = vim.env.HOME,
      key = "<M-p>",                    -- Alt+p
    },
    buffers            = "<C-b>",      -- show buffers
    delete_buffers     = "<M-b>",      -- delete buffers
    git_files          = "<leader>gf", -- show files in git (git ls-files)
    buffer_lines       = "<C-_>",      -- CTRL-/ grep lines of current buffer
    all_buffer_lines   = "<M-/>",      -- search in lines of all open buffers
    complete_dict      = "<c-x><c-k>", -- (Inser mode) dict completion
    complete_path      = "<c-x><c-f>", -- (Insert mode) path completion
    complete_line      = "<c-x><c-l>", -- (Insert mode) line completion
    spell_suggestion   = "z=",         -- show spell suggestions
    in_files           = "<leader>ff", -- find in files
    in_files_force     = "<leader>fa", -- find in files (ignore .gitignore)
    incremental_search = "<leader>fi", -- incremental search with rg
    current_word       = "<leader>rg", -- search for current word
    current_word_force = "<leader>ra", -- search for current word (ignore .gitignore)
    marks              = "<leader>mm", -- show marks
    tags               = "<leader>@",  -- show tags
    fzf_builtin        = "<leader>t"   -- invokes fzf-lua builtin popup
  },

  commands = {
    git_grep     = "GGrep",
    git_tree     = "GTree",
    buffer_lines = "BLines",
    reload       = "Reload",
    config       = "Config",
    todo         = "Todo",
    marks_delete = "MarksDelete",
    marks        = "Marks",
    args_add     = "ArgsAdd",
    args_delete  = "ArgsDelete",
    history      = "History",
    checkout     = "Checkout",
    work_tree    = "WorkTree",         -- git work-tree
    git_status   = "GitStatus",        -- only with fzf-lua frontend
    jumps        = "Jumps",
    autocmds     = "Autocmds",
    changes      = "Changes",
    registers    = "Registers",
  },
}
-- stylua: ignore end

local function config(opts)
  vim.validate({
    mappings = { opts.mappings, { "table", "boolean", "nil" }, false },
    commands = { opts.commands, { "table", "boolean", "nil" }, false },
    fzf_history_dir = { opts.fzf_history_dir, { "string", "boolean", "nil" }, false },
    frontend = { opts.frontend, { "string" }, false },
  })

  if opts.frontend == "fzf-lua" then
    opts.mappings.frontend = true
    opts.commands.frontend = true
    require("fzfmania.fzf_lua").config(opts.commands, opts.mappings)
  else
    opts.mappings.frontend = false
    opts.commands.frontend = false
  end

  if opts.mappings then
    require("fzfmania.mappings").config(opts.mappings)
  end
  if opts.commands then
    require("fzfmania.commands").config(opts.commands)
  end

  if opts.fzf_history_dir then
    vim.g.fzf_history_dir = opts.fzf_history_dir
  end
end

return {
  config = function(opts)
    opts = vim.tbl_deep_extend("force", defaults, opts)
    config(opts)
  end,
  config_empty = function(opts)
    local empty_opts = {}
    for k, v in pairs(opts) do
      if v == true then
        empty_opts[k] = opts[k]
      else
        empty_opts[k] = v
      end
    end
    config(empty_opts)
  end,
}

-- vim fdm=marker fdl=0
