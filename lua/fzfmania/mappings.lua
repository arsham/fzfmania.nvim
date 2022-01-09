local nvim = require("nvim")
local util = require("fzfmania.util")

local function op(desc)
  return { noremap = true, silent = true, desc = desc }
end

local function _config(actions, opts)
  if opts.commands then --{{{
    vim.keymap.set("n", opts.commands, ":Commands<CR>", op("show commands"))
  end --}}}

  if opts.history then --{{{
    vim.keymap.set("n", opts.history, ":History<CR>", op("show history"))
  end --}}}

  if opts.files then --{{{
    vim.keymap.set("n", opts.files, ":Files<CR>", op("show files"))
  end --}}}

  if opts.files_location then --{{{
    local command = string.format(":Files %s<CR>", opts.files_location.loc)
    vim.keymap.set("n", opts.files_location.key, command, op("show all files in home directory"))
  end --}}}

  if opts.buffers then --{{{
    vim.keymap.set("n", opts.buffers, ":Buffers<CR>", op("show buffers"))
  end --}}}

  if opts.delete_buffers then --{{{
    vim.keymap.set("n", opts.delete_buffers, util.delete_buffer, op("delete buffers"))
  end --}}}

  if opts.git_files then --{{{
    vim.keymap.set("n", opts.git_files, ":GitFiles<CR>", op("show files in git (git ls-files)"))
  end --}}}

  if opts.buffer_lines then --{{{
    local header = "<CR>:jumps to line, <C-w>:adds to locallist, <C-q>:adds to quickfix list"
    vim.keymap.set("n", opts.buffer_lines, function()
      util.lines_grep(actions, header)
    end, op("grep lines of current buffer"))
  end --}}}

  if opts.all_buffer_lines then --{{{
    local opt = op("search in lines of all open buffers")
    vim.keymap.set("n", opts.all_buffer_lines, ":Lines<CR>", opt)
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
    vim.keymap.set("n", opts.spell_suggestion, function()
      local term = vim.fn.expand("<cword>")
      vim.fn["fzf#run"]({
        source = vim.fn.spellsuggest(term),
        sink = function(new_term)
          require("arshlib.quick").normal("n", '"_ciw' .. new_term .. "")
        end,
        down = 10,
      })
    end, { noremap = true, desc = "show spell suggestions" })
  end --}}}

  if opts.in_files then --{{{
    vim.keymap.set("n", opts.in_files, function()
      util.ripgrep_search("")
    end, { noremap = true, desc = "find in files" })
  end --}}}

  if opts.in_files_force then --{{{
    vim.keymap.set("n", opts.in_files_force, function()
      util.ripgrep_search("", true)
    end, { noremap = true, desc = "find in files (ignore .gitignore)" })
  end --}}}

  if opts.incremental_search then --{{{
    vim.keymap.set("n", opts.incremental_search, function()
      util.ripgrep_search_incremental("", true)
    end, { noremap = true, desc = "incremental search with rg" })
  end --}}}

  if opts.current_word then --{{{
    vim.keymap.set("n", opts.current_word, function()
      util.ripgrep_search(vim.fn.expand("<cword>"))
    end, { noremap = true, desc = "search over current word" })
  end --}}}

  if opts.current_word_force then --{{{
    vim.keymap.set("n", opts.current_word_force, function()
      util.ripgrep_search(vim.fn.expand("<cword>"), true)
    end, { noremap = true, desc = "search over current word (ignore .gitignore)" })
  end --}}}

  if opts.marks then --{{{
    vim.keymap.set("n", opts.marks, ":Marks<CR>", { noremap = true, desc = "show marks" })
  end --}}}

  if opts.tags then --{{{
    vim.keymap.set("n", opts.tags, nvim.ex.BTags, op("show tags"))
  end --}}}
end

return {
  config = _config,
}

-- vim: fdm=marker fdl=0
