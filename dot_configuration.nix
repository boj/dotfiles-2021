{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config.allowUnfree = true;
  };
  c1 = builtins.readFile "/root/certs/c1.crt";
  c2 = builtins.readFile "/root/certs/c2.crt";
in {
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [ ( self: super: { sof-firmware = unstable.sof-firmware; } ) ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelParams = ["ipv6.disable=1"];
  #boot.extraModprobeConfig = ''
  #  options snd slots=snd-hda-intel
  #  options snd-intel-dspcfg dsp_driver=1
  #'';
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.rtkit.enable = true;
  security.pki.certificates = [ c1 c2 ];
  hardware.enableAllFirmware = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  services.blueman.enable = true;

  time.timeZone = "America/Anchorage";

  services.acpid.enable = true;

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/wrappers/bin/light -A 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/wrappers/bin/light -U 10"; }
    ];
  };

  sound.enable = true;
  sound.mediaKeys.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = unstable.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
  };

  networking = {
    hostName = "nanya";
    useDHCP = false;
    interfaces.enp5s0u1.useDHCP = true;
    interfaces.wlp0s20f3.useDHCP = true;
    nameservers = [
      "172.16.69.44"
      "100.100.100.100"
    ];
    search = [
      "accorp.local"
      "mojobojo.gmail.com.beta.tailscale.net"
    ];
    wireless.enable = true;
    wireless.userControlled.enable = true;
    wireless.networks = {
      "AlasConnect_Guest" = {
        psk = "l0udPuppy2!";
      };

      mojobojo = {
        psk = "battlenet";
      };
    };
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };

  services = {
    tailscale.enable = true;
    openssh.enable = true;
  };

  services.xserver = {
    enable = true;

    # xkbOptions = "ctrl:swapcaps";

    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
      };
    };
 
    desktopManager = {
      xterm.enable = true;
    };

    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "bojo";
      };
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        pavucontrol
        polybar
        rofi
      ];
    };
  };

  programs.ssh.startAgent = true;
  users.users.bojo = {
    isNormalUser = true;
    extraGroups = [ "audio" "input" "sound" "tty" "video" "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDgsj2qFf0RXuFYvq5XM0ImTni8qOmQQNKZaQDSzMUoMUEVwZdXvFykOMr9BDhwvRyobKv6gSI3bmcnoFsrkf+U8td9KVtk6Fw7D7fwkCpQp7sUzrGrEi4cN6gdaFh9IYJP86zCnE2/Q2cDGtHWZjtQwvBt9pURPMgA83oAcwpierPDVTLDH1qX8SH7WMEfsQ3s+y70/Bp/uQ9RkykrtZawCBjR/j6g5ekoO7X5SZQBsYq12VBOGdcNQ6alHqjGcGPG2TEN7q23Wj9ITyMPKy+F8fd7t5ekieLaX/BfaTTK7UWoL7Cj3dcxVT25ZE5yyV2S6/J4uZ4egZSTs/uS4f2hqCRRAQ0dVDO3gIBTo9vEB2B065Iisj0dlsqr/OOrarp2yeFkwUF2ApD0ej5G2MgStI0yTI9i5Oyl8v9lXv07uV1vI9uUxzYpBPiD+yT9oIbstoXzkYZpgVaqKwn1SNdqk7H18Qoq7pjAmByMgta1BxChajq7R0MwvPeJbcNT2FFO+WE8HPXU0mLPGcjm7srbvsf9PaPrOsC8Gq4li1IPLgF0WoBjFLaDse0DbWl5GPrpoL7DbdkxcTOd8PX7ALnxwHZdICsZnI0ef9fyRDnRLmI3tR1+uS1sgkgdNAe5XqToq8ohCZ5IgW2ZG1zLCkwMyGd9MKh6wMKoeor/uHAiTQ== bojo@nixos" ];
    shell = pkgs.fish;
  };

  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  system.stateVersion = "21.05";
}

