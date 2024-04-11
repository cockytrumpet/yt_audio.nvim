local M = {}

M.play_url = function(yt_audio)
	local pipe = vim.loop.new_pipe(true)
	local new_ffplay_args = { "-volume", yt_audio.opts.volume, "-" }

	---@diagnostic disable-next-line: missing-fields
	yt_audio.state.Downloader = vim.loop.spawn("yt-dlp", {
		args = vim.list_extend(vim.list_slice(yt_audio.opts.ytdlp_args), { yt_audio.state.url }),
		stdio = { nil, pipe, nil },
	}, function()
		-- NOTE: Can I grab the title here?
		if pipe then
			pipe:close()
		end
	end)

	---@diagnostic disable-next-line: missing-fields
	yt_audio.state.Player = vim.loop.spawn("ffplay", {
		args = vim.list_extend(vim.list_slice(yt_audio.opts.ffplay_args), new_ffplay_args),
		stdio = { pipe, nil, nil },
	}, function() end)
end

M.set_title = function(yt_audio)
	vim.system({ "yt-dlp", "-q", "--no-warnings", "-f", "234", "--print", "fulltitle", yt_audio.state.url }, {
		text = true,
	}, function(out)
		if out.code ~= 0 then
			vim.notify(out.stderr)
			yt_audio.state.url = ""
			return
		end
		yt_audio.state.title, _ = string.gsub(out.stdout, "\n$", " ")
	end):wait()
end

M.get_title = function(yt_audio)
	if yt_audio.state.title == "" then
		return ""
	end
	return yt_audio.opts.icon .. " " .. yt_audio.state.title
end

M.notify = function(yt_audio, message)
	if yt_audio.opts.notifications then
		vim.notify(message)
	end
end

M.redraw = function()
	vim.cmd("redrawtabline")
	vim.cmd("redrawstatus")
end

return M
