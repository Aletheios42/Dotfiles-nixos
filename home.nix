
  { config, pkgs, ... };

{
	home.username = "alehteios42";
	home.homeDirectory = "/home/aletheios42";


	# --- Paquetes ---
	home.packages = with pkgs; [
		kitty
		rofi
		dmenu
		firefox
		
		#sway
		swaybg
		waybar
		grim
		slurp
		wl-clipboard
	];
	# --- i3 ---
	xsession.windowManager.i3 = {
		enable = true;
		package = pkgs.i3;
		config = {
			modifier = "Mod4";
			terminal = "kitty";
			menu = "dmenu_run";
			bars = [ { statusCommand = "${pkgs.i3status}/bin/i3status";} ]
		};
	};
	# --- sway ---
	wayland.windowManager.sway = {
		enable = true;
		config = {
			modifier = "Mod4";
			terminal = "kitty";
			menu = "rofi -show drun";
		};

		outputs = {
			"*" = { bg = "#000000 solid_color"; };
			bars = [ { command = "${pkgs.waybar}/bin/waybar"}; ];
		};
	};

	programs.waybar.enable = true;

	home.stateVersion = "25.11";
};
