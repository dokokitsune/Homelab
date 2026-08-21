{
  description = "Homelab GitOps tooling";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            uv          # provides uvx, used by the grafana MCP server in .mcp.json
            python3     # uv's own CPython downloads are dynamically linked and
                        # cannot execute on NixOS; point uv at this one instead
            kubectl
            fluxcd
            talosctl
            kubernetes-helm
            kubeconform
            jq
            yq-go
          ];

          # Never let uv fetch a prebuilt CPython — it won't run here.
          UV_PYTHON_DOWNLOADS = "never";

          # The token check lives in .envrc, which can only run it after
          # dotenv_if_exists has loaded .env — this shellHook runs before that.
        };
      });
    };
}
