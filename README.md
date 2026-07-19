# nvim-herdr-navigation

Vim-aware navigation between Herdr panes and Neovim splits, inspired by
`vim-tmux-navigator`.

This repository contains two plugins side-by-side:

- `herdr-vim-navigator/` — Herdr plugin actions for `ctrl+h/j/k/l`. Herdr runs
  these first, detects Vim/Neovim, and either forwards the key into the pane or
  moves Herdr focus.
- `nvim-herdr-navigation/` — Neovim plugin. Neovim tries split navigation first;
  when already at an edge, it calls Herdr to focus the neighboring pane.

The `herdr/` and `nvim-tmux-navigation/` directories are reference submodules and
are not modified by these plugins.

See each plugin's README for setup details.
