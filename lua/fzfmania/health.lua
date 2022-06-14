local M = {}
local health = vim.health or require("health")

local libs = {
  arshlib = "arsham/arshlib.nvim",
  listish = "arsham/listish.nvim",
  plenary = "nvim-lua/plenary.nvim",
  ["fzf-lua"] = "ibhagwan/fzf-lua",
}

local executables = {
  git = { "git", "yay -S git" },
  Ripgrep = { "rg", "yay -S rg" },
  FZF = { "fzf", "yay -S fzf" },
  fd = { "fd", "yay -S fd" },
  bat = { "bat", "yay -S bat" },
}

M.check = function()
  health.report_start("FZFMania Health Check")
  for name, package in pairs(libs) do
    if not pcall(require, name) then
      health.report_error(package .. " was not found", {
        'Please install "' .. package .. '"',
      })
    else
      health.report_ok(package .. " is installed")
    end
  end

  for name, aspect in pairs(executables) do
    local ok = vim.fn.executable(aspect[1])
    if ok == 1 then
      health.report_ok(name .. " is installed")
    else
      health.report_error(name .. " is not installed.", aspect[2])
    end
  end
end

return M
