local nvim = require("nvim")
local util = require("fzfmania.util")
local command = require("arshlib.quick").command
local fzf = require("fzf-lua")

local function config(opts)
  if opts.git_grep then --{{{
    local o = { bang = true, nargs = "*", desc = "Interactivly grep in commits" }
    command(opts.git_grep, util.git_grep, o)
  end --}}}

  if opts.git_tree then --{{{
    local o = { bang = true, desc = "Browse git commits" }
    command(opts.git_tree, util.git_tree, o)
  end --}}}

  if opts.buffer_lines then --{{{
    local header = "<CR>:jumps to line, <C-w>:adds to locallist, <C-q>:adds to quickfix list"
    local o = { desc = "Search in current buffer lines" }
    if opts.frontend then
      command(opts.buffer_lines, function()
        fzf.blines({
          fzf_opts = { ["--header"] = header, ["--multi"] = "" },
        })
      end, o)
    else
      command(opts.buffer_lines, function()
        util.lines_grep(util.fzf_actions, header)
      end, o)
    end
  end --}}}

  if opts.reload then --{{{
    local o = { desc = "Reload configuration" }
    command(opts.reload, util.reload_config, o)
  end --}}}

  if opts.config then --{{{
    local o = { desc = "Open config files" }
    command(opts.config, util.open_config, o)
  end --}}}

  if opts.todo then --{{{
    local o = { desc = "Search for TODO tags" }
    if opts.frontend then
      command(opts.todo, function()
        fzf.grep({
          search = [[fixme|todo]],
          no_esc = true,
        })
      end, o)
    else
      command(opts.todo, util.open_todo, o)
    end
  end --}}}

  if opts.marks_delete then --{{{
    local o = { desc = "Delete marks interactivly with fzf." }
    if opts.frontend then
      command(opts.marks_delete, util.delete_marks, o)
    else
      command(opts.marks_delete, util.delete_marks_native, o)
    end
  end --}}}

  if opts.marks then --{{{
    local o = { bang = true, bar = true, desc = "Marks with preview" }
    if opts.frontend then
      command(opts.marks, fzf.marks, o)
    else
      command(opts.marks, util.marks, o)
    end
  end --}}}

  if opts.args_add then --{{{
    local o = { desc = "Add to arglist" }
    if opts.frontend then
      command(opts.args_add, util.add_args, o)
    else
      command(opts.args_add, util.add_args_native, o)
    end
  end --}}}

  if opts.args_delete then --{{{
    local o = { desc = "Delete from arglist" }
    if opts.frontend then
      command(opts.args_delete, util.delete_args, o)
    else
      command(opts.args_delete, util.delete_args_native, o)
    end
  end --}}}

  if opts.history then --{{{
    if opts.frontend then
      command(opts.history, fzf.oldfiles)
    else
      command(opts.history, function()
        vim.fn["fzf#vim#history"](vim.fn["fzf#vim#with_preview"]({
          options = "--no-sort",
        }))
      end, { bang = true, nargs = "*" })
    end
  end --}}}

  if opts.checkout then --{{{
    local o = { bang = true, nargs = 0 }
    if opts.frontend then
      command(opts.checkout, fzf.git_branches, o)
    else
      command(opts.checkout, util.checkout_branch, o)
    end
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

  if opts.git_status then --{{{
    if opts.frontend then
      command(opts.git_status, fzf.git_status, { desc = "View git status" })
    end
  end --}}}

  if opts.autocmds then --{{{
    local o = { bang = true, nargs = 0, desc = "Show all autocmds" }
    command(opts.autocmds, util.autocmds, o)
  end --}}}

  if opts.jumps then --{{{
    if opts.frontend then
      command(opts.jumps, fzf.jumps)
    end
  end --}}}

  if opts.changes then --{{{
    if opts.frontend then
      command(opts.changes, fzf.changes)
    end
  end --}}}

  if opts.registers then --{{{
    if opts.frontend then
      command(opts.registers, fzf.registers)
    end
  end --}}}

  if opts.frontend then
    -- these are replacing the native fzf.vim commands.
    command("Buffers", fzf.buffers, { desc = "Browse loaded buffers" })
    command("Lines", fzf.lines, { desc = "Open buffer lines" })
    command("BLines", fzf.blines, { desc = "Buffer lines" })
    command("Commits", fzf.git_commits, { desc = "Browse commits" })
    command("BCommits", fzf.git_bcommits, { desc = "Buffer commits" })
    command("Branches", fzf.git_branches, { desc = "Git branches" })
    command("Tabs", fzf.tabs, { desc = "Browse tabs" })
    command("Colors", fzf.colorschemes, { desc = "Browse colour schemes" })
    command("Args", fzf.args, { desc = "Browse and delete from arglist" })
    command("Maps", fzf.keymaps, { desc = "Browse the registered keymaps" })
    command("Filetypes", fzf.filetypes, { desc = "Browse the registered filetypes" })
  end
end

return {
  config = config,
}

-- vim: fdm=marker fdl=0
