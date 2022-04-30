local nvim = require("nvim")
local fs = require("arshlib.fs")
local colour = require("arshlib.colour")
local quick = require("arshlib.quick")
local lsp = require("arshlib.lsp")
local listish = require("listish")
local reloader = require("plenary.reload")
local fzf = require("fzf-lua")
local fzfcore = require("fzf-lua.core")
local fzfutils = require("fzf-lua.utils")
local fzfconfig = require("fzf-lua.config")

local M = {}

---Launches a ripgrep search with a fzf search interface.
---@param term? string if empty, the search will only happen on the content.
---@param no_ignore? boolean disables the ignore rules.
function M.ripgrep_search(term, no_ignore) --{{{
  term = vim.fn.shellescape(term)
  local nth = ""
  local with_nth = ""
  local delimiter = ""
  if term then
    with_nth = "--nth 2.."
    nth = "--nth 1,4.."
    delimiter = "--delimiter :"
  end
  no_ignore = no_ignore and "" or "--no-ignore"

  local rg_cmd = table.concat({
    "rg",
    "--line-number",
    "--column",
    "--no-heading",
    "--color=always",
    "--smart-case",
    "--hidden",
    '-g "!.git/" ',
    no_ignore,
    "--",
    term,
  }, " ")

  local args = {
    options = table.concat({
      '--prompt="Search in files> "',
      "--preview-window nohidden",
      delimiter,
      with_nth,
      nth,
    }, " "),
  }

  local preview = vim.fn["fzf#vim#with_preview"](args)
  vim.fn["fzf#vim#grep"](rg_cmd, 1, preview)
end --}}}

---Launches an incremental search with ripgrep and fzf.
---@param term? string if empty, the search will only happen on the content.
---@param no_ignore? string disables the ignore rules.
function M.ripgrep_search_incremental(term, no_ignore) --{{{
  term = vim.fn.shellescape(term)
  local query = ""
  local nth = ""
  local with_nth = ""
  local delimiter = ""
  if term then
    query = "--query " .. term
    with_nth = "--nth 2.."
    nth = "--nth 1,4.."
    delimiter = "--delimiter :"
  end
  no_ignore = no_ignore and "" or "--no-ignore"

  local rg_cmd = table.concat({
    "rg",
    "--line-number",
    "--column",
    "--no-heading",
    "--color=always",
    "--smart-case",
    "--hidden",
    '-g "!.git/" ',
    no_ignore,
    "-- %s || true",
  }, " ")

  local initial = string.format(rg_cmd, term)
  local reload_cmd = string.format(rg_cmd, "{q}")

  local args = {
    options = table.concat({
      '--prompt="1. Ripgrep> "',
      '--header="<Alt-Enter>:Reload on current query"',
      "--header-lines=1",
      "--preview-window nohidden",
      query,
      "--bind",
      string.format("'change:reload:%s'", reload_cmd),
      '--bind "alt-enter:unbind(change,alt-enter)+change-prompt(2. FZF> )+enable-search+clear-query"',
      "--tiebreak=index",
      delimiter,
      with_nth,
      nth,
    }, " "),
  }

  local preview = vim.fn["fzf#vim#with_preview"](args)
  vim.fn["fzf#vim#grep"](initial, 1, preview)
end --}}}

function M.delete_buffers_native() --{{{
  local list = vim.fn.getbufinfo({ buflisted = 1 })
  local buf_list = {
    table.concat({ "", "", "", "Buffer", "", "Filename", "" }, "\t"),
  }
  local cur_buf = vim.fn.bufnr("")
  local alt_buf = vim.fn.bufnr("#")

  for _, v in pairs(list) do
    local name = vim.fn.fnamemodify(v.name, ":~:.")
    -- the bufnr can't go to the first item otherwise it breaks the preview
    -- line
    local t = {
      string.format("%s:%d", v.name, v.lnum),
      v.lnum,
      tostring(v.bufnr),
      string.format("[%s]", colour.ansi_color(colour.colours.red, v.bufnr)),
      "",
      name,
      "",
    }
    local signs = ""
    if v.bufnr == cur_buf then
      signs = signs .. colour.ansi_color(colour.colours.red, "%")
    end
    if v.bufnr == alt_buf then
      signs = signs .. "#"
    end
    t[5] = signs
    if v.changed > 0 then
      t[7] = "[+]"
    end
    table.insert(buf_list, table.concat(t, "\t"))
  end

  local wrapped = vim.fn["fzf#wrap"]({
    source = buf_list,
    options = table.concat({
      '--prompt "Delete Buffers > "',
      "--multi",
      "--exit-0",
      "--ansi",
      "--delimiter '\t'",
      "--with-nth=4..",
      "--nth=3",
      "--bind 'ctrl-a:select-all+accept'",
      "--preview-window +{3}+3/2,nohidden",
      "--tiebreak=index",
      "--header-lines=1",
    }, " "),
    placeholder = "{1}",
  })

  local preview = vim.fn["fzf#vim#with_preview"](wrapped)
  preview["sink*"] = function(names)
    for _, name in pairs({ unpack(names, 2) }) do
      local num = tonumber(name:match("^[^\t]+\t[^\t]+\t([^\t]+)\t"))
      pcall(vim.api.nvim_buf_delete, num, {})
    end
  end
  vim.fn["fzf#run"](preview)
end --}}}

