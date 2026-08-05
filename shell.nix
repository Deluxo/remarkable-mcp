{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "remarkable-mcp";

  buildInputs = with pkgs; [
    uv
    python3
    tesseract
    cairo
    pkg-config
  ];

  shellHook = ''
    unset PYTHONPATH
  '';
}
