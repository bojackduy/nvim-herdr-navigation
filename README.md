# nvim-herdr-navigation: Herdr Neovim Navigator

Seamless `ctrl+h/j/k/l` navigation between Herdr panes and Neovim splits.

`nvim-herdr-navigation` is a `vim-tmux-navigator` style workflow for the
[Herdr](https://github.com/ogulcancelik/herdr) terminal workspace manager and
Neovim. Use one set of Vim keys to move across Neovim windows first, then Herdr
panes when you reach the edge.

```text
ctrl+h  move left
ctrl+j  move down
ctrl+k  move up
ctrl+l  move right
```

## Why Use This

Use this plugin if you searched for any of these:

- Herdr Neovim navigation
- vim-tmux-navigator for Herdr
- Neovim split navigation with Herdr panes
- Ctrl-h Ctrl-j Ctrl-k Ctrl-l pane navigation
- LazyVim Herdr navigation mappings
- terminal multiplexer navigation for Neovim

The goal is simple: make Neovim splits and Herdr panes feel like one navigation
surface.

## What Is Included

This repository contains two plugins that work together:

- `herdr-vim-navigator/`: Herdr plugin actions for `ctrl+h/j/k/l`. Herdr receives
  the key first, detects Vim or Neovim panes, and either forwards the key into
  Neovim or moves Herdr pane focus directly.
- `nvim-herdr-navigation/`: Neovim plugin. Neovim tries normal split navigation
  first. If focus is already at the requested split edge, it calls Herdr to move
  to the neighboring pane.

The `herdr/` and `nvim-tmux-navigation/` directories are reference submodules.
They are not required at runtime and are not modified by this project.

## Requirements

- Herdr `0.7.0` or newer
- Neovim `0.8` or newer
- `herdr` available on `$PATH` inside Neovim
- A plugin manager such as `lazy.nvim` for the Neovim side

## Download and Install

### 1. Install the Herdr Plugin

Install directly from GitHub:

```sh
herdr plugin install bojackduy/nvim-herdr-navigation/herdr-vim-navigator
```

Or clone the repository and link it locally:

```sh
git clone https://github.com/bojackduy/nvim-herdr-navigation.git ~/.local/share/nvim-herdr-navigation
herdr plugin link ~/.local/share/nvim-herdr-navigation/herdr-vim-navigator
```

Verify the plugin is installed:

```sh
herdr plugin list
```

### 2. Configure Herdr Keybindings

Edit `~/.config/herdr/config.toml`.

Disable Herdr's built-in direct pane focus bindings. This is required because
the Vim-aware plugin must receive `ctrl+h/j/k/l` first:

```toml
[keys]
focus_pane_left = ""
focus_pane_down = ""
focus_pane_up = ""
focus_pane_right = ""
```

Bind the same keys to the Herdr plugin actions:

```toml
[[keys.command]]
key = "ctrl+h"
type = "plugin_action"
command = "local.vim-navigator.left"
description = "Vim-aware pane left"

[[keys.command]]
key = "ctrl+j"
type = "plugin_action"
command = "local.vim-navigator.down"
description = "Vim-aware pane down"

[[keys.command]]
key = "ctrl+k"
type = "plugin_action"
command = "local.vim-navigator.up"
description = "Vim-aware pane up"

[[keys.command]]
key = "ctrl+l"
type = "plugin_action"
command = "local.vim-navigator.right"
description = "Vim-aware pane right"
```

Reload Herdr:

```sh
herdr server reload-config
```

### 3. Install the Neovim Plugin with lazy.nvim

Add this to your lazy.nvim plugin specs:

```lua
return {
  "bojackduy/nvim-herdr-navigation",
  submodules = false,
  cond = function()
    return vim.env.HERDR_PANE_ID ~= nil
  end,
  event = "VeryLazy",
  init = function(plugin)
    vim.opt.rtp:prepend(plugin.dir .. "/nvim-herdr-navigation")
  end,
  config = function()
    vim.schedule(function()
      require("herdr-navigation").setup({
        keybindings = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
        },
      })
    end)
  end,
}
```

Why this spec matters:

- `submodules = false` avoids cloning the reference submodules, which are not
  needed by the plugin.
- `init` adds the nested `nvim-herdr-navigation/` plugin directory to Neovim's
  runtime path.
- `event = "VeryLazy"` plus `vim.schedule()` lets these mappings override
  LazyVim's default `<C-h/j/k/l>` window mappings inside Herdr.
- `cond` keeps the plugin inactive outside Herdr.

### 4. Keep vim-tmux-navigator Outside Herdr

If you use `christoomey/vim-tmux-navigator`, keep it disabled inside Herdr so it
does not own the same keys:

```lua
return {
  "christoomey/vim-tmux-navigator",
  cond = function()
    return vim.env.HERDR_PANE_ID == nil
  end,
}
```

## Test It

Start Herdr, open a pane running Neovim, and create a few Neovim splits:

```vim
:vsplit
:split
```

Expected behavior:

- In Neovim, `ctrl+h/j/k/l` moves between Neovim splits first.
- At a Neovim split edge, the same key moves to the neighboring Herdr pane.
- In a shell, agent, or non-Neovim pane, the same key moves Herdr pane focus.
- Outside Herdr, your existing tmux navigator or normal Neovim mappings can keep
  working.

## How It Works

This follows the two-sided design popularized by `vim-tmux-navigator`:

1. Herdr receives `ctrl+h/j/k/l` first.
2. The Herdr plugin checks whether the focused pane is running Vim or Neovim.
3. If the focused pane is not Vim or Neovim, Herdr moves pane focus directly.
4. If the focused pane is Vim or Neovim, Herdr forwards the original key into the pane.
5. The Neovim plugin runs `wincmd h/j/k/l`.
6. If Neovim focus did not change, the plugin runs `herdr pane focus --direction ... --pane $HERDR_PANE_ID`.

## Neovim Commands

The plugin creates these commands:

```vim
:HerdrNavigateLeft
:HerdrNavigateDown
:HerdrNavigateUp
:HerdrNavigateRight
```

Optional compatibility aliases are available if you are replacing existing
`vim-tmux-navigator` command mappings:

```lua
require("herdr-navigation").setup({
  tmux_compat_commands = true,
})
```

That creates:

```vim
:TmuxNavigateLeft
:TmuxNavigateDown
:TmuxNavigateUp
:TmuxNavigateRight
```

## Troubleshooting

### Lazy.nvim Fails Cloning Submodules

Use `submodules = false` in the lazy.nvim spec. The repository includes reference
submodules for development, but the Neovim plugin does not need them.

### Herdr Moves Into Neovim, But Neovim Cannot Move Back to Herdr

Check the live Neovim mapping:

```vim
:lua print(vim.inspect(vim.fn.maparg("<C-l>", "n", false, true)))
```

The mapping should say `desc = "Herdr navigate right"` and should have a Lua
callback. If it says `Go to Right Window` or maps to `<C-w>l`, another config is
overriding the plugin. Use the lazy.nvim spec above with `event = "VeryLazy"` and
`vim.schedule()`.

### ctrl+h/j/k/l Always Moves Herdr Panes and Never Neovim Splits

Herdr's built-in `focus_pane_*` keybindings are still active. Set them to empty
strings in `~/.config/herdr/config.toml`, then run:

```sh
herdr server reload-config
```

### ctrl+h/j/k/l Works in Neovim Splits But Does Nothing at the Edge

Confirm Neovim has the Herdr pane id:

```vim
:lua print(vim.env.HERDR_PANE_ID)
```

Confirm Neovim can find Herdr:

```vim
:lua print(vim.fn.executable("herdr"))
```

Confirm the Herdr command works for the current pane:

```vim
:lua vim.fn.jobstart({ "herdr", "pane", "focus", "--direction", "right", "--pane", vim.env.HERDR_PANE_ID }, { detach = true })
```

### Herdr Does Not Detect Your Neovim Wrapper

The Herdr-side plugin uses a Vim process-name pattern based on
`vim-tmux-navigator`. Override it before launching Herdr if you use a custom
wrapper:

```sh
HERDR_VIM_NAVIGATOR_PATTERN='([^"[:space:]]+/)?(nvim|vim|my-vim-wrapper)' herdr
```

## Related Tools

- `vim-tmux-navigator`: the tmux and Vim workflow this project is inspired by.
- `nvim-tmux-navigation`: a Neovim-focused tmux navigation plugin used here as a
  reference.
- Herdr: the terminal workspace and pane manager this plugin targets.

## Search Keywords

Herdr Neovim navigation, nvim Herdr navigator, vim tmux navigator Herdr,
vim-tmux-navigator alternative, Neovim pane navigation, Neovim split navigation,
LazyVim Ctrl h j k l, Herdr plugin, terminal multiplexer navigation, Herdr pane
focus from Neovim.
