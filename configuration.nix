{
  config,
  pkgs,
  lib,
  ...
}:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
{ 
  

  imports = [
    ./hardware-configuration.nix
    ./zapret.nix
  ];

  virtualisation.docker.enable = true;
  zramSwap.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.bluetooth = {
  	enable = true;
  	powerOnBoot = false;
  };
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];


  boot.kernelParams = ["amd_pstate=active"]; 
  boot.kernelModules = ["amd-pstate"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = ["nvidia" "amdgpu"];

  hardware.amdgpu.initrd.enable = true;

  services.fstrim.enable = lib.mkDefault true;
  hardware.nvidia = {
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  	open = false;
  	nvidiaSettings = true;
  	# package = config.boot.kernelPackages.nvidiaPackages.stable;

  	prime = {
  	  offload = {
  	    enable = true;
  	    enableOffloadCmd = true;
  	  };
  	
  	  amdgpuBusId = "PCI:5:0:0";
  	  nvidiaBusId = "PCI:1:0:0";
  	};
  	package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.firewall = {
  	enable = true;
  	allowedTCPPorts = [ 80 443 3000 5173 8080 ];
 	allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
  	];
  };
  
  time.timeZone = "Asia/Yekaterinburg";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.xserver.xkb = {
    layout = "us,ru";
    variant = "";
    options = "grp:win_space_toogle";
  };

  # KDE 6
  # services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "darwin";
  # services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;

  # FlatPak
  # services.flatpak.enable = true;

  # Define a user account. Dont forget to set a password with ‘passwd’.
  users.users.darwin = {
    isNormalUser = true;
    description = "darwin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  systemd.services.nginx.serviceConfig = {
    ReadWritePaths = [ "/var/log/nginx/" ];
    ProtectHome = false;
    ProtectSystem = lib.mkForce false;
  };
  services.nginx = {
    enable = true;
    enableReload = true;
    package = pkgs.nginxStable.override { openssl = pkgs.libressl; };
    defaultMimeTypes = builtins.readFile /home/darwin/Documents/nginx/mime.types;
    config = builtins.readFile /home/darwin/Documents/nginx/nginx.conf;
  };

  services.mysql = {
    enable = true;
    package = pkgs.mysql84;
  };

  services.postgresql = {
    enable = true;
    package = unstable.postgresql;
    ensureDatabases = [ "plusagent" ];
    enableTCPIP = true;
	authentication = pkgs.lib.mkOverride 10 ''
  		local all all              trust
  		host  all all 127.0.0.1/32 trust
  		host  all all ::1/128      trust
	'';
  };

  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      config.credential.helper = "libsecret";
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;

    zsh = {
      enable = true;
      ohMyZsh.enable = true;
      promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    };

    direnv = {
      enable = true;
      silent = true;
    };

    nix-ld = {
      enable = true;
      libraries = [ ];
    };

	appimage = {
 	  enable = true;
 	  binfmt = true;
	};
  };

  environment.systemPackages = with pkgs; [
    micro-with-wl-clipboard
    git
    zsh
    zsh-powerlevel10k
    unstable.firefox
    chromium
    xdg-utils
    unstable.vscode
    kdePackages.kate
    unstable.qbittorrent
    unstable.telegram-desktop

    vesktop
	
    syncplay
    obsidian
    dbeaver-bin
    unstable.sqlite
    glogg

	heroic
    unstable.nginx
    unstable.lutris
    # unstable.jdk21_headless
    unstable.ytdownloader
    unstable.r2modman
    nixfmt-rfc-style
    unstable.byedpi
    unstable.vlc
    unstable.mpv
    nixpkgs-fmt
    unstable.zapret
    obs-studio
    kdePackages.filelight
	kdePackages.partitionmanager
	exfat
	exfatprogs
    busybox
    wl-color-picker
	mangohud

	pgadmin4-desktopmode
	xarchiver
	p7zip

	libreoffice-qt6
	hunspell
	hunspellDicts.ru_RU
	hunspellDicts.en_US

	kdePackages.kdenlive
	pitivi
	mkvtoolnix

	xclip

	postman
	unstable.git-filter-repo

	ventoy-full-qt
	
	unstable.protonup-qt
	unstable.umu-launcher

	unrar
	espeak

	google-chrome
	go
	zoom-us
	concurrently
	slack
  ];

	nixpkgs.config.permittedInsecurePackages = [
	                "ventoy-qt5-1.1.05"
	              ];
	


  zapret.enable = true;  

  system.stateVersion = "24.05";
}