---Shows all opened buffers and let you search and delete them.
function M.delete_buffers() --{{{
  fzf.buffers({
    prompt = "Delete Buffers > ",
    ignore_current_buffer = false,
    sort_lastused = false,
    fzf_opts = {
      ["--header"] = "'" .. table.concat({ "Buffer", "", "Filename", "" }, "\t") .. "'",
    },
    actions = {
      ["default"] = function(selected)
        for _, name in pairs(selected) do
          local num = name:match("^%[([^%]]+)%]")
          pcall(vim.api.nvim_buf_delete, tonumber(num), {})
        end
      end,
    },
  })
end --}}}

---Searches in the lines of current buffer. It provides an incremental search
-- that would switch to fzf filtering on <Alt-Enter>.
---@param actions table the actions for the sink.
---@param header? string the header to explain the actions.
function M.lines_grep(actions, header) --{{{
  header = header and '--header="' .. header .. '"' or ""
  local options = table.concat({
    '--prompt="Current Buffer> "',
    header,
    "--layout reverse-list",
    '--delimiter="\t"',
    "--with-nth=3..",
    "--preview-window nohidden",
  }, " ")

  local filename = vim.fn.fnameescape(vim.fn.expand("%"))
  local rg_cmd = {
    "rg",
    ".",
    "--line-number",
    "--no-heading",
    "--color=never",
    "--smart-case",
    filename,
  }
  local got = vim.fn.systemlist(rg_cmd)
  local source = {}
  for _, line in pairs(got) do
    local num, content = line:match("^(%d+):(.+)$")
    if not num then
      return
    end
    table.insert(source, string.format("%s:%d\t%d\t%s", filename, num, num, content))
  end
  local wrapped = vim.fn["fzf#wrap"]({
    source = source,
    options = options,
    placeholder = "{1}",
  })

  local preview = vim.fn["fzf#vim#with_preview"](wrapped)
  preview["sink*"] = function(names)
    if #names == 0 then
      return
    end
    local action = names[1]
    if #action > 0 then
      local fn = actions[action]
      _t(names)
        :when(fn)
        :slice(2)
        :map(function(v)
          local name, line, content = v:match("^([^:]+):([^\t]+)\t([^\t]+)\t(.+)")
          return {
            filename = vim.fn.fnameescape(name),
            lnum = tonumber(line),
            col = 1,
            text = content,
          }
        end)
        :exec(fn)
    end

    if #names == 2 then
      local num = names[2]:match("^[^:]+:(%d+)\t")
      quick.normal("n", string.format("%dgg", num))
    end
  end
  vim.fn["fzf#run"](preview)
end --}}}

