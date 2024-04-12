local N = {}

N.state = require("yt_audio.state")

N.get_url = function(args)
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
		return false
	else
		if N.state.url ~= "" or N.state.title ~= "" then
			N.reset()
			while N.state.url ~= "" or N.state.title ~= "" do
				vim.wait(10)
			end
		end
		N.state.url = url
		return true
	end
end

N.play_url = function()
	local pipe = vim.loop.new_pipe(true)
	local new_ffplay_args = { "-volume", N.opts.volume, "-" }

	---@diagnostic disable-next-line: missing-fields
	N.state.Downloader = vim.loop.spawn("yt-dlp", {
		args = vim.list_extend(vim.list_slice(N.opts.ytdlp_args), { N.state.url }),
		stdio = { nil, pipe, nil },
	}, function()
		-- NOTE: Can I grab the title here?
		if pipe then
			pipe:close()
		end
	end)

	---@diagnostic disable-next-line: missing-fields
	N.state.Player = vim.loop.spawn("ffplay", {
		args = vim.list_extend(vim.list_slice(N.opts.ffplay_args), new_ffplay_args),
		stdio = { pipe, nil, nil },
	}, function() end)

	N.set_title()
end

N.set_title = function()
	vim.system({ "yt-dlp", "-q", "--no-warnings", "-f", "234", "--print", "fulltitle", N.state.url }, {
		text = true,
	}, function(out)
		if out.code ~= 0 then
			vim.notify(out.stderr)
			N.state.url = ""
			return
		end
		N.state.title, _ = string.gsub(out.stdout, "\n$", " ")
	end):wait()
end

N.get_title = function()
	if N.state.title == "" then
		return ""
	end
	return N.opts.icon .. " " .. N.state.title
end

N.notify = function(message)
	if N.opts.notifications then
		vim.notify(message)
	end
end

N.reset = function()
	local stop_process = function(component)
		if component then
			component.kill(component, "sigterm")
		end
	end

	stop_process(N.state.Downloader)
	stop_process(N.state.Player)

	N.state.title = ""
	N.state.url = ""
	N.state.Downloader = nil
	N.state.Player = nil

	N.redraw()
end

N.redraw = function()
	vim.cmd("redrawtabline")
	vim.cmd("redrawstatus")
end

return N
