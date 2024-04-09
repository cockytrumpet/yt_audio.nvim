local M = {}

M.ytdlp_args = {
	"-q",
	"--no-warnings",
	"-f",
	"234",
	"-o",
	"-",
	-- url is appended to this table
}

M.ffplay_args = {
	"-i",
	"-vn",
	"-nodisp",
	"-autoexit",
	"-loglevel",
	"quiet",
	-- "-" is appended after volume options
}

M.opts = {
	notifications = true,
	volume = 50,
	icon = "", --  , 
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
		if M.url ~= "" or M.title ~= "" then
			M.stop()
			while M.url ~= "" or M.title ~= "" do
				vim.wait(10)
			end
		end
		M.url = url
	end

	vim.system({ "yt-dlp", "-q", "--no-warnings", "-f", "234", "--print", "fulltitle", M.url }, {
		text = true,
	}, function(out)
		if out.code ~= 0 then
			vim.notify(out.stderr)
			M.url = ""
			return
		end

		M.title, _ = string.gsub(out.stdout, "\n$", " ")

		M.notify(M.title)
	end):wait()

	M.redraw()
	M.playURL()
end

M.playURL = function()
	local pipe = vim.loop.new_pipe(true)
	local new_ffplay_args = { "-volume", M.opts.volume, "-" }

	---@diagnostic disable-next-line: missing-fields
	M.Downloader = vim.loop.spawn("yt-dlp", {
		args = vim.list_extend(vim.list_slice(M.ytdlp_args), { M.url }),
		stdio = { nil, pipe, nil },
	}, function()
		if pipe then
			pipe:close()
		end
	end)

	---@diagnostic disable-next-line: missing-fields
	M.Player = vim.loop.spawn("ffplay", {
		args = vim.list_extend(vim.list_slice(M.ffplay_args), new_ffplay_args),
		stdio = { pipe, nil, nil },
	}, function() end)
end

M.notify = function(message)
	if M.opts.notifications then
		vim.notify(message)
	end
end

M.stop = function()
	M.notify("Stopping")

	local stop_process = function(component)
		if component then
			component.kill(component, "sigterm")
		end
	end

	stop_process(M.Downloader)
	stop_process(M.Player)

	M.title = ""
	M.url = ""

	M.redraw()
end

M.getTitle = function()
	if M.title == "" then
		return M.title
	end

	return M.opts.icon .. " " .. M.title
end

M.redraw = function()
	vim.cmd("redrawtabline")
	vim.cmd("redrawstatus")
end

return M
