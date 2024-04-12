local M = {}

M.yt_audio = require("yt_audio.yt_audio")

M.setup = function(opts)
	local default_opts = require("yt_audio.opts")
	M.yt_audio.opts = vim.tbl_deep_extend("force", default_opts, opts or {})

	vim.api.nvim_create_user_command("YAPlay", function(args)
		require("yt_audio").play(args.args)
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("YAStop", function()
		require("yt_audio").stop()
	end, {})
end

M.get_title = function()
	return M.yt_audio.get_title()
end

M.play = function(args)
	if not M.yt_audio.get_url(args) then
		return
	end

	M.yt_audio.play_url()
	M.yt_audio.notify("Playing " .. M.yt_audio.state.title)
end

M.stop = function()
	M.yt_audio.reset()
	M.yt_audio.notify("Stopped")
end

return M
