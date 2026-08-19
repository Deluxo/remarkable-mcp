let
  testPkgs = import <nixpkgs> { config = {}; overlays = []; };
  evalModule = import <nixpkgs/nixos/lib/eval-config.nix>;

  # Test: default configuration uses package.output/bin/remarkable-mcp
  evaluated = evalModule {
    modules = [
      ../remarkable-mcp-bridge.nix
      {
        services.remarkable-mcp.enable = true;
        system.stateVersion = "24.11";
      }
    ];
    pkgs = testPkgs;
  };

  config = evaluated.config;
  service = config.systemd.services.remarkable-mcp-bridge;
  unitText = config.systemd.units."remarkable-mcp-bridge.service".text;
in
  # Service runs as the expected user
  assert service.serviceConfig.User == "remarkable-mcp";
  assert service.serviceConfig.Group == "remarkable-mcp";

  # HOME points to the configured home dir
  assert service.environment.HOME == "/var/lib/remarkable-mcp";

  # Security settings are enforced
  assert service.serviceConfig.NoNewPrivileges;
  assert service.serviceConfig.PrivateTmp;

  # tesseract is always in path
  assert builtins.elem testPkgs.tesseract service.path;

  # The command points to the package's bin directory
  assert builtins.match ".*bin/remarkable-mcp.*" service.serviceConfig.ExecStart != null;

  # ExecStart contains the flag arguments
  assert builtins.match ".*--http.*" service.serviceConfig.ExecStart != null;
  assert builtins.match ".*--host.*" service.serviceConfig.ExecStart != null;
  assert builtins.match ".*--port.*" service.serviceConfig.ExecStart != null;

  # unitText is a valid unit string
  assert builtins.isString unitText;
  assert builtins.stringLength unitText > 0;

  # Return a plain value, not a derivation: `nix-instantiate --eval --strict`
  # deeply forces the result, and forcing any nixpkgs stdenv derivation exceeds
  # Nix's max-call-depth. The asserts above are still evaluated.
  true
