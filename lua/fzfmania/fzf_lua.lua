local actions = require("fzf-lua.actions")
local quick = require("arshlib.quick")
local fzf = require("fzf-lua")
local lsp = require("arshlib.lsp")
local path = require("fzf-lua.path")

local function get_filename(selected) -- {{{
  if #selected < 1 then
    return nil
  end
  return path.entry_to_file(selected[1]).path
end -- }}}

local function sink_line_number(selected) --{{{
  local filename = get_filename(selected)
  if not filename then
    return
  end
  vim.cmd.edit(filename)
  quick.normal("n", ":")
end --}}}

-- FD exclude list {{{
local fd_exclude = " -E "
  .. table.concat({
    "'*.JPEG'",
    "'*.JPG'",
    "'*.gif'",
    "'*.iso'",
    "'*.jpeg'",
    "'*.jpg'",
    "'*.mp4'",
    "'*.part'",
    "'*.pdf'",
    "'*.png'",
    "'*.so'",
    "'*.o'",
    "'*.o.d'",
    "'*.svg'",
    "'*.h.in'",
    ".cache",
    ".dropbox",
    ".gimme",
    ".git",
    ".helm",
    ".kube",
    ".local/lib",
    ".local/pipx",
    ".local/share",
    ".mozilla",
    ".npm",
    ".rustup",
    ".steam",
    ".themes",
    ".virtualenvs",
    "Documents/pkgbuild",
    "Dropbox/.dropbox.cache",
    "Dropbox/Home/.purple",
    "Pictures",
    "Videos",
    "dotfiles",
    "go/pkg",
    "node_modules",
    "target",
    "tmp/delete",
    "tmp/googleapis",
    "zig-cache",
    "tmp/neovim",
  }, " -E ") -- }}}

