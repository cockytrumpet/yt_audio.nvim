local M = {}

M.playURL = function(YtAudio)
	local pipe = vim.loop.new_pipe(true)
	local new_ffplay_args = { "-volume", YtAudio.opts.volume, "-" }

	---@diagnostic disable-next-line: missing-fields
	YtAudio.state.Downloader = vim.loop.spawn("yt-dlp", {
		args = vim.list_extend(vim.list_slice(YtAudio.opts.ytdlp_args), { YtAudio.state.url }),
		stdio = { nil, pipe, nil },
	}, function()
		if pipe then
			pipe:close()
		end
	end)

	---@diagnostic disable-next-line: missing-fields
	YtAudio.state.Player = vim.loop.spawn("ffplay", {
		args = vim.list_extend(vim.list_slice(YtAudio.opts.ffplay_args), new_ffplay_args),
		stdio = { pipe, nil, nil },
	}, function() end)
end

M.setTitle = function(YtAudio)
	vim.system({ "yt-dlp", "-q", "--no-warnings", "-f", "234", "--print", "fulltitle", YtAudio.state.url }, {
		text = true,
	}, function(out)
		if out.code ~= 0 then
			vim.notify(out.stderr)
			YtAudio.state.url = ""
			return
		end
		YtAudio.state.title, _ = string.gsub(out.stdout, "\n$", " ")
		M.notify(YtAudio, YtAudio.title)
	end):wait()
end

M.getTitle = function(YtAudio)
	if YtAudio.state.title == "" then
		return YtAudio.state.title
	end
	return YtAudio.opts.icon .. " " .. YtAudio.state.title
end

M.notify = function(YtAudio, message)
	if YtAudio.opts.notifications then
		vim.notify(message)
	end
end

M.redraw = function()
	vim.cmd("redrawtabline")
	vim.cmd("redrawstatus")
end

return M
