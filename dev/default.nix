let
  flake = builtins.getFlake (toString ./.);
  self = {
    inherit (flake) inputs;
    outputs = self.config.flake;
  };
in
self.config.flake // { inherit (flake) inputs; }
