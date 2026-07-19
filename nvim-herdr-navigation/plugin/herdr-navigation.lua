if vim.g.loaded_herdr_navigation == 1 then
  return
end

vim.g.loaded_herdr_navigation = 1
require("herdr-navigation").setup()
