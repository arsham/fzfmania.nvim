local M = {}

local libs = {
  arshlib = "arsham/arshlib.nvim",
  listish = "arsham/listish.nvim",
  plenary = "nvim-lua/plenary.nvim",
  ["fzf-lua"] = "ibhagwan/fzf-lua",
}

local executables = {
  git = { "git", "paru -S git" },
  Ripgrep = { "rg", "paru -S rg" },
  fzf = { "fzf", "paru -S fzf" },
  fd = { "fd", "paru -S fd" },
  bat = { "bat", "paru -S bat" },
  viu = { "viu", "paru -S viu" },
}

M.check = function()
  vim.health.start("FZFMania Health Check")
  for name, package in pairs(libs) do
    if not pcall(require, name) then
      vim.health.error(package .. " was not found", {
        'Please install "' .. package .. '"',
      })
    else
      vim.health.ok(package .. " is installed")
    end
  end

  for name, aspect in pairs(executables) do
    local ok = vim.fn.executable(aspect[1])
    if ok == 1 then
      vim.health.ok(name .. " is installed")
    else
      vim.health.error(name .. " is not installed.", aspect[2])
    end
  end
end

return M
