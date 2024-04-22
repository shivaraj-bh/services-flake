let
  flake = builtins.getFlake (toString ./dev);
in
{
  inherit (flake.outputs) herculesCI;
}
