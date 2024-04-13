-- This module provides a high-level interface for playing audio from YouTube videos in Neovim.
local M = {}

M.yt_audio = require("yt_audio.yt_audio")

---@param opts? table<any, any>
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

-- Only called externally.
---@return string @formatted string or ""
M.get_title = function()
	return M.yt_audio.get_title()
end

---@param args? string the URL of the YouTube video
M.play = function(args)
	if not M.yt_audio.get_url(args) then
		return
	end

	M.yt_audio.play_url()
end

M.stop = function()
	return M.yt_audio.stop()
end

return M
