# Import of thie module is controlled by bool: servicesSettings.nginx
# This is a configuration file for the adminer.local virtual host
# It is a database management tool that is a single PHP file
{
  self,
  config,
  lib,
  pkgs,
  servicesSettings,
  ...
}:
{
  # Nginx configuration for adminer.local
  # but for this to work, adminer.local must point to "127.0.0.1"
  # via networking.extraHosts, you should add to ../system/network.nix

  # To use adminer, just type adminer.local in the browser
  # After any changes to this file, run the following commands:
  # systemctl restart phpfpm-adminer.service nginx.service

  services.nginx.virtualHosts."adminer.local" = {
    extraConfig = ''
      index index.php;
    '';
    locations."/".extraConfig = ''
      try_files $uri $uri/ /index.php?$args;
    '';

    locations."~ ^(.+\\.php)(.*)$" = {
      extraConfig = ''
        # Check that the PHP script exists before passing it
        try_files $fastcgi_script_name =404;
        include ${config.services.nginx.package}/conf/fastcgi_params;
        fastcgi_split_path_info  ^(.+\.php)(.*)$;
        fastcgi_pass unix:${config.services.phpfpm.pools.adminer.socket};
        fastcgi_param  SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
        fastcgi_param  PATH_INFO        $fastcgi_path_info;

        include ${config.services.nginx.package}/conf/fastcgi.conf;
      '';
    };
    root = "${self.packages.${pkgs.system}.adminneo-with-theme}";
  };

  # PHP-FPM pool configuration
  # Needed for nginx to communicate with PHP
  services.phpfpm.pools.adminer = {
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
}