---Launches a fzf search for reloading config files.
function M.reload_config() --{{{
  local loc = vim.env["MYVIMRC"]
  local base_dir = require("plenary.path"):new(loc):parents()[1]
  local got = vim.fn.systemlist({ "fd", ".", "-e", "lua", "-t", "f", "-L", base_dir })
  local source = {}
  for _, name in ipairs(got) do
    table.insert(source, ("%s\t%s"):format(name, vim.fn.fnamemodify(name, ":~:.")))
  end

  local wrapped = vim.fn["fzf#wrap"]({
    source = source,
    options = table.concat({
      '--prompt="Open Config> "',
      '--header="<C-a>:Reload all"',
      '--delimiter="\t"',
      "--with-nth=2..",
      "--nth=1",
      "--multi",
      "--bind ctrl-a:select-all+accept",
      "--preview-window +{3}+3/2,nohidden",
      "--tiebreak=index",
    }, " "),
    placeholder = "{1}",
  })
  local preview = vim.fn["fzf#vim#with_preview"](wrapped)
  preview["sink*"] = function(list)
    local names = _t(list):slice(2):map(function(v)
      return v:match("^[^\t]*")
    end)

    names
      :filter(function(name)
        name = name:match("^[^\t]*")
        local mod, ok = fs.file_module(name)
        return ok, mod.module
      end)
      :map(function(mod)
        reloader.reload_module(mod, false)
        require(mod)
        return mod
      end)
      :exec(function(mod)
        local msg = table.concat(mod, "\n")
        vim.notify(msg, vim.lsp.log_levels.INFO, {
          title = "Reloaded",
          timeout = 1000,
        })
      end)
  end
  vim.fn["fzf#run"](preview)
end --}}}

---Open one of your neovim config files.
function M.open_config() --{{{
  local path = vim.fn.stdpath("config")
  local got = vim.fn.systemlist({ "fd", ".", "-t", "f", "-F", path })
  local source = {}
  for _, name in ipairs(got) do
    table.insert(source, ("%s\t%s"):format(name, vim.fn.fnamemodify(name, ":~:.")))
  end

  local wrapped = vim.fn["fzf#wrap"]({
    source = source,
    options = table.concat({
      '--prompt="Open Config> "',
      "+m",
      "--with-nth=2..",
      "--nth=1",
      '--delimiter="\t"',
      "--preview-window +{3}+3/2,nohidden",
      "--tiebreak=index",
    }, " "),
    placeholder = "{1}",
  })
  local preview = vim.fn["fzf#vim#with_preview"](wrapped)
  preview["sink*"] = function() end
  preview["sink"] = function(filename)
    filename = filename:match("^[^\t]*")
    if filename ~= "" then
      nvim.ex.edit(filename)
    end
  end
  vim.fn["fzf#run"](preview)
end --}}}

---Show marks with preview.
function M.marks() --{{{
  local home = vim.fn["fzf#shellescape"](vim.fn.expand("%"))
  local preview = vim.fn["fzf#vim#with_preview"]({
    placeholder = table.concat({
      '$([ -r $(echo {4} | sed "s#^~#$HOME#") ]',
      "&& echo {4}",
      "|| echo ",
      home,
      "):{2}",
    }, " "),
    options = "--preview-window +{2}-/2",
  })
  vim.fn["fzf#vim#marks"](preview, 0)
end --}}}

---Show marks for deletion using fzf's native ui.
function M.delete_marks_native() --{{{
  local mark_list = _t({
    ("666\tmark\t%5s\t%3s\t%s"):format("line", "col", "file/text"),
  })
  local bufnr = vim.fn.bufnr()
  local bufname = vim.fn.bufname(bufnr)
  _t(vim.fn.getmarklist(bufnr))
    :map(function(v)
      v.file = bufname
      return v
    end)
    :merge(vim.fn.getmarklist())
    :filter(function(v)
      return string.match(string.lower(v.mark), "[a-z]")
    end)
    :map(function(v)
      mark_list:insert(
        ("%s:%d\t%s\t%5d\t%3d\t%s"):format(
          vim.fn.fnamemodify(v.file, ":~:."),
          v.pos[2],
          string.sub(v.mark, 2, 2),
          v.pos[2],
          v.pos[3],
          v.file
        )
      )
    end)

  local wrapped = vim.fn["fzf#wrap"]({ --{{{
    source = mark_list,
    options = table.concat({
      '--prompt="Delete Mark> "',
      '--header="<C-a>:Delete all"',
      "--header-lines=1",
      '--delimiter="\t"',
      "--with-nth=2..",
      "--nth=3",
      "--multi",
      "--exit-0",
      "--bind ctrl-a:select-all+accept",
      "--preview-window +{3}+3/2,nohidden",
      "--tiebreak=index",
    }, " "),
    placeholder = "{1}",
  }) --}}}
  local preview = vim.fn["fzf#vim#with_preview"](wrapped)
  preview["sink*"] = function(names)
    _t(names):slice(2):map(function(name)
      local mark = string.match(name, "^[^\t]+\t(%a)")
      nvim.ex.delmarks(mark)
    end)
  end
  vim.fn["fzf#run"](preview)
end --}}}

