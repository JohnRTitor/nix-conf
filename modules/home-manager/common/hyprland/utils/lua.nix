{ lib }:
let
  mkLuaInline = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua { };

  args = xs: { _args = xs; };

  mkEventHook =
    eventName: commands:
    args [
      eventName
      (mkLuaInline ''
        function()
        ${lib.concatMapStringsSep "\n" (command: "  hl.exec_cmd(${builtins.toJSON command})") commands}
        end
      '')
    ];
in
{
  inherit
    mkLuaInline
    toLua
    args
    mkEventHook
    ;

  dspExec = cmd: mkLuaInline ("hl.dsp.exec_cmd(" + toLua cmd + ")");

  mkBezier =
    name: points:
    args [
      name
      {
        type = "bezier";
        inherit points;
      }
    ];

  mkBind =
    key: desc: action: opts:
    args [
      (mkLuaInline key)
      action
      ({ description = desc; } // opts)
    ];

  mkEnvList =
    attrs:
    lib.mapAttrsToList (
      name: value:
      args [
        name
        value
      ]
    ) attrs;

  mkStartupHook = mkEventHook "hyprland.start";
}
