{ pkgs, ... }:
{
  # git
  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.extraConfig = {
    init.defaultBranch = "main";
    # safe.directory = [];
  };

  # difftastic
  # TODO: difftastic + magit (emacs)
  programs.git.difftastic.enable = true;

  # gitui
  programs.gitui.enable = true;
  programs.gitui.catppuccin.enable = true;
  
  programs.lazygit.enable = true;

  # gh
  programs.gh.enable = true;
  programs.gh.extensions = with pkgs; [
    # gh-dash
    gh-markdown-preview
    gh-poi
  ];

  # gh-dash
  # programs.gh-dash.enable = true;
  # programs.gh-dash.catppuccin.enable = true;
}
