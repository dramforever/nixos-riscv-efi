{
  inputs.nixpkgs.url = "github:NickCao/nixpkgs/riscv";
  inputs.nixpkgs-staging.url = "github:NixOS/nixpkgs/staging";

  nixConfig.extra-substituters = "https://cache.nichi.co";
  nixConfig.extra-trusted-public-keys = "hydra.nichi.co-0:P3nkYHhmcLR3eNJgOAnHDjmQLkfqheGyhZ6GLrUVHwk=";

  outputs = { self, nixpkgs, nixpkgs-staging }:
    let eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          crossSystem.config = "riscv64-unknown-linux-gnu";
          overlays = [ self.overlays.systemd-252 ];
        });

      overlays.systemd-252 = final: prev: {
        systemd = final.callPackage (nixpkgs-staging + "/pkgs/os-specific/linux/systemd") {
          # break some cyclic dependencies
          util-linux = final.util-linuxMinimal;
          # provide a super minimal gnupg used for systemd-machined
          gnupg = final.gnupg23.override {
            enableMinimal = true;
            guiSupport = false;
          };
          libbpf = final.libbpf_1;
        };
      };

      nixosConfigurations.nixos-efi-demo = nixpkgs.lib.nixosSystem {
        system = "riscv64-linux";
        modules = [
          ./configuration.nix
          { nixpkgs.pkgs = self.legacyPackages."x86_64-linux"; }
        ];
      };

      packages.x86_64-linux.nixos-system = self.nixosConfigurations.nixos-efi-demo.config.system.build.toplevel;
      packages.x86_64-linux.nixos-image = self.nixosConfigurations.nixos-efi-demo.config.system.build.efiImage;
    };
}
