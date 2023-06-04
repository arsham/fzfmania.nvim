local util = require("fzfmania.util")
local command = require("arshlib.quick").command
local fzf = require("fzf-lua")

local function config(opts)
  local frontend = " (native)"
  if opts.frontend then
    frontend = " (fzf-lua)"
  end
  if opts.git_grep then --{{{
    local o = { bang = true, nargs = "*", desc = "Interactivly grep in commits" .. frontend }
    command(opts.git_grep, util.git_grep, o)
  end --}}}

  if opts.git_tree then --{{{
    local o = { bang = true, desc = "Browse git commits" }
    command(opts.git_tree, util.git_tree, o)
  end --}}}

  if opts.buffer_lines then --{{{
    local header = "<CR>:jumps to line, <C-w>:adds to locallist, <C-q>:adds to quickfix list"
    local o = { desc = "Search in current buffer lines" .. frontend }
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
    local o = { desc = "Reload configuration (deprecated)" }
    ---@diagnostic disable-next-line: deprecated
    command(opts.reload, util.reload_config, o)
  end --}}}

  if opts.config then --{{{
    local o = { desc = "Open config files" .. frontend }
    command(opts.config, util.open_config, o)
  end --}}}

  if opts.todo then --{{{
    local o = { desc = "Search for TODO tags" .. frontend }
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
    local o = { desc = "Delete marks interactivly with fzf" .. frontend }
    if opts.frontend then
      command(opts.marks_delete, util.delete_marks, o)
    else
      command(opts.marks_delete, util.delete_marks_native, o)
    end
  end --}}}

  if opts.marks then --{{{
    local o = { bang = true, bar = true, desc = "Marks with preview" .. frontend }
    if opts.frontend then
      command(opts.marks, fzf.marks, o)
    else
      command(opts.marks, util.marks, o)
    end
  end --}}}

  if opts.args_add then --{{{
    local o = { desc = "Add to arglist" .. frontend }
    if opts.frontend then
      command(opts.args_add, util.add_args, o)
    else
      command(opts.args_add, util.add_args_native, o)
    end
  end --}}}

  if opts.args_delete then --{{{
    local o = { desc = "Delete from arglist" .. frontend }
    if opts.frontend then
      command(opts.args_delete, util.delete_args, o)
    else
      command(opts.args_delete, util.delete_args_native, o)
    end
  end --}}}

  if opts.history then --{{{
    local desc = "Browse file history" .. frontend
    if opts.frontend then
      command(opts.history, fzf.oldfiles, { desc = desc })
    else
      command(opts.history, function()
        vim.fn["fzf#vim#history"](vim.fn["fzf#vim#with_preview"]({
          options = "--no-sort",
        }))
      end, { bang = true, nargs = "*", desc = desc })
    end
  end --}}}

  if opts.checkout then --{{{
    local o = { bang = true, nargs = 0, desc = "Checkout a branch" .. frontend }
    if opts.frontend then
      command(opts.checkout, fzf.git_branches, o)
    else
      command(opts.checkout, util.checkout_branch, o)
    end
  end --}}}

  if opts.work_tree then --{{{
    local o =
      { desc = "Switch git worktrees. It creates a new tab in the new location" .. frontend }
    command(opts.work_tree, function()
      local cmd = "git worktree list | cut -d' ' -f1"
      local wrapped = vim.fn["fzf#wrap"]({
        source = cmd,
        options = { "--no-multi" },
      })
      wrapped["sink*"] = function(dir)
        vim.cmd.tabnew()
        vim.cmd.tcd(dir[2])
      end
      vim.fn["fzf#run"](wrapped)
    end, o)
  end --}}}

  if opts.git_status then --{{{
    if opts.frontend then
      command(opts.git_status, fzf.git_status, { desc = "View git status" .. frontend })
    end
  end --}}}

  if opts.autocmds then --{{{
    local o = { bang = true, nargs = 0, desc = "Show all autocmds" .. frontend }
    if opts.frontend then
      command(opts.autocmds, util.autocmds, o)
    else
      command(opts.autocmds, util.autocmds_native, o)
    end
  end --}}}

  if opts.jumps then --{{{
    local o = { desc = "Browse jumps" .. frontend }
    if opts.frontend then
      command(opts.jumps, fzf.jumps, o)
    end
  end --}}}

  if opts.changes then --{{{
    local o = { desc = "Browse changes" .. frontend }
    if opts.frontend then
      command(opts.changes, fzf.changes, o)
    end
  end --}}}

  if opts.registers then --{{{
    local o = { desc = "View registers" .. frontend }
    if opts.frontend then
      command(opts.registers, fzf.registers, o)
    end
  end --}}}

  if opts.frontend then
    -- these are replacing the native fzf.vim commands.
    command("Buffers", fzf.buffers, { desc = "Browse loaded buffers" .. frontend })
    command("Lines", fzf.lines, { desc = "Open buffer lines" .. frontend })
    command("BLines", fzf.blines, { desc = "Buffer lines" .. frontend })
    command("Commits", fzf.git_commits, { desc = "Browse commits" .. frontend })
    command("BCommits", fzf.git_bcommits, { desc = "Buffer commits" .. frontend })
    command("Branches", fzf.git_branches, { desc = "Git branches" .. frontend })
    command("Tabs", fzf.tabs, { desc = "Browse tabs" .. frontend })
    command("Colors", fzf.colorschemes, { desc = "Browse colour schemes" .. frontend })
    command("Args", fzf.args, { desc = "Browse and delete from arglist" .. frontend })
    command("Maps", fzf.keymaps, { desc = "Browse the registered keymaps" .. frontend })
    command("Filetypes", fzf.filetypes, { desc = "Browse the registered filetypes" .. frontend })
    command("Files", fzf.files, { desc = "Browse files" .. frontend })
    command("GitFiles", fzf.git_files, { desc = "Browse the files in git" .. frontend })
    command("GFiles", fzf.git_files, { desc = "Browse the files in git" .. frontend })
  end
end

return {
  config = config,
}

-- vim: fdm=marker fdl=0
