{
  description = "Ghost CMS - Arion configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    {
      # Export the nixos modules for easy importing
      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.services.ghost-cms;
        in
        {

          options.services.ghost-cms = {
            enable = mkEnableOption "Ghost CMS";

            url = mkOption {
              type = types.str;
              default = "http://localhost:8080";
              description = "Public URL of the Ghost instance";
            };

            port = mkOption {
              type = types.port;
              default = 8080;
              description = "Port to expose Ghost on";
            };

            database = {
              client = mkOption {
                type = types.enum [ "mysql" "sqlite3" ];
                default = "mysql";
                description = "Database client type";
              };

              host = mkOption {
                type = types.str;
                default = "db";
                description = "Database host";
              };

              user = mkOption {
                type = types.str;
                default = "root";
                description = "Database user";
              };

              passwordFile = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Path to file containing database password";
                example = "/run/secrets/ghost-db-password";
              };

              database = mkOption {
                type = types.str;
                default = "ghost";
                description = "Database name";
              };
            };

            mail = {
              transport = mkOption {
                type = types.nullOr types.str;
                default = "Direct";
                description = "Mail transport method";
              };

              from = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "From email address";
              };

              smtp = {
                host = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                  description = "SMTP host";
                };

                port = mkOption {
                  type = types.nullOr types.port;
                  default = null;
                  description = "SMTP port";
                };

                secure = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = "Use secure SMTP connection";
                };

                userFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to file containing SMTP username";
                  example = "/run/secrets/ghost-smtp-user";
                };

                passwordFile = mkOption {
                  type = types.nullOr types.path;
                  default = null;
                  description = "Path to file containing SMTP password";
                  example = "/run/secrets/ghost-smtp-password";
                };
              };
            };

            nodeEnv = mkOption {
              type = types.enum [ "production" "development" ];
              default = "production";
              description = "Node environment";
            };

            contentPath = mkOption {
              type = types.str;
              default = "/var/lib/ghost/content";
              description = "Path to Ghost content directory";
            };
          };

          config = mkIf cfg.enable {
            # Ghost CMS configuration options are defined but implementation
            # is handled by the importing system (newton) which configures Arion
          };
        };
    };
}