{ pkgs, lib ? pkgs.lib, config ? null, ... }:

let
  # Default configuration for Ghost deployment
  defaultConfig = {
    port = 8080;
    url = "http://localhost:8080";
    database = {
      client = "mysql";
      host = "db";
      user = "root";
      password = "ghostpass";
      database = "ghost";
    };
    mail = {
      transport = "Direct";
      from = null;
      smtp = {
        host = null;
        port = null;
        secure = null;
        user = null;
        password = null;
      };
    };
    nodeEnv = "production";
    contentPath = "/var/lib/ghost/content";
  };

  # Use provided config or fallback to defaults
  cfg = defaultConfig // (if config != null then config else {});
  
  # Volume mounts for secrets
  secretVolumes = lib.optionals (cfg.database.passwordFile != null || cfg.mail.smtp.passwordFile != null || cfg.mail.smtp.userFile != null) [
    "/run/agenix:/secrets:ro"
  ];
  
  # Build environment variables for Ghost
  ghostEnv = {
    database__client = cfg.database.client;
    database__connection__host = cfg.database.host;
    database__connection__user = cfg.database.user;
    database__connection__password = 
      if cfg.database.passwordFile != null then "$(cat /secrets/ghost-db-password)"
      else cfg.database.password;
    database__connection__database = cfg.database.database;
    url = cfg.url;
    NODE_ENV = cfg.nodeEnv;
  } // lib.optionalAttrs (cfg.mail.transport != null) {
    mail__transport = cfg.mail.transport;
  } // lib.optionalAttrs (cfg.mail.from != null) {
    mail__from = cfg.mail.from;
  } // lib.optionalAttrs (cfg.mail.smtp.host != null) {
    mail__options__host = cfg.mail.smtp.host;
  } // lib.optionalAttrs (cfg.mail.smtp.port != null) {
    mail__options__port = toString cfg.mail.smtp.port;
  } // lib.optionalAttrs (cfg.mail.smtp.secure != null) {
    mail__options__secure = if cfg.mail.smtp.secure then "true" else "false";
  } // lib.optionalAttrs (cfg.mail.smtp.user != null) {
    mail__options__auth__user = cfg.mail.smtp.user;
  } // lib.optionalAttrs (cfg.mail.smtp.userFile != null) {
    mail__options__auth__user = "$(cat /secrets/smtp-user)";
  } // lib.optionalAttrs (cfg.mail.smtp.password != null) {
    mail__options__auth__pass = cfg.mail.smtp.password;
  } // lib.optionalAttrs (cfg.mail.smtp.passwordFile != null) {
    mail__options__auth__pass = "$(cat /secrets/smtp-password)";
  };
in
{
  project.name = "ghost";

  services = {
    # Ghost CMS
    ghost = {
      service = {
        image = "ghost:5-alpine";
        ports = [ "${toString cfg.port}:2368" ];
        
        volumes = [
          "ghost-content:${cfg.contentPath}"
        ] ++ secretVolumes;
        
        environment = ghostEnv;
        
        depends_on = {
          db = {
            condition = "service_healthy";
          };
        };
        
        healthcheck = {
          test = [ "CMD" "wget" "--no-verbose" "--tries=1" "--spider" "http://localhost:2368/ghost/api/v4/admin/site/" ];
          interval = "30s";
          timeout = "10s";
          retries = 5;
          start_period = "60s";
        };
        
        restart = "always";
      };
    };

    # MySQL Database
    db = {
      service = {
        image = "mysql:8.0";
        
        volumes = [
          "db-data:/var/lib/mysql"
        ] ++ secretVolumes;
        
        environment = {
          MYSQL_DATABASE = cfg.database.database;
        } // (if cfg.database.passwordFile != null then {
          MYSQL_ROOT_PASSWORD_FILE = "/secrets/ghost-db-password";
        } else {
          MYSQL_ROOT_PASSWORD = cfg.database.password;
        });
        
        healthcheck = {
          test = [ "CMD" "mysqladmin" "ping" "-h" "localhost" "-u" "root" "-p${if cfg.database.passwordFile != null then "$(cat /secrets/ghost-db-password)" else cfg.database.password}" ];
          interval = "10s";
          timeout = "5s";
          retries = 5;
          start_period = "30s";
        };
        
        restart = "always";
      };
    };
  };

  # Docker volumes
  docker-compose.volumes = {
    db-data = {};
    ghost-content = {};
  };
}