require("fzf-lua").setup({
  winopts = { --{{{
    height = 0.7,
    width = 1,
    row = 1,
    border = false,

    hl = { --{{{
      normal = "Normal",
      border = "FloatBorder",
      cursor = "Cursor",
      cursorline = "CursorLine",
      search = "Search",
      scrollbar_f = "PmenuThumb",
      scrollbar_e = "PmenuSbar",
    }, --}}}

    preview = { --{{{
      -- default = "bat",
      border = "noborder",
      wrap = "nowrap",
      hidden = "nohidden",
      vertical = "up:45%",
      horizontal = "right:70%",
      layout = "flex",
      flip_columns = 120,
      title = true,
      scrollbar = "float",
      scrolloff = "-2",
      scrollchars = { "█", "" },

      winopts = { -- Builtin previewer window options {{{
        number = true,
        relativenumber = false,
        cursorline = true,
        cursorlineopt = "both",
        cursorcolumn = false,
        signcolumn = "no",
        list = false,
        foldenable = false,
        foldmethod = "manual",
      }, --}}}
    }, --}}}

    on_create = function() --{{{
      -- pasting from registers.
      vim.keymap.set(
        "t",
        "<C-r>",
        [['<C-\><C-N>"'.nr2char(getchar()).'pi']],
        { buffer = 0, noremap = true, expr = true }
      )
    end, --}}}
  }, --}}}

  keymap = { --{{{
    builtin = { --{{{
      -- `:tmap` mappings
      ["<F1>"] = "toggle-help",
      ["<F2>"] = "toggle-fullscreen",
      ["<F3>"] = "toggle-preview-wrap",
      ["<C-/>"] = "toggle-preview",
      [""] = "toggle-preview",
      ["<F5>"] = "toggle-preview-ccw",
      ["<F6>"] = "toggle-preview-cw",
      ["<M-j>"] = "preview-page-down",
      ["<M-k>"] = "preview-page-up",
      ["<M-left>"] = "preview-page-reset",
    }, --}}}

    fzf = { --{{{
      -- fzf '--bind=' options
      ["esc"] = "abort",
      ["ctrl-d"] = "half-page-down",
      ["ctrl-u"] = "half-page-up",
      ["ctrl-a"] = "beginning-of-line",
      ["ctrl-e"] = "end-of-line",
      ["alt-a"] = "toggle-all",
      ["ctrl-/"] = "ignore",
    }, --}}}
  }, --}}}

  actions = { --{{{
    files = { --{{{
      ["default"] = actions.file_edit_or_qf,
      ["ctrl-s"] = actions.file_split,
      ["ctrl-v"] = actions.file_vsplit,
      ["ctrl-t"] = actions.file_tabedit,
      ["alt-q"] = actions.file_sel_to_qf,
      ["alt-w"] = actions.file_sel_to_ll,
      ["alt-@"] = function(selected)
        local filename = get_filename(selected)
        if not filename then
          return
        end
        vim.cmd.edit(filename)
        if lsp.is_lsp_attached() and lsp.has_lsp_capability("documentSymbolProvider") then
          fzf.lsp_document_symbols({ jump_to_single_result = true })
          actions.ensure_insert_mode()
          return
        end
        vim.cmd.FzfLua("btags")
        actions.ensure_insert_mode()
      end,
      ["alt-:"] = sink_line_number,
      ["alt-/"] = function(selected)
        local filename = get_filename(selected)
        if not filename then
          return
        end
        vim.cmd.edit(filename)
        fzf.blines()
        actions.ensure_insert_mode()
      end,
    }, --}}}

    buffers = { --{{{
      ["default"] = actions.buf_edit,
      ["ctrl-s"] = actions.buf_split,
      ["ctrl-v"] = actions.buf_vsplit,
      ["ctrl-t"] = actions.buf_tabedit,
      ["alt-q"] = actions.buf_sel_to_qf,
      ["alt-w"] = actions.buf_sel_to_ll,
      ["alt-:"] = sink_line_number,
    }, --}}}
  }, --}}}

  fzf_opts = { --{{{
    ["--ansi"] = "",
    ["--prompt"] = "> ",
    ["--info"] = "default",
    ["--height"] = "100%",
    ["--layout"] = "default",
    ["--no-multi"] = false,
  }, --}}}

  previewers = { --{{{
    cat = { --{{{
      cmd = "cat",
      args = "--number",
    }, --}}}
    bat = { --{{{
      cmd = "bat",
      args = "--style=numbers,changes --color always",
      theme = "Monokai Extended Light",
      config = nil,
    }, --}}}
    head = { --{{{
      cmd = "head",
      args = nil,
    }, --}}}
    git_diff = { --{{{
      cmd_deleted = "git diff --color HEAD --",
      cmd_modified = "git diff --color HEAD",
      cmd_untracked = "git diff --color --no-index /dev/null",
    }, --}}}
    man = { --{{{
      cmd = "man %s | col -bx",
    }, --}}}
    builtin = { --{{{
      syntax = true,
      syntax_limit_l = 1024 * 1024, -- syntax limit (lines), 0=nolimit
      syntax_limit_b = 1024 * 1024 * 5, -- syntax limit (bytes), 0=nolimit
      limit_b = 1024 * 1024 * 10, -- preview limit (bytes), 0=nolimit
      extensions = {
        ["jpg"] = { "ueberzug" },
        ["png"] = { "ueberzug" },
      },
      ueberzug_scaler = "contain",
    }, --}}}
  }, --}}}

  files = { --{{{
    prompt = "Files❯ ",
    multiprocess = true,
    git_icons = true,
    file_icons = true,
    color_icons = true,
    find_opts = [[-type f -not -path '*/\.git/*' -printf '%P\n']],
    rg_opts = "--color=never --files --hidden --follow --smart-case  -g '!.git'",
    fd_opts = "--color=never --type f --hidden --follow  --no-ignore" .. fd_exclude,
    actions = {
      ["default"] = actions.file_edit,
    },
    winopts = {
      preview = {
        hidden = "hidden",
        delay = 0,
      },
      height = 0.3,
      width = 1,
      row = 1,
      border = false,
    },
  }, --}}}

  git = { --{{{
    files = { --{{{
      prompt = "Git Files❯ ",
      cmd = "git ls-files --exclude-standard",
      multiprocess = true,
      git_icons = true,
      file_icons = true,
      color_icons = true,
    }, --}}}

    status = { --{{{
      prompt = "Git Status❯ ",
      cmd = "git status -s",
      previewer = "git_diff",
      file_icons = true,
      git_icons = true,
      color_icons = true,
      actions = {
        ["right"] = { actions.git_unstage, actions.resume },
        ["left"] = { actions.git_stage, actions.resume },
      },
    }, --}}}

    commits = { --{{{
      prompt = "Commits❯ ",
      cmd = "git log --pretty=oneline --abbrev-commit --color",
      preview = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
      actions = {
        ["default"] = actions.git_checkout,
      },
    }, --}}}

    bcommits = { --{{{
      prompt = "Buffer Commits❯ ",
      cmd = "git log --pretty=oneline --abbrev-commit --color",
      preview = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
      actions = {
        ["default"] = actions.git_buf_edit,
        ["ctrl-s"] = function(...)
          actions.git_buf_split(...)
          vim.cmd.windo("diffthis")
        end,
        ["ctrl-v"] = function(...)
          actions.git_buf_vsplit(...)
          vim.cmd.windo("diffthis")
        end,
        ["ctrl-t"] = actions.git_buf_tabedit,
      },
    }, --}}}

    branches = { --{{{
      prompt = "Branches❯ ",
      cmd = "git branch --all --color",
      preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
      actions = {
        ["default"] = actions.git_switch,
      },
    }, --}}}

    icons = { --{{{
      ["M"] = { icon = "★", color = "yellow" },
      ["D"] = { icon = "✗", color = "red" },
      ["A"] = { icon = "+", color = "green" },
      ["R"] = { icon = "R", color = "yellow" },
      ["C"] = { icon = "C", color = "yellow" },
      ["?"] = { icon = "?", color = "magenta" },
    }, --}}}
  }, --}}}

  grep = { --{{{
    prompt = "Rg❯ ",
    input_prompt = "Grep For❯ ",
    multiprocess = true,
    git_icons = true,
    file_icons = true,
    color_icons = true,
    grep_opts = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp",
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=512",
    rg_glob = false,
    glob_flag = "--iglob",
    glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
    -- rg_glob_fn = function(opts, query)
    --   ...
    --   return new_query, flags
    -- end,
    actions = {
      ["ctrl-g"] = { actions.grep_lgrep },
    },
    no_header = false,
    no_header_i = false,
  }, --}}}

  args = { --{{{
    prompt = "Args❯ ",
    files_only = true,
    actions = { ["ctrl-x"] = { actions.arg_del, actions.resume } },
    winopts = {
      preview = {
        hidden = "hidden",
        delay = 0,
      },
      height = 0.3,
      width = 1,
      row = 1,
      border = false,
    },
  }, --}}}

  oldfiles = { --{{{
    prompt = "History❯ ",
    cwd_only = false,
    stat_file = true, -- verify files exist on disk
    include_current_session = false, -- include bufs from current session
    winopts = {
      preview = {
        hidden = "hidden",
        delay = 0,
      },
      height = 0.3,
      width = 1,
      row = 1,
      border = false,
    },
  }, --}}}

  buffers = { --{{{
    previewer = "builtin",
    prompt = "Buffers❯ ",
    file_icons = true,
    color_icons = true,
    sort_lastused = true,
    actions = {
      ["ctrl-x"] = { actions.buf_del, actions.resume },
    },
    winopts = {
      preview = {
        hidden = "hidden",
        delay = 0,
      },
      height = 0.3,
      width = 1,
      row = 1,
      border = false,
    },
  }, --}}}

  tabs = { --{{{
    prompt = "Tabs❯ ",
    tab_title = "Tab",
    tab_marker = "<<",
    file_icons = true,
    color_icons = true,
    actions = {
      ["default"] = actions.buf_switch,
      ["ctrl-x"] = { actions.buf_del, actions.resume },
    },
    fzf_opts = {
      -- hide tabnr
      ["--delimiter"] = "'[\\):]'",
      ["--with-nth"] = "2..",
    },
  }, --}}}

  lines = { --{{{
    previewer = "builtin",
    prompt = "Open Buffer Lines❯ ",
    show_unlisted = false, -- exclude 'help' buffers
    no_term_buffers = true,
    fzf_opts = {
      -- do not include bufnr in fuzzy matching
      -- tiebreak by line no.
      ["--delimiter"] = "'[\\]:]'",
      ["--nth"] = "2,4..",
      ["--tiebreak"] = "index",
    },
    winopts = {
      preview = {
        delay = 0,
      },
    },
  }, --}}}

  blines = { --{{{
    previewer = "builtin",
    prompt = "Buffer Lines❯ ",
    show_unlisted = true,
    no_term_buffers = false,
    fzf_opts = {
      -- hide filename, tiebreak by line no.
      ["--delimiter"] = "'[\\]:]'",
      ["--tiebreak"] = "index",
      ["--no-multi"] = false,
    },
    winopts = {
      preview = {
        delay = 0,
      },
    },
  }, --}}}

  tags = { --{{{
    prompt = "Tags❯ ",
    ctags_file = "tags",
    multiprocess = true,
    file_icons = true,
    git_icons = true,
    color_icons = true,
    rg_opts = "--no-heading --color=always --smart-case",
    grep_opts = "--color=auto --perl-regexp",
    actions = {
      ["ctrl-g"] = { actions.grep_lgrep },
    },
    no_header = false,
    no_header_i = false,
  }, --}}}

  btags = { --{{{
    prompt = "BTags❯ ",
    ctags_file = "tags",
    multiprocess = true,
    file_icons = true,
    git_icons = true,
    color_icons = true,
    rg_opts = "--no-heading --color=always",
    grep_opts = "--color=auto --perl-regexp",
    fzf_opts = {
      ["--delimiter"] = "'[\\]:]'",
      ["--with-nth"] = "2..",
      ["--tiebreak"] = "index",
    },
  }, --}}}

  colorschemes = { --{{{
    prompt = "Colorschemes❯ ",
    live_preview = true,
    actions = { ["default"] = actions.colorscheme },
    winopts = { height = 0.55, width = 0.30 },
    post_reset_cb = function()
      require("feline").reset_highlights()
    end,
  }, --}}}

  quickfix = { --{{{
    file_icons = true,
    git_icons = true,
  }, --}}}

  lsp = { --{{{
    prompt_postfix = "❯ ",
    cwd_only = false,
    async_or_timeout = true, -- 5000(ms) or 'true' for async calls
    file_icons = true,
    git_icons = false,
    lsp_icons = true,
    ui_select = true,
    severity = "hint",
    icons = {
      ["Error"] = { icon = "", color = "red" },
      ["Warning"] = { icon = "", color = "yellow" },
      ["Information"] = { icon = "", color = "blue" },
      ["Hint"] = { icon = "", color = "magenta" },
    },
  }, --}}}

  file_icon_padding = "",
  file_icon_colors = {
    ["lua"] = "blue",
  },
})

return {
  config = function(_, mappings)
    if mappings.fzf_builtin then
      vim.keymap.set("n", mappings.fzf_builtin, fzf.builtin)
    end
  end,
}
-- vim: fdm=marker fdl=0
