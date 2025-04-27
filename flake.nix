{
  description = "Linux Discord rich presence for music";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-24.11";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in rec {
            packages = rec {
              mpris-discord-rpc = pkgs.callPackage ./default.nix {};
              default = mpris-discord-rpc;
            };
          }) // {
            homeManagerModules.mpris-discord-rpc =
              { config, lib, pkgs, ... }:
              with lib;
              let
                cfg = config.services.mpris-discord-rpc;
                playersString = concatMapStringsSep "" (x: "-a" + x) cfg.players;
              in
                {
                  options.services.mpris-discord-rpc = {
                    enable = lib.mkEnableOption "Enable MPRIS Discord RPC";
                    package = lib.mkOption {
                      type = lib.types.package;
                      default = self.packages.${pkgs.stdenv.hostPlatform.system}.mpris-discord-rpc;
                      description = "The package to use for mpris-discord-rpc";
                    };
                    players = lib.mkOption {
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
