# nvim-herdr-navigation

Neovim-side plugin for seamless `ctrl+h/j/k/l` navigation between Neovim splits
and Herdr panes. It is the Neovim half of a `vim-tmux-navigator` style workflow
for Herdr.

Pair this with the Herdr plugin in `../herdr-vim-navigator`.

## Install with lazy.nvim

Because the Neovim plugin lives in a subdirectory of the GitHub repository, add
the nested directory to runtime path in `init`:

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

Use `event = "VeryLazy"` and `vim.schedule()` if you use LazyVim or another
distribution that sets default `<C-h/j/k/l>` window mappings after plugin specs.

## Commands

```vim
:HerdrNavigateLeft
:HerdrNavigateDown
:HerdrNavigateUp
:HerdrNavigateRight
```

Optional compatibility commands:

```lua
require("herdr-navigation").setup({
  tmux_compat_commands = true,
})
```

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
- Outside Herdr, the recommended lazy.nvim spec does not load this plugin.

## Troubleshooting

If Neovim moves between splits but never moves back to Herdr at the edge, check
the active mapping:

```vim
:lua print(vim.inspect(vim.fn.maparg("<C-l>", "n", false, true)))
```

The mapping should have `desc = "Herdr navigate right"`. If it maps to `<C-w>l`,
another keymap is overriding this plugin.
