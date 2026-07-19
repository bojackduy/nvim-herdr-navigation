# herdr-vim-navigator

Herdr-side plugin for seamless `ctrl+h/j/k/l` navigation between Herdr panes and
Vim or Neovim splits. It mirrors the tmux side of `vim-tmux-navigator`: Herdr
receives the key, detects whether the focused pane is Vim or Neovim, and either
forwards the key into that pane or moves Herdr focus.

Pair this with the Neovim plugin in `../nvim-herdr-navigation`.

## Install

Install directly from GitHub:

```sh
herdr plugin install bojackduy/nvim-herdr-navigation/herdr-vim-navigator
```

Or link a local clone:

```sh
git clone https://github.com/bojackduy/nvim-herdr-navigation.git ~/.local/share/nvim-herdr-navigation
herdr plugin link ~/.local/share/nvim-herdr-navigation/herdr-vim-navigator
```

Verify installation:

```sh
herdr plugin list
```

## Configure Herdr

Disable Herdr's built-in direct pane focus bindings so the plugin actions can own
those keys:

```toml
[keys]
focus_pane_left = ""
focus_pane_down = ""
focus_pane_up = ""
focus_pane_right = ""
```

Bind the same keys to plugin actions:

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

Reload Herdr after editing config:

```sh
herdr server reload-config
```

## Detection

The default process-name pattern is based on `vim-tmux-navigator`:

```text
([^"[:space:]]+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?
```

Override it before launching Herdr if you use unusual Vim or Neovim wrappers:

```sh
HERDR_VIM_NAVIGATOR_PATTERN='([^"[:space:]]+/)?(nvim|vim|my-vim-wrapper)' herdr
```

## Keywords

Herdr Vim navigator, Herdr Neovim navigation, vim-tmux-navigator for Herdr,
Ctrl h j k l pane navigation, Herdr plugin action navigation.
