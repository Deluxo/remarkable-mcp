{ config, lib, pkgs, ... }:

let
  cfg = config.services.remarkable-mcp;
in {
  options.services.remarkable-mcp = {
    enable = lib.mkEnableOption "the reMarkable MCP server exposed over Streamable HTTP for Open WebUI";

    user = lib.mkOption {
      type = lib.types.str;
      default = "remarkable-mcp";
      description = ''
        System user the bridge runs as. Must own the reMarkable cloud token in
        ~/.rmapi and have read access to the `python`/`launcher` paths.
      '';
    };

    python = lib.mkOption {
      type = lib.types.path;
      default = "/opt/remarkable-mcp/.venv/bin/python";
      description = ''
        Python interpreter of the venv that has remarkable-mcp installed.
        Override with the actual venv path on the host.
      '';
    };

    launcher = lib.mkOption {
      type = lib.types.path;
      default = "/opt/remarkable-mcp/remarkable_mcp_http.py";
      description = ''
        Streamable-HTTP launcher script shipped with this module.
        Override with the path to the checked-out copy on the host.
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address to bind. Keep on localhost; Open WebUI is the only client.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description
    };

    tesseractBin = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.tesseract}/bin";
      description = ''
        Directory containing the `tesseract` binary, added to the service PATH so
        pytesseract-based OCR works.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.remarkable-mcp-bridge = {
      description = "reMarkable MCP server (Streamable HTTP bridge for Open WebUI)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = "${cfg.python} ${cfg.launcher}";
        Restart = "on-failure";
        RestartSec = "5";
        Environment = [
          "HOME=/home/${cfg.user}"
          "REMARKABLE_MCP_HOST=${cfg.host}"
          "REMARKABLE_MCP_PORT=${toString cfg.port}"
          "PATH=${cfg.tesseractBin}:/run/current-system/sw/bin:/usr/bin:/bin"
        ];
      };
    };
  };
}
