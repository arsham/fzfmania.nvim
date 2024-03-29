local util = require("fzfmania.util")
local fzf_cmd = require("fzf-lua.cmd")
local fzf = require("fzf-lua")
local fzfgrep = require("fzf-lua.providers.grep")

local function op(desc)
  return { silent = true, desc = desc }
end

local function _config(opts)
  local frontend = " (native)"
  if opts.frontend then
    frontend = " (fzf-lua)"
  end
  if opts.commands then --{{{
    local o = op("Show commands" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.commands, function()
        fzf_cmd.load_command("commands")
      end, o)
    else
      vim.keymap.set("n", opts.commands, ":Commands<CR>", o)
    end
  end --}}}

  if opts.history then --{{{
    local o = op("Show histoty" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.history, fzf.oldfiles, o)
    else
      vim.keymap.set("n", opts.history, ":History<CR>", o)
    end
  end --}}}

  if opts.files then --{{{
    local o = op("Show (filtered) files" .. frontend)
    if type(opts.files) == "string" then
      -- backwards compatibility
      opts.files.filtered = opts.files
      opts.files.all = opts.filtered
    end
    if opts.frontend then
      vim.keymap.set("n", opts.files.filtered, fzf.files, o)
    else
      vim.keymap.set("n", opts.files.filtered, ":Files<CR>", o)
    end
    if opts.frontend and opts.files.all then
      vim.keymap.set("n", opts.files.all, function()
        fzf.files({
          fd_opts = "--color=never --type f --hidden --follow  --no-ignore",
        })
      end, op("Show (all) files" .. frontend))
    end
  end --}}}

  if opts.files_location then --{{{
    local o = op("Show all files in home directory" .. frontend)
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
    local o = op("Show buffers" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.buffers, fzf.buffers, o)
    else
      vim.keymap.set("n", opts.buffers, ":Buffers<CR>", o)
    end
  end --}}}

  if opts.delete_buffers then --{{{
    local o = op("Delete buffers" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.delete_buffers, util.delete_buffers, o)
    else
      vim.keymap.set("n", opts.delete_buffers, util.delete_buffers_native, o)
    end
  end --}}}

  if opts.git_files then --{{{
    local o = op("Show files in git (git ls-files)" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.git_files, fzf.git_files, o)
    else
      vim.keymap.set("n", opts.git_files, ":GitFiles<CR>", o)
    end
  end --}}}

  if opts.buffer_lines then --{{{
    local o = op("Grep lines of current buffer" .. frontend)
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
    local o = op("Search in lines of all open buffers" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.all_buffer_lines, fzf.lines, o)
    else
      vim.keymap.set("n", opts.all_buffer_lines, ":Lines<CR>", o)
    end
  end --}}}

  if opts.complete_dict then --{{{
    -- Replace the default dictionary completion with fzf-based fuzzy completion.
    vim.keymap.set("i", "<c-x><c-k>", function()
      vim.fn["fzf#vim#complete"]("cat /usr/share/dict/words-insane")
    end, op("Dict completion" .. frontend))
  end --}}}

  if opts.complete_path then --{{{
    vim.keymap.set(
      "i",
      opts.complete_path,
      "<Plug>(fzf-complete-path)",
      op("Path completion" .. frontend)
    )
  end --}}}

  if opts.complete_line then --{{{
    vim.keymap.set(
      "i",
      opts.complete_line,
      "<Plug>(fzf-complete-line)",
      op("Line completion" .. frontend)
    )
  end --}}}

  if opts.spell_suggestion then --{{{
    local o = op("Show spell suggestions" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.spell_suggestion, fzf.spell_suggest, o)
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
      end, o)
    end
  end --}}}

  if opts.in_files then --{{{
    local in_files = opts.in_files
    local in_files_names = nil
    if type(in_files) == "table" then
      in_files_names = in_files[2]
      in_files = in_files[1]
    end

    local o = op("Find in files" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", in_files, function()
        fzf.grep({ search = "", fzf_opts = { ["--nth"] = "2..", ["--delimiter"] = "'[:]'" } })
      end, o)
      if in_files_names then
        vim.keymap.set("n", in_files_names, function()
          fzf.grep({ search = "", fzf_opts = { ["--nth"] = "1.." } })
        end, o)
      end
    else
      vim.keymap.set("n", in_files, util.ripgrep_search, o)
      if in_files_names then
        vim.keymap.set("n", in_files_names, function()
          util.ripgrep_search("", false, true)
        end, o)
      end
    end
  end --}}}

  if opts.in_files_force then --{{{
    local in_files_force = opts.in_files_force
    local in_files_force_name = nil
    if type(in_files_force) == "table" then
      in_files_force_name = in_files_force[2]
      in_files_force = in_files_force[1]
    end

    local o = op("Find in files (ignoring .gitignore directives)" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", in_files_force, function()
        fzf.grep({
          search = "",
          rg_opts = "--no-ignore --column --line-number --no-heading --color=always --smart-case --max-columns=512",
          fzf_opts = { ["--nth"] = "2..", ["--delimiter"] = "'[:]'" },
        })
      end, o)
      if in_files_force_name then
        vim.keymap.set("n", in_files_force_name, function()
          fzf.grep({
            search = "",
            rg_opts = "--no-ignore --column --line-number --no-heading --color=always --smart-case --max-columns=512",
          })
        end, o)
      end
    else
      vim.keymap.set("n", in_files_force, function()
        util.ripgrep_search("", true)
      end, o)
      if in_files_force_name then
        vim.keymap.set("n", in_files_force_name, function()
          util.ripgrep_search("", true, true)
        end, o)
      end
    end
  end --}}}

  if opts.incremental_search then --{{{
    local o = op("Incremental search with rg" .. frontend)
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
    local current_word = opts.current_word
    local current_word_names = nil
    if type(current_word) == "table" then
      current_word_names = current_word[2]
      current_word = current_word[1]
    end

    local o = op("Search over current word" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", current_word, function()
        fzfgrep.grep_cword({
          fzf_opts = { ["--nth"] = "2..", ["--delimiter"] = "'[:]'" },
        })
      end, o)
      if current_word_names then
        vim.keymap.set("n", current_word_names, fzfgrep.grep_cword, o)
      end
    else
      vim.keymap.set("n", current_word, function()
        util.ripgrep_search(vim.fn.expand("<cword>"))
      end, o)
      if current_word_names then
        vim.keymap.set("n", current_word_names, function()
          util.ripgrep_search(vim.fn.expand("<cword>"), false, true)
        end, o)
      end
    end
  end --}}}

  if opts.current_word_force then --{{{
    local current_word_force = opts.current_word_force
    local current_word_force_names = nil
    if type(current_word_force) == "table" then
      current_word_force_names = current_word_force[2]
      current_word_force = current_word_force[1]
    end

    local o = op("Search over current word (ignoring .gitignore directives)" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", current_word_force, function()
        fzfgrep.grep_cword({
          rg_opts = "--no-ignore --column --line-number --no-heading --color=always --smart-case --max-columns=512",
          fzf_opts = { ["--nth"] = "2..", ["--delimiter"] = "'[:]'" },
        })
      end, o)
      if current_word_force_names then
        vim.keymap.set("n", current_word_force_names, function()
          fzfgrep.grep_cword({
            rg_opts = "--no-ignore --column --line-number --no-heading --color=always --smart-case --max-columns=512",
            fzf_opts = { ["--delimiter"] = "'[:]'" },
          })
        end, o)
      end
    else
      vim.keymap.set("n", current_word_force, function()
        util.ripgrep_search(vim.fn.expand("<cword>"), true)
      end, o)
      if current_word_force_names then
        vim.keymap.set("n", current_word_force_names, function()
          util.ripgrep_search(vim.fn.expand("<cword>"), true, true)
        end, o)
      end
    end
  end --}}}

  if opts.marks then --{{{
    local o = op("Show marks" .. frontend)
    if opts.frontend then
      vim.keymap.set("n", opts.marks, fzf.marks, o)
    else
      vim.keymap.set("n", opts.marks, ":Marks<CR>", o)
    end
  end --}}}

  if opts.tags then --{{{
    local btags = vim.cmd.BTags
    if opts.frontend then
      btags = function()
        vim.cmd.FzfLua("btags")
      end
    end

    vim.keymap.set("n", opts.tags, btags, op("Show tags" .. frontend))
  end --}}}
end

return {
  config = _config,
}

-- vim: fdm=marker fdl=0
