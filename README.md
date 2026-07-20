# Herdr Neovim Navigator (nvim-herdr-navigation)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

`nvim-herdr-navigation` is a `vim-tmux-navigator` alternative for Herdr: seamless
`ctrl+h/j/k/l` navigation between Neovim splits and Herdr panes.

Use the same Vim navigation keys everywhere. Move across Neovim windows first;
when you reach a split edge, jump to the neighboring Herdr pane.

```text
ctrl+h  move left
ctrl+j  move down
ctrl+k  move up
ctrl+l  move right
```

## Demo

![Herdr Neovim navigation demo](assets/demo.gif)

Prefer terminal playback? Use the asciinema recording:

```sh
asciinema play assets/demo.cast
```

## Install Herdr Neovim Navigation

This project has two parts. Install both for full Neovim split and Herdr pane
navigation.

### 1. Install the Herdr Plugin

```sh
herdr plugin install bojackduy/nvim-herdr-navigation/herdr-vim-navigator
```

Verify Herdr can see the plugin:

```sh
herdr plugin list
```

### 2. Configure Herdr ctrl+h/j/k/l Keybindings

Edit `~/.config/herdr/config.toml`.

Disable Herdr's built-in direct pane focus bindings. The Vim-aware plugin must
receive these keys first:

```toml
[keys]
focus_pane_left = ""
focus_pane_down = ""
focus_pane_up = ""
focus_pane_right = ""
```

Bind `ctrl+h/j/k/l` to the Herdr plugin actions:

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

Add this lazy.nvim spec:

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

Important details for lazy.nvim and LazyVim users:

- `submodules = false` prevents lazy.nvim from cloning development-only reference
  submodules.
- `init` adds the nested Neovim plugin directory to the runtime path.
- `event = "VeryLazy"` plus `vim.schedule()` lets this plugin override LazyVim's
  default `<C-h/j/k/l>` window mappings inside Herdr.
- `cond` keeps this Neovim plugin disabled outside Herdr.

### 4. Keep vim-tmux-navigator Outside Herdr

If you already use `christoomey/vim-tmux-navigator`, keep it active outside Herdr
and disabled inside Herdr:

```lua
return {
  "christoomey/vim-tmux-navigator",
  cond = function()
    return vim.env.HERDR_PANE_ID == nil
  end,
}
```

## Features

- `vim-tmux-navigator` style navigation for Herdr and Neovim.
- One set of `ctrl+h/j/k/l` keys for Neovim splits and Herdr panes.
- Neovim-first behavior: move between splits before falling back to Herdr.
- Herdr-aware behavior: shell, agent, and non-Neovim panes move directly through Herdr.
- LazyVim-compatible mapping setup for default `<C-h/j/k/l>` window keymaps.
- Works alongside tmux navigation by loading `vim-tmux-navigator` only outside Herdr.
- No Herdr core patches required.

## When to Use This Plugin

Use `nvim-herdr-navigation` if you want:

- Herdr pane navigation from Neovim.
- Neovim split navigation that falls back to Herdr at split edges.
- A Herdr equivalent of `vim-tmux-navigator`.
- LazyVim `ctrl+h/j/k/l` navigation that works across Herdr panes.
- A terminal multiplexer navigation workflow for Herdr, Vim, and Neovim.

## Repository Layout

This repository contains two plugins that work together:

- `herdr-vim-navigator/`: Herdr plugin actions for `ctrl+h/j/k/l`. Herdr receives
  the key first, detects Vim or Neovim panes, and either forwards the key into
  Neovim or moves Herdr pane focus directly.
- `nvim-herdr-navigation/`: Neovim plugin. Neovim tries normal split navigation
  first. If focus is already at the requested split edge, it calls Herdr to move
  to the neighboring pane.

The `herdr/` and `nvim-tmux-navigation/` directories are reference submodules.
They are not required at runtime.

## Requirements

- Herdr `0.7.0` or newer
- Neovim `0.8` or newer
- `herdr` available on `$PATH` inside Neovim
- `lazy.nvim` or another Neovim plugin manager

## Test Neovim Split and Herdr Pane Navigation

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

## How Herdr Neovim Navigation Works

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

## Troubleshooting Herdr and Neovim Navigation

### lazy.nvim Fails Cloning Submodules

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

## FAQ

### Is this vim-tmux-navigator for Herdr?

Yes. `nvim-herdr-navigation` provides the same style of pane-aware Vim navigation
for Herdr that `vim-tmux-navigator` provides for tmux.

### How do I move from a Neovim split to a Herdr pane?

Press `ctrl+h/j/k/l` at the edge of the Neovim split layout. The Neovim plugin
detects that focus did not move inside Neovim and asks Herdr to focus the
neighboring pane.

### Does this work with LazyVim?

Yes. Use the lazy.nvim spec in this README. The `VeryLazy` event and
`vim.schedule()` are included so the Herdr mappings win over LazyVim's default
window-navigation mappings.

### Can I keep using vim-tmux-navigator?

Yes. Keep `vim-tmux-navigator` enabled outside Herdr and disabled inside Herdr
with `cond = function() return vim.env.HERDR_PANE_ID == nil end`.

### Does this work outside Herdr?

The recommended lazy.nvim spec only loads the Neovim plugin when
`HERDR_PANE_ID` exists. Outside Herdr, keep using your existing Neovim or tmux
navigation setup.

## Related Tools

- `vim-tmux-navigator`: the tmux and Vim workflow this project is inspired by.
- `nvim-tmux-navigation`: a Neovim-focused tmux navigation plugin used here as a
  reference.
- Herdr: the terminal workspace and pane manager this plugin targets.

## License

MIT. See [LICENSE](LICENSE).

## Discoverability

This project is relevant for searches such as Herdr Neovim navigation,
Herdr Neovim navigator, vim-tmux-navigator for Herdr, Neovim split navigation,
Herdr pane navigation, LazyVim ctrl h j k l, terminal multiplexer navigation,
and Neovim pane focus from Herdr.
