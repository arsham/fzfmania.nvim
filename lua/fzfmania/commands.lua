local nvim = require("nvim")
local util = require("fzfmania.util")
local command = require("arshlib.quick").command

local function config(actions, opts)
  if opts.git_grep then --{{{
    command(opts.git_grep, util.git_grep, { bang = true, nargs = "*" })
  end --}}}

  if opts.buffer_lines then --{{{
    local header = "<CR>:jumps to line, <C-w>:adds to locallist, <C-q>:adds to quickfix list"
    command(opts.buffer_lines, function()
      util.lines_grep(actions, header)
    end)
  end --}}}

  if opts.reload then --{{{
    command(opts.reload, util.reload_config)
  end --}}}

  if opts.config then --{{{
    command(opts.config, util.open_config)
  end --}}}

  if opts.todo then --{{{
    command(opts.todo, util.open_todo)
  end --}}}

  if opts.marks_delete then --{{{
    command(opts.marks_delete, util.delete_marks, { desc = "Delete marks interactivly with fzf." })
  end --}}}

  if opts.marks then --{{{
    command(opts.marks, util.marks, { bang = true, bar = true, desc = "Marks with preview" })
  end --}}}

  if opts.args_add then --{{{
    command(opts.args_add, util.add_args)
  end --}}}

  if opts.args_delete then --{{{
    command(opts.args_delete, util.delete_args)
  end --}}}

  if opts.history then --{{{
    command(opts.history, function()
      vim.fn["fzf#vim#history"](vim.fn["fzf#vim#with_preview"]({
        options = "--no-sort",
      }))
    end, { bang = true, nargs = "*" })
  end --}}}

  if opts.checkout then --{{{
    command(opts.checkout, util.checkout_branck, { bang = true, nargs = 0 })
  end --}}}

  if opts.work_tree then --{{{
    ---Switch git worktrees. It creates a new tab in the new location.
    command(opts.work_tree, function()
      local cmd = "git worktree list | cut -d' ' -f1"
      local wrapped = vim.fn["fzf#wrap"]({
        source = cmd,
        options = { "--no-multi" },
      })
      wrapped["sink*"] = function(dir)
        nvim.ex.tabnew()
        nvim.ex.tcd(dir[2])
      end
      vim.fn["fzf#run"](wrapped)
    end)
  end --}}}
end

return {
  config = config,
}

-- vim: fdm=marker fdl=0
