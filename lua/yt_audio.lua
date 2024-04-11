local M = {}

M.opts = require("yt_audio.opts")
M.utils = require("yt_audio.utils")
M.state = {
	title = "",
	url = "",
}

M.setup = function(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

	vim.api.nvim_create_user_command("YAPlay", function(args)
		require("yt_audio").play(args.args)
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("YAStop", function()
		require("yt_audio").stop()
	end, {})
end

M.get_title = function()
	return M.utils.get_title(M)
end

M.play = function(args)
	local url = args

	if url == "" then
		vim.ui.input({
			prompt = "Enter URL: ",
		}, function(input)
			url = input
		end)
	end

	if url == "" then
		vim.notify("No URL provided")
		return
	else
		if M.state.url ~= "" or M.state.title ~= "" then
			M.reset()
			while M.state.url ~= "" or M.state.title ~= "" do
				vim.wait(10)
			end
		end
		M.state.url = url
	end

	M.utils.play_url(M)
	M.utils.set_title(M)
	M.utils.redraw()
	M.utils.notify(M, "Playing " .. M.state.title)
end

M.stop = function()
	M.reset()
	M.utils.notify(M, "Stopped")
end

M.reset = function()
	local stop_process = function(component)
		if component then
			component.kill(component, "sigterm")
		end
	end

	stop_process(M.state.Downloader)
	stop_process(M.state.Player)

	M.state.title = ""
	M.state.url = ""
	M.state.Downloader = nil
	M.state.Player = nil

	M.utils.redraw()
end

return M
