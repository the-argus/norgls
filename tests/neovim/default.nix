{
  writeShellScriptBin,
  runCommandLocal,
  neovim,
  norgls,
  gitMinimal,
  vimPlugins,
  ...
}: let
  init = builtins.toFile "init.lua" (builtins.readFile ./init.lua);

  plugins = with vimPlugins; [
    nvim-lspconfig
  ];

  pluginCommands = map (plugin: "ln -sf ${plugin} $out/pack/myNeovimPlugins/start/${plugin.pname}") plugins;

  packpath = runCommandLocal "installPlugins" {} ''
    mkdir -p $out/pack/myNeovimPlugins/start
    ${builtins.concatStringsSep "\n" pluginCommands}
  '';
in
  writeShellScriptBin
  "neovim-with-norg"
  ''
    PATH=$PATH:${norgls}/bin:${gitMinimal}/bin \
    ${neovim}/bin/nvim -u ${init} \
    "--cmd" "set packpath^=${packpath}"
  ''
