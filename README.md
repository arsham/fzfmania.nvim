# FZF Mania

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/arsham/fzfmania.nvim)
![License](https://img.shields.io/github/license/arsham/fzfmania.nvim)

Powerful **FZF** setup in **Lua** for **Neovim**.

Neovim and FZF are awesome projects, and when they work together they can save
you time by doing complex tasks very quickly.

This setup can be used as a whole, or parts can be disabled selectively or you
can setup up an empty config with the `config_empty` function and enable the
options you want.

1. [Requirements](#requirements)
2. [Installation](#installation)
   - [Lazy](#lazy)
   - [Packer](#packer)
   - [Important Note](#important-note)
   - [Configuration](#configuration)
3. [Mappings](#mappings)
4. [Commands](#commands)
5. [Functions](#functions)
6. [License](#license)

## Requirements

This library supports [Neovim
v0.7.0](https://github.com/neovim/neovim/releases/tag/v0.7.0) or newer.

This library depends are the following libraries. Please make sure to add them
as dependencies in your package manager:

| Project                                                  | Reason for using          |
| :------------------------------------------------------- | :------------------------ |
| [arshlib.nvim](https://github.com/arsham/arshlib.nvim)   | common library            |
| [listish.nvim](https://github.com/arsham/listish.nvim)   | for sinking to lists      |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) |                           |
| [fzf.vim](https://github.com/junegunn/fzf.vim)           |                           |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua)           | (Optional) for better ui  |
| [fd](https://github.com/sharkdp/fd)                      | fast file find            |
| [Ripgrep](https://github.com/BurntSushi/ripgrep)         |                           |
| [bat](https://github.com/sharkdp/bat)                    | colour scheme in previews |

## Installation

Use your favourite package manager to install this library.

### Lazy

```lua
{
  "arsham/fzfmania.nvim",
  dependencies = {
    "arshlib.nvim",
    "fzf.vim",
    "nvim.lua",
    "plenary.nvim",
    -- uncomment if you want a better ui.
    -- {
    --   "ibhagwan/fzf-lua",
    --   dependencies = { "kyazdani42/nvim-web-devicons" },
    -- },
  },
  config = {
    -- frontend = "fzf-lua", -- uncomment if you want a better ui.
  },
  event = { "VeryLazy" },
}
```

### Packer

```lua
use({
  "arsham/fzfmania.nvim",
  requires = {
    "arshlib.nvim",
    "fzf.vim",
    "nvim.lua",
    "plenary.nvim",
    -- uncomment if you want a better ui.
    -- {
    --   "ibhagwan/fzf-lua",
    --   requires = { "kyazdani42/nvim-web-devicons" },
    -- },
  },
  after = { "listish.nvim", "fzf-lua" },
  config = function() require("fzfmania").config({
    -- frontend = "fzf-lua", -- uncomment if you want a better ui.
  }),
  event = { "UIEnter" }, -- best way to lazy load this plugin
})
```

### Important Note

If you are using this plugin, you can't lazy load
[listish.nvim](https://github.com/arsham/listish.nvim) any more. Therefore your
listing setup should not contain any `after`, `keys`, `cmd`, `ft`, or anything
that marks it as an `opt` package.

### Configuration

If you don't pass anything to the `config()` function, it enable everything
with their default. You can change individual settings by providing
replacements, or disable them by setting them to `false`.

```lua
require("fzfmania").config({
  frontend = "fzf-lua", -- uses fzf-lua for handling the ui
  mappings = {
    git_files = false,
    in_files = false,
  },
  commands = false, -- completely disables creating commands
})
```

You may also use this form to only enable a few items. In this setup only in
files search and listing files mappings are set:

```lua
require("fzfmania").config_empty({
  mappings = {
    in_files = "<leader>F", -- use this mapping for me
    files = true, -- use the default mappings
  },
})
```

Note that you also want to set the `fzf_actions`, they will become disabled if
you use the `config_empty` function.

Some mappings can be in form of a string or a table. If you provide a string,
it only creates the map for when you **can't** filter by filenames. If you
provide a table with two values, the first one doesn't filter by filenames,
and the second one will do. In these cases, I have chosen the capitalised
second letter for enabling file names filtering. For example:

```lua
in_files = {
  "<leader>ff", -- doesn't filter filenames as you type
  "<leader>fF", -- filters filenames too as you type.
},
-- or
in_files = "<leader>ff" -- only this version is available.
```

Here is a list of default configurations:

```lua
{
  fzf_history_dir = vim.env.HOME .. "/.local/share/fzf-history",
  frontend = "fzf.vim",                -- set to "fzf-lua" for handling the ui

  mappings = {
    commands = "<leader>:",            -- Show commands
    history  = "<leader>fh",           -- Show history
    files    = "<C-p>",                -- Show files in cwd
    files_location = {                 -- Show files in home or given location
      loc = vim.env.HOME,              -- You can set to any location
      key = "<M-p>",                    -- Alt+p
    },
    buffers            = "<C-b>",      -- Show buffers
    delete_buffers     = "<M-b>",      -- Delete buffers
    git_files          = "<leader>gf", -- Show files in git (git ls-files)
    buffer_lines       = "<C-_>",      -- CTRL-/ grep lines of current buffer
    all_buffer_lines   = "<M-/>",      -- Search in lines of all open buffers
    complete_dict      = "<c-x><c-k>", -- (Inser mode) dict completion
    complete_path      = "<c-x><c-f>", -- (Insert mode) path completion
    complete_line      = "<c-x><c-l>", -- (Insert mode) line completion
    spell_suggestion   = "z=",         -- Show spell suggestions
    in_files           = {             -- if it's a string, only the first mapping is made
      "<leader>ff",                    -- find in files
      "<leader>fF",                    -- find in files with filtering filenames
    },
    in_files_force     = {
      "<leader>fa",                    -- find in files (ignore .gitignore)
      "<leader>fA",                    -- find in files (ignore .gitignore) with filtering filenames
    },
    incremental_search = "<leader>fi", -- Incremental search with rg
    current_word       = {
      "<leader>rg",                    -- search for current word
      "<leader>rG",                    -- search for current word with filtering filenames
    },
    current_word_force = {
      "<leader>ra",                    -- search for current word (ignore .gitignore)
      "<leader>rA",                    -- search for current word (ignore .gitignore) with filtering filenames
    },
    marks              = "<leader>mm", -- Show marks
    tags               = "<leader>@",  -- Show tags
    fzf_builtin        = "<leader>t"   -- Invokes fzf-lua builtin popup
  },

  commands = {
    git_grep     = "GGrep",
    git_tree     = "GTree",
    buffer_lines = "BLines",
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
    jumps        = "Jumps",            -- Choose from the jump list
    autocmds     = "Autocmds",         -- List autocmds
    changes      = "Changes",          -- Choose from change list
    registers    = "Registers",        -- View registers
  },
}
```

## Mappings

Most actions can apply to multiple selected items if possible.

| Mapping            | Description                                            |
| :----------------- | :----------------------------------------------------- |
| `<Ctrl-p>`         | File list in current folder.                           |
| `<Alt-p>`          | File list in home folder.                              |
| `<Ctrl-b>`         | **B**uffer list.                                       |
| `<Alt-b>`          | Delete **b**uffers from the buffer list.               |
| `<Ctrl-/>`         | Search in lines on current buffer.                     |
| `<Alt-/>`          | Search in lines of **all open buffers**.               |
| `<leader>@`        | Search in **ctags** or **LSP** symbols (see below).    |
| `<leader>:`        | Commands                                               |
| `<leader>ff`       | **F**ind in contents of all files in current folder.   |
| `<leader>fa`       | **F**ind **A**ll disabling `.gitignore` handling.      |
| `<leader>fi`       | **I**ncrementally **F**ind.                            |
| `<leader>rg`       | Search (**rg**) with current word.                     |
| `<leader>ra`       | Search (**rg**) disabling `.gitignore` handling.       |
| `<leader>ri`       | **I**ncrementally search (**rg**) with current word.   |
| `<leader>fh`       | **F**ile **H**istory                                   |
| `<leader>gf`       | **GFiles**                                             |
| `<leader>mm`       | **Marks**                                              |
| `<Ctrl-x><Ctrl-k>` | Search in **dictionaries** (requires **words-insane**) |
| `<Ctrl-x><Ctrl-f>` | Search in **f**iles                                    |
| `<Ctrl-x><Ctrl-l>` | Search in **l**ines                                    |
| `<leader>t`        | Invoke fzf-lua builtin popup                           |

If you keep hitting `<Ctrl-/>` the preview window will change width. With
`Shift-/` you can show and hide the preview window.

When a file is selected, additional to what **fzf** provides out of the box,
you can invoke one of these secondary actions:

| Mapping | Description                        |
| :------ | :--------------------------------- |
| `alt-/` | To search in the lines.            |
| `alt-@` | To search in ctags or lsp symbols. |
| `alt-:` | To go to a specific line.          |
| `alt-q` | Add items to the quickfix list.    |
| `alt-w` | Add items to the local list.       |

Note that if a `LSP` server is not attached to the buffer, it will fall back to
`ctags`.

Sometimes when you list files and `sink` with **@**, the `LSP` might not be
ready yet, therefore it falls back to `ctags` immediately. In this case you can
cancel, which will land you to the file, and you can invoke `<leader>@` for
**LSP** symbols.

## Commands

| Command       | Description                                |
| :------------ | :----------------------------------------- |
| `GGrep`       | Run **git grep**                           |
| `GTree`       | Browse **git** commits                     |
| `Marks`       | Show **marks** with preview                |
| `MarksDelete` | Delete **marks**                           |
| `Todo`        | List **todo**/**fixme** lines              |
| `ArgsAdd`     | Select and add files to the args list      |
| `ArgsDelete`  | Select and delete files from the args list |
| `Worktree`    | Switch between git worktrees               |
| `BLines`      | Search in current buffer                   |
| `History`     | Show open file history                     |
| `Checkout`    | Checkout a branch                          |
| `GitStatus`   | Show git status                            |
| `Jumps`       | Choose from jump list                      |
| `Autocmds`    | Show autocmds                              |
| `Changes`     | Show change list                           |
| `Registers`   | Show register contents                     |

## Functions

These functions can be imported from the `fzfmania.util` module.

| Function                     | Notes                                                              |
| :--------------------------- | :----------------------------------------------------------------- |
| `ripgrep_search`             | Ripgrep search                                                     |
| `ripgrep_search_incremental` | Incremental Ripgrep search with fzf                                |
| `delete_buffer`              | Shows all opened buffers and let you delete them                   |
| `lines_grep`                 | Incremental searches in the lines of current buffer                |
| `open_config`                | Open one of your Neovim config files                               |
| `marks`                      | Show marks with preview                                            |
| `delete_marks`               | Show marks for deletion                                            |
| `git_grep`                   | Two phase search in all git commits                                |
| `checkout_branch`            | Checkout a branch                                                  |
| `open_todo`                  | Search for all todo/fixme/etc.                                     |
| `add_args`                   | Find and add files to the args list                                |
| `delete_args`                | Choose and remove files from the args list                         |
| `insert_into_list`           | (`Action`) Populate quickfix/local lists with search results       |
| `goto_def`                   | (`Action`) Go to definition. In absence of LSP falls back to BTags |

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

<!--
vim: foldlevel=1 conceallevel=0
-->
