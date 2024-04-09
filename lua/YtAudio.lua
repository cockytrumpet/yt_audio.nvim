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
	"-volume",
	"20",
	"-loglevel",
	"quiet",
	"-",
}

M.opts = {
	notifications = true,
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

M.stop = function()
	local function stop_process(component)
		if component then
			if M.opts.notifications then
				vim.notify("Stopping " .. component)
			end
			component.kill(component, "sigterm")
		end
	end

	stop_process(M.Downloader)
	stop_process(M.Player)

	M.title = ""
	M.url = ""

	M.redraw()
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

		if M.opts.notifications == true then
			vim.notify(M.title)
		end
	end):wait()

	M.redraw()
	M.playURL()
end

M.playURL = function()
	local pipe = vim.loop.new_pipe(true)

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
		args = M.ffplay_args,
		stdio = { pipe, nil, nil },
	}, function() end)
end

return M
