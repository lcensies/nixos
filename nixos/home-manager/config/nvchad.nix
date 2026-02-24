# NvChad via nix4nvchad, declaratively managed.
# Keybinds from dotfiles injected via extraConfig; no programs.neovim.
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  # UI: minimal statusline, transparency (from dotfiles chadrc)
  # Keybinds are set in extraConfig below, not via custom.mappings.
  chadrcConfig = ''
    local M = {}
    M.ui = {
      statusline = { theme = "minimal" },
      transparency = true,
    }
    M.plugins = "custom.plugins"
    return M
  '';

  # Keybinds extracted from dotfiles/config/nvim/lua/custom/mappings.lua
  # Set via vim.keymap.set so we don't depend on dotfiles on disk.
  extraConfig = ''
    -- Disabled default keymaps (from mappings.disabled)
    local disabled_n = { "<S-k>", "<leader>ra", "<leader>q", "<leader>ma", "<C-h>", "<C-l>", "<C-j>", "<C-k>", "<C-x>", "<A-h>", "<A-v>", "<leader>th", "<leader>n" }
    for _, key in ipairs(disabled_n) do
      pcall(vim.keymap.del, "n", key)
    end
    pcall(vim.keymap.del, "v", "J")
    pcall(vim.keymap.del, "v", "K")

    -- Splits
    vim.keymap.set("n", "<leader>sc", "<cmd> split <CR>", { desc = "Split horizontal" })
    vim.keymap.set("n", "<leader>sv", "<cmd> vsplit <CR>", { desc = "Split vertical" })

    -- Yanks
    vim.keymap.set("n", "<leader>yf", "<cmd> :let @+=expand('%:t')<CR>", { desc = "Yank current filename" })
    vim.keymap.set("n", "<leader>ya", '[["+y]]', { desc = "Yank all content" })

    -- Motions
    vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert with Ctrl+c" })
    vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
    vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
    vim.keymap.set("v", "H", "^", { desc = "Line start" })
    vim.keymap.set("v", "L", "$", { desc = "Line end" })
    vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down and center" })
    vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up and center" })
    vim.keymap.set("n", "H", "^", { desc = "Line start" })
    vim.keymap.set("n", "L", "$", { desc = "Line end" })

    -- Nvterm (default NvChad)
    vim.keymap.set("n", "<leader>th", function() require("nvterm.terminal").toggle "horizontal" end, { desc = "Toggle horizontal term" })
    vim.keymap.set("n", "<leader>tv", function() require("nvterm.terminal").toggle "vertical" end, { desc = "Toggle vertical term" })

    -- Telescope
    vim.keymap.set("n", "<leader>fm", "<cmd> Telescope harpoon marks <CR>", { desc = "Find Harpoon marks" })
    vim.keymap.set("v", "<leader>fs", "<cmd> lua require'telescope.builtin'.grep_string({search = vim.fn.expand('<cword>')}) <CR>", { desc = "Find selection" })

    -- Harpoon
    vim.keymap.set("n", "<leader>a", '<cmd> lua require("harpoon.mark").add_file() <CR>', { desc = "Harpoon add file" })
    vim.keymap.set("n", "<leader>fr", '<cmd> lua require("harpoon.ui").toggle_quick_menu() <CR>', { desc = "Harpoon toggle menu" })

    -- Crates
    vim.keymap.set("n", "<leader>rcu", function() require("crates").upgrade_all_crates() end, { desc = "Update crates" })

    -- Trouble
    vim.keymap.set("n", "<leader>T", function() require("trouble").toggle "document_diagnostics" end, { desc = "Trouble document diagnostics" })

    -- Git worktree
    vim.keymap.set("n", "<leader>gwa", "<cmd> lua require('telescope').extensions.git_worktree.create_git_worktree() <CR>", { desc = "Git worktree add" })
    vim.keymap.set("n", "<leader>gws", "<cmd> lua require('telescope').extensions.git_worktree.git_worktrees() <CR>", { desc = "Git worktree switch" })

    -- Obsidian
    vim.keymap.set("n", "<leader>gl", "<cmd> ObsidianToday <CR>", { desc = "Obsidian Daily Note" })
  '';

  # Plugins required by the keybinds above
  extraPlugins = ''
    return {
      { "ThePrimeagen/harpoon", dependencies = "nvim-lua/plenary.nvim", config = function() end },
      { "folke/trouble.nvim", dependencies = "nvim-tree/nvim-web-devicons", opts = {} },
      { "saecki/crates.nvim", ft = "toml", config = function(_, opts) require("crates").setup(opts) end },
      {
        "ThePrimeagen/git-worktree.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
        config = function()
          require("telescope").load_extension "git_worktree"
        end,
      },
      {
        "epwalsh/obsidian.nvim",
        ft = "markdown",
        opts = { workspaces = { { name = "notes", path = "~/notes" } } },
      },
    }
  '';
in
{
  imports = [ inputs.nix4nvchad.homeManagerModule ];

  programs.nvchad = {
    enable = true;
    backup = false;
    hm-activation = true;

    chadrcConfig = chadrcConfig;
    extraConfig = extraConfig;
    extraPlugins = extraPlugins;

    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      nixd
      (python3.withPackages (ps: with ps; [ python-lsp-server ]))
    ];
  };
}
