{ config, pkgs, nodes, ... }:
let
  whichPkg = pkg: "${builtins.getAttr pkg pkgs}/bin/${pkg}";
  anyPublicIP = nodes: "10.14.10.135";
  nomadCommonConfig = ''
    log_level = "DEBUG"
    data_dir = "/var/nomad"'';

    nomadServerConfig = {
      filename = "nomad-server.hcl";
      text = ''
        server {
            enabled = true
            bootstrap_expect = ${with builtins; toString (length (attrNames nodes))}
        }

        advertise {
          http = "${thisNodeIP}"
          rpc  = "${thisNodeIP}"
          serf = "${thisNodeIP}"
        }

        ${nomadCommonConfig}'';
    };

  nomadClientConfig = {
    filename = "nomad-client.hcl";
    text = ''
      datacenter = "dc1"

      client {
          enabled = true
      }

      ports {
          http = 5656
      }

      ${nomadCommonConfig}'';
  };

  nomadService = kind: {
    description = "Nomad ${kind}";
    # TODO: how to do UI

    # not much point in running as non-root, since it has access to the Docker socket anyway

    path = with pkgs; [
      iproute
    ];

    serviceConfig = {
      ExecStart = "${whichPkg "nomad"} agent --config /etc/nomad-${kind}.hcl";
      ExecReload = "/run/current-system/sw/bin/kill -HUP $MAINPID";

      KillMode="process";
      Restart = "on-failure";
      RestartSec="42s";
    };

    after = if kind == "client" then [ "nomad-server.service" ] else [ "consul-dev.service" ];
    wantedBy = [ "multi-user.target" ];
  };

  nomadConfigEntry = config: {
    "${config.filename}" = {
      text = config.text;
      mode = "0444";
    };
  };
  
  nomadServer = "server";
  nomadClient = "client";

  thisNodeIP = with builtins; (getAttr "name" nodes).config.networking.publicIPv4;
in
{
  imports = [
    ./nomad.nix
  ];

  environment.systemPackages = with pkgs; [
      consul
      vimHugeX
      nomad
  ];

  # TODO: heh, I can do this better
  services.openssh.permitRootLogin = "yes";

  # TODO: move gluster mounts into nixos
  # TODO: ensure machines won't go to sleep after closing lid
  # TODO: bring cluster-zwei online

  # TODO: extract Consul
  # TODO: add ssh banner
  # TODO: secure ssh (will it break nixops?)
  # TODO: backups!

  # TODO: copy apps configs (how about stically through etc? :D) - Consul
  # TODO: copy job descriptions
  # TODO: tune them so that they work

  # TODO: add management scripts from Squire vs. make sure they're not needed
  # TODO: move persistent data

  # TODO: change generic DNS to OpenNic
  # TODO: do better security XD
    # add explicit users and minimum privilages everywhere
    # firewall - is doing firewall worth it in this case?
    # go through "security" options on nixos

  virtualisation.docker.enable = true;
  networking.firewall.enable = false;

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    alwaysKeepRunning = true;

    servers = [
      "8.8.8.8"
      "/consul/127.0.0.1#8600"
    ];

    extraConfig = ''
      cache-size=0
      no-resolv
    '';
  };

  services.glusterfs.enable = true;

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false; # at least until I figure out how to securely set passwords across multiple machines

  users.users.allgreed = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWnwdY4pSLVyuLwMARJ6tQtnxcrQS4dx5RM+HiVBj4HSGWSSGNpbFlwcUx4bDuSII6hofuoPy83OvtKs/n1+SWv9UDue72slXamh2XbTXDtA2IG2XiiaiXSUUbJX5/ejKE+90/OK87ccGpDFgJVAD53EMV6NUJXWbDKwVrAnVEzoCPqGLYGDPs389pzM1OYHFzbuWAh5Wlrv/05j4T8b5fB+QsX87Z8FT0tDwPjUYzsd6ugL7Vf5EU8HkLAH+9m128OMGcOuv5bTVUVbR7CI7c8bmw2+nw7AjgX7oexQFC+fevSKYVRbusZ88jbz5sUhCC58d3mdfmYxME3z/sD37Cr0HTUBOEWS4eP0BqF0w+tTTl3bsXCUhs35cMIoUY8SRuij3zqsGNDqWhVuVFwI5uYJOXEtBfQuI/79inJhLHi/SwnXu1FXJ0q7kRureMR9EnrZ8LEMNZ9rrFwCdhJXIlHzu9vpbMlpbSAkiHmfiigcCZFxyBr/GRRj6srTGxkv63fsOYOVfvTSzUa4cpqxEcD+0Yhyr7mf/OfpdwTaR/r8SPvP3CJUme2pviXP7FxcVYKhHMAJTLQ2xMwEt6yyqs/RR9/lYdQFyCwM5oBZQqZxHJMSqdXp+ZUEFa5orKWvaxBisLQy2tIEqE77h22er3zK0VFK/ETE/3Cxdz3HtlOQ== allgreed@terminator"
      ];
  };

  # TODO: Move it into a real service without --dev
  # TODO: how about containers and using system stuff? ;D
  systemd.services.consul-dev = {
      description = "Consul client and server";

      serviceConfig = {
         ExecStart = "${whichPkg "consul"} agent --dev --ui --bind '{{ GetInterfaceIP \"enp19s0\" }}' --retry-join '${anyPublicIP nodes}'";
         Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
  };

  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d";
  };

  environment.etc = 
    nomadConfigEntry nomadServerConfig //
    nomadConfigEntry nomadClientConfig
    ;

  systemd.services.nomad-client = nomadService nomadClient;
  systemd.services.nomad-server = nomadService nomadServer;
}