---Show marks for deletion.
function M.delete_marks() --{{{
  local opts = {
    fzf_opts = {
      ["--multi"] = "",
      ["--exit-0"] = "",
      ["--bind"] = "ctrl-a:select-all+accept",
    },
  }
  opts = fzfconfig.normalize_opts(opts, fzfconfig.globals.nvim.marks)
  if not opts then
    return
  end

  local marks = vim.fn.execute("marks")
  marks = vim.split(marks, "\n")

  local entries = {}
  for i = #marks, 3, -1 do
    if string.match(string.lower(marks[i]), "^%s+[a-z]") then
      local mark, line, col, text = marks[i]:match("(.)%s+(%d+)%s+(%d+)%s+(.*)")
      table.insert(
        entries,
        string.format(
          "%-15s %-15s %-15s %s",
          fzfutils.ansi_codes.yellow(mark),
          fzfutils.ansi_codes.blue(line),
          fzfutils.ansi_codes.green(col),
          text
        )
      )
    end
  end

  table.sort(entries, function(a, b)
    return a < b
  end)

  fzfcore.fzf_wrap(opts, entries, function(selected)
    for _, name in ipairs(selected) do
      local mark = string.match(name, "^(%a)")
      nvim.ex.delmarks(mark)
    end
  end)()
end -- }}}

