local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.unix_domains = {
	{
		name = "unix",
		socket_path = "/run/wezterm/wezterm-mux.sock",
		no_serve_automatically = true,
	},
}

config.daemon_options = {
	pid_file = "/run/wezterm-mux-server.pid",
}

return config
