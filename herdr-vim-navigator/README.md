# herdr-vim-navigator

Herdr-side half of Vim-aware pane navigation. It mirrors the tmux side of
`vim-tmux-navigator`: Herdr receives `ctrl+h/j/k/l`, detects whether the focused
pane is Vim/Neovim, and either forwards the key into that pane or moves Herdr
focus.

This plugin does not modify Herdr. It exposes plugin actions that you bind in
`~/.config/herdr/config.toml`.

## Install

From this repository:

```sh
herdr plugin link ./herdr-vim-navigator
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

Override it for unusual wrappers:

```sh
HERDR_VIM_NAVIGATOR_PATTERN='([^"[:space:]]+/)?(nvim|vim|my-vim-wrapper)' herdr
```

Set `HERDR_VIM_NAVIGATOR_PATTERN` in the environment before launching Herdr if
you need a custom pattern.