---Two phase search in git commits. The initial search is with git and the
-- secondary is with fzf.
function M.git_grep(term) --{{{
  local format = "format:"
    .. table.concat({
      "%H",
      "%C(yellow)%h%C(reset)",
      "%C(bold green)(%ar)%C(reset)",
      "%s",
      "%C(green)<%an>%C(reset)",
      "%C(blue)%d%C(reset)",
    }, "\t")
  local query = [[git --no-pager log -G '%s' --color=always --format='%s']]
  local source = vim.fn.systemlist(string.format(query, term.args, format))
  local reload_cmd = string.format(query, "{q}", format)
  local wrapped = vim.fn["fzf#wrap"]({ --{{{
    source = source,
    options = table.concat({
      '--prompt="Search in tree> "',
      "+m",
      '--delimiter="\t"',
      "--phony",
      "--with-nth=2..",
      "--nth=3..",
      "--tiebreak=index",
      "--preview-window +{3}+3/2,~1,nohidden",
      "--exit-0",
      "--bind",
      string.format('"change:reload:%s"', reload_cmd),
      "--ansi",
      "--bind",
      '"alt-enter:unbind(change,alt-enter)+change-prompt(2. FZF> )+enable-search+clear-query"',
      "--preview",
      '"',
      [[echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |]],
      "xargs -I % sh -c 'git show --color=always %'",
      '"',
    }, " "),
    placeholder = "{1}",
  })
  --}}}
  wrapped["sink*"] = function(list)
    for _, sha in pairs(list) do
      sha = sha:match("^[^\t]*")
      if sha ~= "" then
        local toplevel = vim.fn.system("git rev-parse --show-toplevel")
        toplevel = string.gsub(toplevel, "\n", "")
        local str = string.format([[fugitive://%s/.git//%s]], toplevel, sha)
        nvim.ex.edit(str)
      end
    end
  end
  vim.fn["fzf#run"](wrapped)
end --}}}

---Browse the git tree.
function M.git_tree() --{{{
  local format = "format:"
    .. table.concat({
      "%H",
      "%C(yellow)%h%C(reset)",
      "%C(bold green)(%ar)%C(reset)",
      "%s",
      "%C(green)<%an>%C(reset)",
      "%C(blue)%d%C(reset)",
    }, "\t")

  local query = [[git --no-pager log --all --color=always --format='%s']]
  local source = vim.fn.systemlist(string.format(query, format))
  local wrapped = vim.fn["fzf#wrap"]({ --{{{
    source = source,
    options = table.concat({
      '--prompt="Search in tree> "',
      "+m",
      '--delimiter="\t"',
      "--with-nth=2..",
      "--nth=3..",
      "--tiebreak=index",
      "--preview-window +{3}+3/2,~1,nohidden",
      "--exit-0",
      "--ansi",
      "--preview",
      '"',
      [[echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |]],
      "xargs -I % sh -c 'git show --color=always %'",
      '"',
    }, " "),
    placeholder = "{1}",
  })
  --}}}
  wrapped["sink*"] = function(list)
    local sha = list[2]:match("^[^\t]*")
    if sha ~= "" then
      local toplevel = vim.fn.system("git rev-parse --show-toplevel")
      toplevel = string.gsub(toplevel, "\n", "")
      local str = string.format([[fugitive://%s/.git//%s]], toplevel, sha)
      nvim.ex.edit(str)
    end
  end
  vim.fn["fzf#run"](wrapped)
end --}}}

---Checkout a branch.
function M.checkout_branch() --{{{
  local current = vim.fn.system("git symbolic-ref --short HEAD")
  current = current:gsub("\n", "")
  local current_escaped = current:gsub("/", "\\/")

  local cmd = table.concat({
    "git",
    "branch",
    "-r",
    "--no-color |",
    "sed",
    "-r",
    "-e 's/^[^/]*\\///'",
    "-e '/^",
    current_escaped,
    "$/d' -e '/^HEAD/d' | sort -u",
  }, " ")
  local opts = {
    sink = function(branch)
      vim.fn.system("git checkout " .. branch)
    end,
    options = { "--no-multi", "--header=Currently on: " .. current },
  }
  vim.fn["fzf#vim#grep"](cmd, 0, opts)
end --}}}

---Search for all todo/fixme/etc.
---@param extra_terms table any extra terms.
function M.open_todo(extra_terms) --{{{
  local terms = vim.tbl_extend("force", {
    "fixme",
    "todo",
  }, extra_terms)
  terms = table.concat(terms, "|")

  local cmd = table.concat({
    "rg",
    "--line-number",
    "--column",
    "--no-heading",
    "--color=always",
    "--smart-case",
    "--hidden",
    '-g "!.git/"',
    "--",
    '"fixme|todo"',
    '"' .. terms .. '"',
  }, " ")
  vim.fn["fzf#vim#grep"](cmd, 1, vim.fn["fzf#vim#with_preview"]())
end --}}}

---Find and add files to the args list using fzf.vim native interface.
local function add_args_native() --{{{
  local seen = _t()
  _t(vim.fn.argv()):map(function(v)
    seen[v] = true
  end)

  local files = _t()
  _t(vim.fn.systemlist({ "fd", ".", "-t", "f" }))
    :map(function(v)
      return v:gsub("^./", "")
    end)
    :filter(function(v)
      return not seen[v]
    end)
    :map(function(v)
      table.insert(files, v)
    end)

  if #files == 0 then
    local msg = "Already added everything from current folder"
    vim.notify(msg, vim.lsp.log_levels.WARN, { title = "Adding Args" })
    return
  end

  local wrapped = vim.fn["fzf#wrap"]({
    source = files,
    options = "--multi --bind ctrl-a:select-all+accept",
  })
  wrapped["sink*"] = function(lines)
    nvim.ex.arga(lines)
  end
  vim.fn["fzf#run"](wrapped)
end --}}}

---Find and add files to the args list.
function M.add_args() --{{{
  fzf.files({
    prompt = "Choose Files> ",
    -- fzf_opts = {
    --   ["--header"] = "'" .. table.concat({ "Buffer", "", "Filename", "" }, "\t") .. "'",
    -- },
    fd_opts = "--color=never --type f --hidden --follow --exclude .git",
    actions = {
      ["default"] = function(selected)
        nvim.ex.arga(selected)
      end,
    },
  })
end --}}}

---Find and add files to the args list.
function M.delete_args() --{{{
  fzf.args({
    prompt = "Choose Files> ",
    fzf_opts = {
      ["--exit-0"] = "",
    },
    actions = {
      ["default"] = function(selected)
        nvim.ex.argd(selected)
      end,
    },
  })
end --}}}

---Choose and remove files from the args list.
function M.delete_args_native() --{{{
  local wrapped = vim.fn["fzf#wrap"]({
    source = vim.fn.argv(),
    options = "--multi --bind ctrl-a:select-all+accept",
  })
  wrapped["sink*"] = function(lines)
    nvim.ex.argd(lines)
  end
  vim.fn["fzf#run"](wrapped)
end --}}}

---Populate the quickfix/local lists search results. Use it as an action.
---@param items string[]|table[]
function M.insert_into_list(items, is_local) --{{{
  local values = {}
  for _, item in pairs(items) do
    if type(item) == "string" then
      item = {
        filename = item,
        lnum = 1,
        col = 1,
        text = "Added with fzf selection",
      }
    end
    local bufnr = vim.fn.bufnr(item.filename)
    if bufnr > 0 then
      local line = vim.api.nvim_buf_get_lines(bufnr, item.lnum - 1, item.lnum, false)[1]
      if line ~= "" then
        item.text = line
      end
    end
    table.insert(values, item)
  end
  listish.insert_list(values, is_local)
end --}}}

---Shows a fzf search for going to definition. If LSP is not attached, it uses
--the BTags functionality. Use it as an action.
---@param lines string[]
function M.goto_def(lines) --{{{
  local file = lines[1]
  vim.api.nvim_command(("e %s"):format(file))
  if lsp.is_lsp_attached() and lsp.has_lsp_capability("documentSymbolProvider") then
    local ok = pcall(vim.lsp.buf.document_symbol)
    if ok then
      return
    end
  end
  nvim.ex.BTags()
end --}}}

function M.autocmds() --{{{
  local autocmds = vim.api.nvim_get_autocmds({})
  local source = {}
  for _, item in pairs(autocmds) do
    local buf = item.buflocal and colour.ansi_color(colour.colours.red, "BUF") or ""
    local once = item.once and colour.ansi_color(colour.colours.yellow, "ONCE") or ""
    local line = table.concat({
      colour.ansi_color(colour.colours.blue, item.event),
      buf .. once,
      colour.ansi_color(colour.colours.green, item.pattern),
      item.command,
    }, "\t")
    table.insert(source, line)
  end

  local wrapped = vim.fn["fzf#wrap"]({
    source = source,
    options = table.concat({
      '--prompt "Search Term > "',
      "--header 'Event\tBuffer/Once\tPattern\tCommand'",
      "+m",
      "--exit-0",
      "--ansi",
      "--delimiter '\t'",
      "--no-preview",
      "--tiebreak=index",
    }, " "),
    placeholder = "{1}",
  })

  wrapped["sink*"] = function() end
  vim.fn["fzf#run"](wrapped)
end --}}}

function M.jumps(opts) --{{{
  local config = require("fzf-lua.config")
  local utils = require("fzf-lua.utils")
  local core = require("fzf-lua.core")
  local actions = require("fzf-lua.actions")
  opts = config.normalize_opts(opts, config.globals.nvim.jumps)
  if not opts then
    return
  end

  local jumps = vim.fn.execute(opts.cmd)
  jumps = vim.split(jumps, "\n")

  local entries = {}
  for i = #jumps - 1, 3, -1 do
    local jump, line, col, text = jumps[i]:match("(%d+)%s+(%d+)%s+(%d+)%s+(.*)")
    table.insert(
      entries,
      string.format(
        "%-15s %-15s %-15s %s",
        utils.ansi_codes.yellow(jump),
        utils.ansi_codes.blue(line),
        utils.ansi_codes.green(col),
        text
      )
    )
  end

  opts.fzf_opts["--no-multi"] = ""

  core.fzf_wrap(opts, entries, function(selected)
    if not selected then
      return
    end
    actions.act(opts.actions, selected, opts)
  end)()
end --}}}

---Shows a fzf search for going to a line number.
---@param lines string[]
local function goto_line(lines) --{{{
  local file = lines[1]
  vim.api.nvim_command(("e %s"):format(file))
  quick.normal("n", ":")
end --}}}

---Shows a fzf search for line content.
---@param lines string[]
local function search_file(lines) --{{{
  local file = lines[1]
  vim.api.nvim_command(("e +BLines %s"):format(file))
end --}}}

---Set selected lines in the quickfix list with fzf search.
---@param items string[]|table[]
local function set_qf_list(items) --{{{
  M.insert_into_list(items, false)
  nvim.ex.copen()
end --}}}

---Set selected lines in the local list with fzf search.
---@param items string[]|table[]
local function set_loclist(items) --{{{
  M.insert_into_list(items, true)
  nvim.ex.lopen()
end --}}}

M.fzf_actions = { --{{{
  ["ctrl-t"] = "tab split",
  ["ctrl-s"] = "split",
  ["ctrl-v"] = "vsplit",
  ["alt-q"] = set_qf_list,
  ["alt-w"] = set_loclist,
  ["alt-@"] = M.goto_def,
  ["alt-:"] = goto_line,
  ["alt-/"] = search_file,
} --}}}
vim.g.fzf_action = M.fzf_actions

return M

-- vim: fdm=marker fdl=0
