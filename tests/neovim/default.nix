{
  writeShellScriptBin,
  runCommandLocal,
  neovim,
  norgls,
  vimPlugins,
  fetchFromGitHub,
  ...
}: let
  init = builtins.toFile "init.lua" (builtins.readFile ./init.lua);

  plugins = with vimPlugins; [
    neorg
    (nvim-lspconfig.overrideAttrs (_: {
      src = fetchFromGitHub {
        owner = "the-argus";
        repo = "nvim-lspconfig";
        rev = "952b4f8f129d09828be4a0cd306bc93b1deb8109";
        sha256 = "075n9dmpjxlk9pxv7biawbnvpsj9ynnsdn2l33pm771qv9rpma0s";
      };
    }))
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
    PATH=$PATH:${norgls}/bin \
    ${neovim}/bin/nvim -u ${init} \
    "--cmd" "set packpath^=${packpath}"
  ''
