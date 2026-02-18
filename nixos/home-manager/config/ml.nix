{ pkgs, inputs, ... }:
let
  llmPkgs = inputs.llm-agents.packages.${pkgs.system};
in
{
  home.packages = [
    llmPkgs.cursor-agent
  ];
}

