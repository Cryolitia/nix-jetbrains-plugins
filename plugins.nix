{ pkgs }:

let
  inherit (pkgs) lib fetchurl fetchzip;

  pluginsJson = builtins.fromJSON (builtins.readFile ./data/cache/plugins-latest.json);
  fetchPluginSrc = url: hash:
    let
      isJar = lib.hasSuffix ".jar" url;
      fetcher = if isJar then fetchurl else fetchzip;
    in
    fetcher {
      executable = isJar;
      inherit url hash;
    };
  files = builtins.mapAttrs (key: value: fetchPluginSrc key value) pluginsJson.files;
  ids = builtins.attrNames pluginsJson.plugins;


in
rec {

  mkPlugin = id: file: files."${file}";

  selectFile = id: ide: build:
    if !builtins.elem ide pluginsJson.plugins."${id}".compatible then
      throw "Plugin with id ${id} does not support IDE ${ide}"
    else if !pluginsJson.plugins."${id}".builds ? "${build}" then
      throw "Jetbrains IDEs with build ${build} are not in nixpkgs. Try update_plugins.py with --with-build?"
    else if pluginsJson.plugins."${id}".builds."${build}" == null then
      throw "Plugin with id ${id} does not support build ${build}"
    else
      pluginsJson.plugins."${id}".builds."${build}";

  byId = builtins.listToAttrs
    (map
      (id: {
        name = id;
        value = ide: build: mkPlugin id (selectFile id ide build);
      })
      ids);

  byName = builtins.listToAttrs
    (map
      (id: {
        name = pluginsJson.plugins."${id}".name;
        value = byId."${id}";
      })
      ids);

  addPlugins = ide: unprocessedPlugins:
    let

      processPlugin = plugin:
        if byId ? "${plugin}" then byId."${plugin}" ide.pname ide.buildNumber else
        if byName ? "${plugin}" then byName."${plugin}" ide.pname ide.buildNumber else
        plugin;

      plugins = map processPlugin unprocessedPlugins;

    in pkgs.jetbrains.plugins.addPlugins ide plugins;
}
