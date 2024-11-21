lib: {
  tarow = with lib; {
    readSubdirs = basePath:
      let
        dirs = builtins.attrNames (attrsets.filterAttrs (v: v: v == "directory") (builtins.readDir basePath));
        dirPaths = map (d: basePath + "/${d}") dirs;
      in
      dirPaths;

    recursiveMerge = attrList:
      let
        f = attrPath:
          zipAttrsWith (n: values:
            if tail values == [ ]
            then head values
            else if all isList values
            then unique (concatLists values)
            else if all isAttrs values
            then f (attrPath ++ [ n ]) values
            else last values
          );
      in
      f [ ] attrList;

    enableModules = moduleNames: builtins.listToAttrs (builtins.map (m: { name = m; value = { enable = true; }; }) moduleNames);
  };
}
