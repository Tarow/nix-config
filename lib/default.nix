lib: {
  tarow = with lib; {
    mkIfElse = p: yes: no:
      mkMerge [
        (mkIf p yes)
        (mkIf (!p) no)
      ];

    readSubdirs = basePath: let
      dirs = builtins.attrNames (attrsets.filterAttrs (v: v: v == "directory") (builtins.readDir basePath));
      dirPaths = map (d: basePath + "/${d}") dirs;
    in
      dirPaths;

    recursiveMerge = attrList: let
      f = attrPath:
        zipAttrsWith (
          n: values:
            if tail values == []
            then head values
            else if all isList values
            then unique (concatLists values)
            else if all isAttrs values
            then f (attrPath ++ [n]) values
            else last values
        );
    in
      f [] attrList;

    enableModules = moduleNames:
          moduleNames 
          |> (builtins.map (m: {
              name = m;
              value = {enable = true;};
            }))
          |> (builtins.listToAttrs);
  };
}
