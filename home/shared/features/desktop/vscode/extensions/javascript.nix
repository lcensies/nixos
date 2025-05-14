{ pkgs, ... }:
{
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    denoland.vscode-deno # javascript (deno)

    # Linter / Formatter
    dbaeumer.vscode-eslint # eslint

    # Library / Framework
    astro-build.astro-vscode # astro
    svelte.svelte-vscode # svelte
    unifiedjs.vscode-mdx # mdx
    vue.volar # vue3
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # THREE.js / R3F / WebXR
    {
      # https://volu.dev
      name = "volumetrics";
      publisher = "Volumetrics";
      version = "0.1.7";
      sha256 = "4QmSQJjuEach+B9Q2muQ4iVRak40l2yK+5z0RV+58eo=";
    }
    # UnoCSS
    {
      name = "unocss";
      publisher = "antfu";
      version = "0.61.9";
      sha256 = "ugkeCMTvWmC7ebc1uB1ZzIbzIdUTO/8vE3Gfh363Ykc=";
    }
    # HTML/CSS Tagged Template Literals
    {
      name = "fast-tagged-templates";
      publisher = "ms-fast";
      version = "0.2.0";
      sha256 = "vddpfU6VcXSqRbjGvQEY547e+0GTRNlRKaiYE/Ime3g=";
    }
  ];

  programs.vscode.userSettings = {
    "deno.enable" = false;
  };
}
