local wezterm = require("wezterm")

local M = {}

local function tableMerge(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				tableMerge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

local config = {
	alt_screen = true,
	padding_rules = {},
}

M.apply_to_config = function(c, opts)
	if not opts then
		opts = {}
	end

	opts = tableMerge(config, opts)

	local default_padding = c.window_padding

	wezterm.on("update-status", function(window, pane)
		local fgp = pane:get_foreground_process_info() or { name = "" }

		if opts.padding_rules[fgp.name] ~= nil then
			window:set_config_overrides({
				window_padding = opts.padding_rules[fgp.name],
			})
		elseif opts.alt_screen and pane:is_alt_screen_active() then
			window:set_config_overrides({
				window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
			})
		else
			window:set_config_overrides({
				window_padding = default_padding,
			})
		end
	end)
end

return M
