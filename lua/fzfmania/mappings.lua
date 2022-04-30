local nvim = require("nvim")
local util = require("fzfmania.util")
local fzf_cmd = require("fzf-lua.cmd")
local fzf = require("fzf-lua")
local fzfgrep = require("fzf-lua.providers.grep")

local function op(desc)
  return { silent = true, desc = desc }
end

local function _config(opts)
  if opts.commands then --{{{
    local o = op("show commands")
    if opts.frontend then
      vim.keymap.set("n", opts.commands, function()
        fzf_cmd.load_command("commands")
      end, o)
    else
      vim.keymap.set("n", opts.commands, ":Commands<CR>", o)
    end
  end --}}}

  if opts.history then --{{{
    if opts.frontend then
      vim.keymap.set("n", opts.history, fzf.oldfiles, op("show history"))
    else
      vim.keymap.set("n", opts.history, ":History<CR>", op("show history"))
    end
  end --}}}

  if opts.files then --{{{
    local o = op("show files")
    if opts.frontend then
      vim.keymap.set("n", opts.files, fzf.files, o)
    else
      vim.keymap.set("n", opts.files, ":Files<CR>", o)
    end
  end --}}}

  if opts.files_location then --{{{
    local o = op("show all files in home directory")
    if opts.frontend then
      vim.keymap.set("n", opts.files_location.key, function()
        fzf.files({ cwd = opts.files_location.loc })
      end, o)
    else
      local command = string.format(":Files %s<CR>", opts.files_location.loc)
      vim.keymap.set("n", opts.files_location.key, command, o)
    end
  end --}}}

  if opts.buffers then --{{{
    local o = op("show buffers")
    if opts.frontend then
      vim.keymap.set("n", opts.buffers, fzf.buffers, o)
    else
      vim.keymap.set("n", opts.buffers, ":Buffers<CR>", o)
    end
  end --}}}

  if opts.delete_buffers then --{{{
    local o = op("delete buffers")
    if opts.frontend then
      vim.keymap.set("n", opts.delete_buffers, util.delete_buffers, o)
    else
      vim.keymap.set("n", opts.delete_buffers, util.delete_buffers_native, o)
    end
  end --}}}

  if opts.git_files then --{{{
    local o = op("show files in git (git ls-files)")
    if opts.frontend then
      vim.keymap.set("n", opts.git_files, fzf.git_files, o)
    else
      vim.keymap.set("n", opts.git_files, ":GitFiles<CR>", o)
    end
  end --}}}

  if opts.buffer_lines then --{{{
    local o = op("grep lines of current buffer")
    local header = "'<CR>:jumps to line, <C-w>:adds to locallist, <C-q>:adds to quickfix list'"
    if opts.frontend then
      vim.keymap.set("n", opts.buffer_lines, function()
        fzf.blines({
          fzf_opts = { ["--header"] = header },
        })
      end, o)
    else
      vim.keymap.set("n", opts.buffer_lines, function()
        util.lines_grep(util.fzf_actions, header)
      end, o)
    end
  end --}}}

  if opts.all_buffer_lines then --{{{
    local o = op("search in lines of all open buffers")
    if opts.frontend then
      vim.keymap.set("n", opts.all_buffer_lines, fzf.lines, o)
    else
      vim.keymap.set("n", opts.all_buffer_lines, ":Lines<CR>", o)
    end
  end --}}}

  if opts.complete_dict then --{{{
    -- Replace the default dictionary completion with fzf-based fuzzy completion.
    local command = [[fzf#vim#complete('cat /usr/share/dict/words-insane')]]
    vim.keymap.set("i", "<c-x><c-k>", command, op("dict completion"))
  end --}}}

  if opts.complete_path then --{{{
    vim.keymap.set("i", opts.complete_path, "<Plug>(fzf-complete-path)", op("path completion"))
  end --}}}

  if opts.complete_line then --{{{
    vim.keymap.set("i", opts.complete_line, "<Plug>(fzf-complete-line)", op("line completion"))
  end --}}}

  if opts.spell_suggestion then --{{{
    if opts.frontend then
      vim.keymap.set(
        "n",
        opts.spell_suggestion,
        fzf.spell_suggest,
        { desc = "show spell suggestions" }
      )
    else
      vim.keymap.set("n", opts.spell_suggestion, function()
        local term = vim.fn.expand("<cword>")
        vim.fn["fzf#run"]({
          source = vim.fn.spellsuggest(term),
          sink = function(new_term)
            require("arshlib.quick").normal("n", '"_ciw' .. new_term .. "")
          end,
          down = 10,
        })
      end, { desc = "show spell suggestions" })
    end
  end --}}}

  if opts.in_files then --{{{
    local o = { desc = "find in files" }
    if opts.frontend then
      vim.keymap.set("n", opts.in_files, fzf.grep_project, o)
    else
      vim.keymap.set("n", opts.in_files, function()
        util.ripgrep_search("")
      end, o)
    end
  end --}}}

  if opts.in_files_force then --{{{
    local o = { desc = "find in files (ignore .gitignore)" }
    if opts.frontend then
      vim.keymap.set("n", opts.in_files_force, function()
        fzf.grep({
          search = "",
          rg_opts = "--no-ignore",
        })
      end, o)
    else
      vim.keymap.set("n", opts.in_files_force, function()
        util.ripgrep_search("", true)
      end, o)
    end
  end --}}}

  if opts.incremental_search then --{{{
    local o = { desc = "incremental search with rg" }
    if opts.frontend then
      vim.keymap.set("n", opts.incremental_search, function()
        fzf.live_grep({ exec_empty_query = true })
      end, o)
    else
      vim.keymap.set("n", opts.incremental_search, function()
        util.ripgrep_search_incremental("", true)
      end, o)
    end
  end --}}}

  if opts.current_word then --{{{
    local o = { desc = "search over current word" }
    if opts.frontend then
      vim.keymap.set("n", opts.current_word, fzfgrep.grep_cword, o)
    else
      vim.keymap.set("n", opts.current_word, function()
        util.ripgrep_search(vim.fn.expand("<cword>"))
      end, o)
    end
  end --}}}

  if opts.current_word_force then --{{{
    local o = { desc = "search over current word (ignore .gitignore)" }
    if opts.frontend then
      vim.keymap.set("n", opts.current_word_force, function()
        fzfgrep.grep_cword({
          rg_opts = "--no-ignore",
        })
      end, o)
    else
      vim.keymap.set("n", opts.current_word_force, function()
        util.ripgrep_search(vim.fn.expand("<cword>"), true)
      end, o)
    end
  end --}}}

  if opts.marks then --{{{
    local o = { desc = "show marks" }
    if opts.frontend then
      vim.keymap.set("n", opts.marks, fzf.marks, o)
    else
      vim.keymap.set("n", opts.marks, ":Marks<CR>", o)
    end
  end --}}}

  if opts.tags then --{{{
    vim.keymap.set("n", opts.tags, nvim.ex.BTags, op("show tags"))
  end --}}}
end

return {
  config = _config,
}

-- vim: fdm=marker fdl=0
