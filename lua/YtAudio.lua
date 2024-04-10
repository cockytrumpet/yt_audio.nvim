local M = {}

M.opts = require("YtAudio.opts")
M.utils = require("YtAudio.utils")
M.state = {
	title = "",
	url = "",
}

M.setup = function(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

	vim.api.nvim_create_user_command("YAPlay", function(args)
		require("YtAudio").play(args.args)
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("YAStop", function()
		require("YtAudio").stop()
	end, {})
end

M.getTitle = function()
	return M.utils.getTitle(M)
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
			M.stop()
			while M.state.url ~= "" or M.state.title ~= "" do
				vim.wait(10)
			end
		end
		M.state.url = url
		M.utils.notify(M, "Playing " .. M.state.url)
	end

	M.utils.playURL(M)
	M.utils.setTitle(M)
	M.utils.redraw()
end

M.stop = function()
	M.utils.notify(M, "Stopping")

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
