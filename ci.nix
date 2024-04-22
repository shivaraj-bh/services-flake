let
  flake = import ./dev;
in
{
  inherit (flake) herculesCI;
}
