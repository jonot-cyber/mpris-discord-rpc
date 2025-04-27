{
  description = "Linux Discord rich presence for music";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ...}: rec {
    packages = {
      x86_64-linux.mpris-discord-rpc =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
          pkgs.rustPlatform.buildRustPackage rec {
            pname = "mpris-discord-rpc";
            version = "v0.4.0";

            src = pkgs.fetchFromGitHub {
              owner = "patryk-ku";
              repo = pname;
              rev = version;
              hash = "sha256-szftij29YTLzqBNirvoTgZfPIRznM1Ax5MPTKqB1nYI=";
            };

            postPatch = ''
              echo "LASTFM_API_KEY=9ee4c0cf26335be5b1259ed067e28fc3" > .env
              ls -a
            '';

            cargoHash = "sha256-8bJ6esBiA1fkwiqhNBPQIvkPI2RgHXJrlFxe2EyCdOA=";

            buildInputs = with pkgs; [ openssl dbus ];
            nativeBuildInputs = with pkgs; [ pkg-config ];
          };
          
    };
    homeManagerModules.mpris-discord-rpc =
      { config, lib, pkgs, ... }:
      let
        cfg = config.services.mpris-discord-rpc;
        playersString = lib.concatMapStringsSep "" (x: "-a" + x) cfg.player;
      in
        {
          options.services.mpris-discord-rpc = {
            enable = lib.mkEnableOption "Enable MPRIS Discord RPC";
            package = lib.mkOption {
              type = lib.types.package;
              default = packages.x86_64-linux.mpris-discord-rpc;
              description = "The package to use for mpris-discord-rpc";
            };
            player = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              example = "[Clementine]";
              description = "What players should be allowed to show up as a Discord status";
            };
          };

          config = lib.mkIf cfg.enable {
            systemd.user.services.mpris-discord-rpc = {
              Unit = {
                Description = "MPRIS Discord RPC";
              };
              Install.WantedBy = [ "graphical-session.target" ];
              Service.ExecStart = "${cfg.package}/bin/mpris-discord-rpc ${playersString}";
            };
          };
        };
  };
}
