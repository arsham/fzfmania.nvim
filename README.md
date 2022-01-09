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
   - [Important Note](#important-note)
   - [Configuration](#configuration)
3. [Mappings](#mappings)
4. [Commands](#commands)
5. [Functions](#functions)
6. [License](#license)

## Requirements

At the moment it works on the development release of Neovim, and will be
officially supporting [Neovim 0.7.0](https://github.com/neovim/neovim/releases/tag/v0.7.0).

This library depends are the following libraries. Please make sure to add them
as dependencies in your package manager:

| Project                                                  | Reason for using          |
| :------------------------------------------------------- | :------------------------ |
| [arshlib.nvim](https://github.com/arsham/arshlib.nvim)   | common library            |
| [listish.nvim](https://github.com/arsham/listish.nvim)   | for sinking to lists      |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) |                           |
| [nvim.lua](https://github.com/norcalli/nvim.lua)         |                           |
| [fd](https://github.com/sharkdp/fd)                      | fast file find            |
| [Ripgrep](https://github.com/BurntSushi/ripgrep)         |                           |
| [bat](https://github.com/sharkdp/bat)                    | colour scheme in previews |

## Installation

Use your favourite package manager to install this library. Packer example:

```lua
use({
  "arsham/fzfmania.nvim",
  requires = { "arshlib.nvim", "listish.nvim", "nvim.lua", "plenary.nvim" },
  config = function() require("fzfmania").config({})
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
  mappings = {
    git_files = false,
    in_files = false,
  },
  commands = false,                    -- completely disables creating commands
})
```

You may also use this form to only enable a few items. In this setup only in
files search and listing files mappings are set:

```lua
require("fzfmania").config_empty({
  mappings = {
    in_files = "<leader>F",            -- use this mapping for me
    files = true,                      -- use the default mappings
  },
})
```

Note that you also want to set the `fzf_actions`, they will become disabled if
you use the `config_empty` function.

Here is a list of default configurations:

```lua
{
  fzf_history_dir = vim.env.HOME .. "/.local/share/fzf-history",

  mappings = {
    commands = "<leader>:",            -- Show commands
    history  = "<leader>fh",           -- Show history
    files    = "<C-p>",                -- Show files in cwd
    files_location = {                 -- Show files in home or given location
      loc = vim.env.HOME,              -- You can set to any location
      key = "<M-p",                    -- Alt+p
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
    in_files           = "<leader>ff", -- Find in files
    in_files_force     = "<leader>fa", -- Find in files (ignore .gitignore)
    incremental_search = "<leader>fi", -- Incremental search with rg
    current_word       = "<leader>rg", -- Search for current word
    current_work_force = "<leader>ra", -- Search for current word (ignore .gitignore)
    marks              = "<leader>mm", -- Show marks
    tags               = "<leader>@",  -- Show tags
  },

  commands = {
    git_grep     = "GGrep",
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
| `<leader>fl`       | **F**ile **l**ocate (requires mlocate)                 |
| `<leader>gf`       | **GFiles**                                             |
| `<leader>mm`       | **Marks**                                              |
| `<Ctrl-x><Ctrl-k>` | Search in **dictionaries** (requires **words-insane**) |
| `<Ctrl-x><Ctrl-f>` | Search in **f**iles                                    |
| `<Ctrl-x><Ctrl-l>` | Search in **l**ines                                    |

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
| `Marks`       | Show marks with preview                    |
| `MarksDelete` | Delete marks                               |
| `Todo`        | List **todo**/**fixme** lines              |
| `ArgAdd`      | Select and add files to the args list      |
| `ArgDelete`   | Select and delete files from the args list |
| `Worktree`    | Switch between git worktrees               |
| `Reload`      | Reload one or more lua config files        |

## Functions

These functions can be imported from the `fzfmania.util` module.

| Function                     | Notes                                                              |
| :--------------------------- | :----------------------------------------------------------------- |
| `ripgrep_search`             | Ripgrep search                                                     |
| `ripgrep_search_incremental` | Incremental Ripgrep search with fzf                                |
| `delete_buffer`              | Shows all opened buffers and let you delete them                   |
| `lines_grep`                 | Incremental searches in the lines of current buffer                |
| `reload_config`              | Reloads config files                                               |
| `open_config`                | Open one of your Neovim config files                               |
| `marks`                      | Show marks with preview                                            |
| `delete_marks`               | Show marks for deletion                                            |
| `git_grep`                   | Two phase search in all git commits                                |
| `checkout_branck`            | Checkout a branch                                                  |
| `open_todo`                  | Search for all todo/fixme/etc.                                     |
| `add_args`                   | Find and add files to the args list                                |
| `delete_args`                | Choose and remove files from the args list                         |
| `insert_into_list`           | (`Action`) Populate quickfix/local lists with search results       |
| `goto_def`                   | (`Action`) Go to definition. In absence of LSP falls back to BTags |

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

<!--
vim: foldlevel=1
-->
