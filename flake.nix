{
  description = "Multicloud Kubernetes provisioning";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # Terraform is BSL-licensed, which nixpkgs marks unfree
            config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "terraform";
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              awscli2
              (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
              terraform
              dnsutils # dig, used by the Google Cloud DNS module
              gh
              yq-go
              kubectl
              kustomize
              docker-client
              k3d
              skaffold
            ];
          };
        });
    };
}
