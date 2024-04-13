-- This module provides state management and utility functions for the yt_audio module.
local N = {}

N.state = require("yt_audio.state")

-- The message to display.
--@param message string
local notify = function(message)
	if N.opts.notifications then
		vim.notify(message)
	end
end

--@return string @The title of the YouTube video, or an empty string if no title is set.
local get_title = function()
	if N.state.title == "" then
		return ""
	end
	return N.opts.icon .. " " .. N.state.title
end

-- redraw the tabline and statusline.
local redraw = function()
	vim.cmd("redrawtabline")
	vim.cmd("redrawstatus")
	if N.state.debug_win or N.opts.dev_mode then
		N.debug()
	end
end

-- reset the state of the module.
local reset = function()
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

	redraw()
end

-- If no URL is provided, it prompts the user to enter one.
-- If a URL is already stored in the state, it resets the state before storing the new URL.
--@param args string @The URL of the YouTube video.
--@return boolean @true if a URL is provided, false otherwise.
local get_url = function(args)
	local url = args or ""

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
	end

	if N.state.url ~= "" or N.state.title ~= "" then
		reset()
		while N.state.url ~= "" or N.state.title ~= "" do
			vim.wait(10)
		end
	end
	N.state.url = url
	return true
end

-- Store the title of the YouTube video.
-- It uses the yt-dlp command-line program to get the title.
local set_title = function()
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

-- Play the audio of the YouTube video.
-- It uses the yt-dlp command-line program to download the audio and ffplay to play it.
local play_url = function()
	local pipe = vim.loop.new_pipe(true)
	local new_ffplay_args = { "-volume", N.opts.volume, "-" }

	---@diagnostic disable-next-line: missing-fields
	N.state.Downloader = vim.loop.spawn("yt-dlp", {
		args = vim.list_extend(vim.list_slice(N.opts.ytdlp_args), { N.state.url }),
		stdio = { nil, pipe, nil },
	}, function()
		if pipe then
			pipe:close()
		end
	end)

	---@diagnostic disable-next-line: missing-fields
	N.state.Player = vim.loop.spawn("ffplay", {
		args = vim.list_extend(vim.list_slice(N.opts.ffplay_args), new_ffplay_args),
		stdio = { pipe, nil, nil },
	}, function() end)

	set_title()
	redraw()

	if N.state.url ~= "" and N.state.title ~= "" then
		notify("Playing " .. N.state.title)
	end
end

-- reset the state of the module and notify
local stop = function()
	reset()
	notify("Stopped")
end

-- display the state of the module in a new window.
---@param args? string 'stop' to clean up the debug window
local debug = function(args)
	if args == "stop" then
		if N.state.debug_win then
			vim.api.nvim_win_close(N.state.debug_win, true)
			N.state.debug_win = nil
		end
		if N.state.debug_buf then
			vim.api.nvim_buf_delete(N.state.debug_buf, { force = true })
			N.state.debug_buf = nil
		end
		return
	end

	if not N.state.debug_buf then
		local newbuf = vim.api.nvim_create_buf(false, true)

		vim.api.nvim_set_option_value("filetype", "lua", { buf = newbuf })
		vim.api.nvim_set_option_value("buflisted", false, { buf = newbuf })
		vim.keymap.set("n", "q", function()
			require("yt_audio.yt_audio").debug("stop")
		end, { buffer = newbuf })

		N.state.debug_buf = newbuf
	end

	if not N.state.debug_win then
		local opts = {
			relative = "editor",
			width = 33,
			height = 41,
			col = vim.api.nvim_get_option_value("columns", {}),
			row = 1,
			anchor = "NE",
			style = "minimal",
			border = "single",
		}

		N.state.debug_win = vim.api.nvim_open_win(N.state.debug_buf, true, opts)
		vim.api.nvim_set_option_value("wrap", true, { win = N.state.debug_win })
	end

	local cmd = "lua=require 'yt_audio'"
	local lines = vim.split(vim.api.nvim_exec(cmd, true), "\n", { plain = true })
	vim.api.nvim_buf_set_lines(N.state.debug_buf, 0, -1, false, lines)
end

N.play_url = play_url
N.stop = stop
N.get_title = get_title
N.get_url = get_url
N.debug = debug
return N
