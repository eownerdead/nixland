{ config, lib, dream2nix, ... }:
let
  cfg = config.service;
  root = config.deps.runCommandLocal "root" { } ''
    mkdir -p $out/{dev,proc,sys,nix/store,etc,run,tmp}/

    cat > $out/etc/passwd << EOF
    root:x:0:0:System administrator:/root:${config.deps.bash}
    nobody:x:65534:65534:Unprivileged account (don't use!):/var/empty:/bin/nologin
    EOF

    cat > $out/etc/group << EOF
    root:x:0:
    wheel:x:1:
    kmem:x:2:
    tty:x:3:
    messagebus:x:4:
    disk:x:6:
    audio:x:17:
    floppy:x:18:
    uucp:x:19:
    lp:x:20:
    cdrom:x:24:
    tape:x:25:
    video:x:26:
    dialout:x:27:
    utmp:x:29:
    adm:x:55:
    keys:x:96:
    users:x:100:
    input:x:174:
    nogroup:x:65534:
    EOF

    cat > $out/etc/nsswitch.conf << EOF
    passwd:    files mymachines systemd
    group:     files mymachines systemd
    shadow:    files

    hosts:     files mymachines dns myhostname
    networks:  files

    ethers:    files
    services:  files
    protocols: files
    rpc:       files
    EOF
  '';

  configJson = {
    ociVersion = "1.0.0";
    platform = {
      os = "linux";
      arch = "x86_64";
    };

    process = {
      #        terminal = true;
      user = {
        uid = 0;
        gid = 0;
      };
      args = [ "${config.deps.bash}/bin/bash" "-c" config.service.start ];
      env = [
        "TERM=xterm"
        "SSL_CERT_FILE=${config.deps.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      cwd = "/";
      noNewPrivileges = true;
    };

    root = {
      path = "${root}";
      readonly = true;
    };

    mounts = [
      {
        destination = "/proc";
        type = "proc";
        source = "proc";
      }
      {
        destination = "/dev";
        type = "tmpfs";
        source = "tmpfs";
        options = [ "nosuid" "strictatime" "mode=755" "size=65536k" ];
      }
      {
        destination = "/dev/pts";
        type = "devpts";
        source = "devpts";
        options =
          [ "nosuid" "noexec" "newinstance" "ptmxmode=0666" "mode=0620" ];
      }
      {
        destination = "/dev/shm";
        type = "tmpfs";
        source = "shm";
        options = [ "nosuid" "noexec" "nodev" "mode=1777" "size=65536k" ];
      }
      {
        destination = "/dev/mqueue";
        type = "mqueue";
        source = "mqueue";
        options = [ "nosuid" "noexec" "nodev" ];
      }
      {
        destination = "/sys";
        type = "none";
        source = "/sys";
        options = [ "rbind" "nosuid" "noexec" "nodev" "ro" ];
      }
      {
        destination = "/sys/fs/cgroup";
        type = "cgroup";
        source = "cgroup";
        options = [ "nosuid" "noexec" "nodev" "relatime" "ro" ];
      }
      {
        destination = "/tmp";
        type = "tmpfs";
        source = "tmpfs";
        options = [ "nosuid" "nodev" "strictatime" "mode=1777" ];
      }
      {
        destination = "/run";
        type = "tmpfs";
        source = "tmpfs";
        options = [ "mode=0700" ];
      }
      {
        destination = "/nix/store";
        source = "/nix/store";
        options = [ "bind" "ro" ];
      }
    ];

    linux = {
      namespaces = map (type: { inherit type; }) [
        "pid"
        "ipc"
        "uts"
        "user"
        "cgroup"
        "mount"
      ];

      uidMappings = [{
        containerID = 0;
        hostID = 1000;
        size = 1;
      }];

      gidMappings = [{
        containerID = 0;
        hostID = 100;
        size = 1;
      }];
    };
  };
in {
  imports = [ ./service.nix ];

  config = {
    inherit (cfg) name;
    version = "unstable";

    deps = { nixpkgs, ... }: {
      inherit (nixpkgs) writeTextFile bash cacert runCommandLocal;
    };

    package-func.result = lib.mkIf (cfg.backend == "oci") (lib.mkForce
      (config.deps.writeTextFile {
        name = "oci-bundle";
        text = builtins.toJSON configJson;
        destination = "/config.json";
      }));
  };
}
