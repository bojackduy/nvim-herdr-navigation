local M = {}

local config = {
  herdr_bin = nil,
  keybindings = {},
  tmux_compat_commands = false,
}

local commands_created = false
local tmux_commands_created = false

local directions = {
  left = { wincmd = "h", herdr = "left" },
  down = { wincmd = "j", herdr = "down" },
  up = { wincmd = "k", herdr = "up" },
  right = { wincmd = "l", herdr = "right" },
}

local function herdr_bin()
  return config.herdr_bin or vim.env.HERDR_BIN_PATH or "herdr"
end

local function command_exists(name)
  return vim.fn.exists(":" .. name) == 2
end

local function create_command(name, direction)
  if command_exists(name) then
    return
  end
  vim.api.nvim_create_user_command(name, function()
    M.navigate(direction)
  end, {})
end

local function create_commands()
  if not commands_created then
    create_command("HerdrNavigateLeft", "left")
    create_command("HerdrNavigateDown", "down")
    create_command("HerdrNavigateUp", "up")
    create_command("HerdrNavigateRight", "right")
    commands_created = true
  end

  if config.tmux_compat_commands and not tmux_commands_created then
    create_command("TmuxNavigateLeft", "left")
    create_command("TmuxNavigateDown", "down")
    create_command("TmuxNavigateUp", "up")
    create_command("TmuxNavigateRight", "right")
    tmux_commands_created = true
  end
end

local function focus_herdr(direction)
  local pane_id = vim.env.HERDR_PANE_ID
  if pane_id == nil or pane_id == "" then
    return false
  end

  local bin = herdr_bin()
  if vim.fn.executable(bin) ~= 1 then
    return false
  end

  local job = vim.fn.jobstart({
    bin,
    "pane",
    "focus",
    "--direction",
    direction,
    "--pane",
    pane_id,
  }, { detach = true })

  return job > 0
end

function M.navigate(direction_name)
  local direction = directions[direction_name]
  if direction == nil then
    return false
  end

  local before = vim.api.nvim_get_current_win()
  local ok = pcall(vim.cmd, "wincmd " .. direction.wincmd)
  if not ok then
    return false
  end

  if vim.api.nvim_get_current_win() ~= before then
    return true
  end

  return focus_herdr(direction.herdr)
end

function M.left()
  return M.navigate("left")
end

function M.down()
  return M.navigate("down")
end

function M.up()
  return M.navigate("up")
end

function M.right()
  return M.navigate("right")
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  create_commands()

  for direction, lhs in pairs(config.keybindings or {}) do
    if directions[direction] ~= nil and lhs ~= nil and lhs ~= "" then
      vim.keymap.set("n", lhs, function()
        M.navigate(direction)
      end, { silent = true, desc = "Herdr navigate " .. direction })
    end
  end
end

return M
