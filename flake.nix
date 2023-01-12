{
  inputs.nixpkgs.url = "github:NickCao/nixpkgs/riscv";

  nixConfig.extra-substituters = "https://cache.nichi.co";
  nixConfig.extra-trusted-public-keys = "hydra.nichi.co-0:P3nkYHhmcLR3eNJgOAnHDjmQLkfqheGyhZ6GLrUVHwk=";

  outputs = { self, nixpkgs }:
    let eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          crossSystem.config = "riscv64-unknown-linux-gnu";
        });


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
