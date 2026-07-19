# nvim-herdr-navigation

Neovim-side half of Vim-aware Herdr pane navigation. It mirrors the Vim side of
`vim-tmux-navigator`: try Neovim window navigation first, then call Herdr when
the cursor is already at the edge of the Neovim split layout.

Pair this with the Herdr plugin in `../herdr-vim-navigator`.

## Install with lazy.nvim

```lua
{
  dir = "/path/to/nvim-herdr-navigation",
  config = function()
    require("herdr-navigation").setup({
      keybindings = {
        left = "<C-h>",
        down = "<C-j>",
        up = "<C-k>",
        right = "<C-l>",
      },
    })
  end,
}
```

If you want command names compatible with existing `vim-tmux-navigator` mappings,
enable aliases after removing the tmux plugin to avoid command conflicts:

```lua
require("herdr-navigation").setup({
  tmux_compat_commands = true,
})
```

## Commands

```vim
:HerdrNavigateLeft
:HerdrNavigateDown
:HerdrNavigateUp
:HerdrNavigateRight
```

Optional compatibility commands:

```vim
:TmuxNavigateLeft
:TmuxNavigateDown
:TmuxNavigateUp
:TmuxNavigateRight
```

## Behavior

- If Neovim can move to a split in the requested direction, it does.
- If Neovim focus does not change and `$HERDR_PANE_ID` is present, it runs
  `herdr pane focus --direction ... --pane $HERDR_PANE_ID` asynchronously.
- Outside Herdr, it behaves like normal Neovim split navigation only.
