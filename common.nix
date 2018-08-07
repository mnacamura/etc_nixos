# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  fileSystems = let
    # Mount options for Btrfs on SSD
    commonMountOptions = [
      "commit=60"
      "compress=lzo"
      "defaults"
      "noatime"
    ];
  in {
    "/".options = commonMountOptions;
    "/nix".options = commonMountOptions; "/var".options = commonMountOptions;
    "/home".options = commonMountOptions;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
  };

  hardware = {
    # cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
  };

  networking = {
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Tokyo";

  i18n = {
    # Srcery: https://github.com/srcery-colors/srcery-vim
    consoleColors = [
      "1C1B19" "EF2F27" "519F50" "FBB829" "2C78BF" "E02C6D" "0AAEB3" "918175"
      "2D2C29" "F75341" "98BC37" "FED06E" "68A8E4" "FF5C8F" "53FDE9" "FCE8C3"
    ];
    consoleKeyMap = "us";  # conflicts with consoleUseXkbConfig
    # consoleUseXkbConfig = true;
    defaultLocale = "ja_JP.UTF-8";
    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    };
  };

  fonts = {
    fonts = with pkgs; [
      source-serif-pro
      source-sans-pro
      source-code-pro
      source-han-serif-japanese
      source-han-sans-japanese
      noto-fonts-emoji
      font-awesome-ttf
      fira-code
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Source Serif Pro"
        "Source Han Serif JP"
      ];
      sansSerif = [
        "Source Sans Pro"
        "Source Han Sans JP"
      ];
      monospace = [
        "Source Code Pro"
      ];
    };
  };

  nix = {
    trustedUsers = [ "@wheel" ];
    # useSandbox = true;
    nixPath = [
      # "$HOME/.nix-defexpr/channels"
      "nixpkgs=/var/repos/nixpkgs"
      # "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };

  environment = {
    systemPackages = with pkgs; let
      desktopPkgs = [
        btops
        dunst
        feh
        lightlocker
        rofi
        termite
        yabar-unstable
        pavucontrol
      ] ++ gtkPkgs;
      gtkPkgs = [
        gtk3 # Required to use Emacs key bindings in GTK apps
        arc-theme
        papirus-icon-theme
        numix-cursor-theme
      ];
      miscPkgs = [
        scrot
      ];
    in desktopPkgs ++ miscPkgs;
    profileRelativeEnvVars = {
      MANPATH = [ "/man" "/share/man" ];
    };
    variables = {
      # Apps launched in ~/.xprofile need it if they use SVG icons.
      GDK_PIXBUF_MODULE_FILE = "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";
    };
  };

  programs = let
    # environment.shellAliases cannot be initialized cleanly
    commonShellAliases = {
      ls = "ls -Fh --color --time-style=long-iso";
      cp = "cp -i";
      mv = "mv -i";
      diff = "diff --color";
    };
  in { # Shells
    bash.shellAliases = commonShellAliases // {
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -la";
    };
    fish.enable = true;
    fish.shellAliases = commonShellAliases;
    fish.shellInit = ''
      umask 077
    '';
    fish.interactiveShellInit = ''
      abbr --add la 'ls -a'
      abbr --add ll 'ls -l'
      abbr --add lla 'ls -la'
      abbr --add h history
      abbr --add d  dirh
      abbr --add nd nextd
      abbr --add pd prevd
    '';
  } // { # Others
    # ccache.enable = true;  # cannot use binary caches if ccache is enabled
    vim.defaultEditor = true;
  };

  services = {
    chrony.enable = true;
    fstrim.enable = true;
    autofs.enable = true;
    autofs.autoMaster = let
      mapConf = pkgs.writeText "auto" ''
        usbdisk -fstype=noauto,async,group,gid=100,fmask=117,dmask=007 :/dev/sda1
      '';
    in ''
      /media file:${mapConf} --timeout=10
    '';
    printing.enable = true;
    printing.drivers = [ pkgs.gutenprint ];
  };

  services.xserver = {
    enable = true;
    # exportConfiguration = true;
    layout = "us";
    # Enable bspwm environment.
    windowManager.bspwm.enable = true;
    desktopManager.default = "none";
    windowManager.default = "bspwm";
    windowManager.bspwm.sxhkd.configFile = pkgs.runCommand "sxhkdrc" {} ''
      cp ${./data/config/sxhkdrc} $out
    '';
  };

  services.compton = {
    enable = true;
    fade = true;
    fadeDelta = 5;
    fadeSteps = [ "0.03" "0.03" ];
    shadow = true;
    shadowOpacity = "0.46";
  };

  services.xserver.displayManager.lightdm = {
    enable = true;
    background = let
      backgroundImage = pkgs.runCommand "login-background" {} ''
        cp ${./data/pixmaps/login_background.jpg} $out
      '';
    in "${backgroundImage}";
    greeters.mini.enable = true;
    greeters.mini.user = "mnacamura";
    greeters.mini.extraConfig = ''
      [greeter-theme]
      font = Source Code Pro Medium
      font-size = 13pt
      text-color = "#fce8c3"
      error-color = "#f75341"
      window-color = "#d75f00"
      border-width = 0
      layout-space = 40
      password-color = "#fce8c3"
      password-background-color = "#1c1b19"
    '';
  };

  users.users.mnacamura = {
    description = "Mitsuhiro Nakamura";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = "/run/current-system/sw/bin/fish";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
