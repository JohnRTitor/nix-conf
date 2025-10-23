# Import of thie module is controlled by bool: config.myOptions.devSettings.nginx
# This config file mainly contains the Nginx configuration for localhost
# Integrates with PHP (done through PHP-FPM) and MySQL
{
  config,
  lib,
  pkgs,
  userSettings,
  ...
}:
lib.mkIf config.myOptions.devSettings.nginx {
  # Nginx virtual host configuration for localhost
  services.nginx.virtualHosts."localhost" = {
    root = "/var/www/localhost-server";
    extraConfig = ''
      index index.php;
    '';

    locations."~ ^(.+\\.php)(.*)$" = {
      extraConfig = ''
        # Check that the PHP script exists before passing it
        try_files $fastcgi_script_name =404;
        include ${config.services.nginx.package}/conf/fastcgi_params;
        fastcgi_split_path_info  ^(.+\.php)(.*)$;
        fastcgi_pass unix:${config.services.phpfpm.pools.mypool.socket};
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param  PATH_INFO        $fastcgi_path_info;

        include ${config.services.nginx.package}/conf/fastcgi.conf;
      '';
    };
  };

  # PHP-FPM pool configuration
  # Needed for nginx to communicate with PHP
  services.phpfpm.pools.mypool = {
    user = "nobody";
    settings = {
      "pm" = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "listen.group" = config.services.nginx.group;
      "pm.max_children" = 5;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 1;
      "pm.max_spare_servers" = 3;
      "pm.max_requests" = 500;
    };
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  # Bind mount the website instances directory
  # As nginx can't follow symlinks
  # And will have permissions issues if we use symlinks
  fileSystems."/var/www/localhost-server" = {
    device = "/home/masum/Website-Instances";
    fsType = "none";
    options = [ "bind" ];
  };
}
