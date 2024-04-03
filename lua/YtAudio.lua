local M = {
	Downloader = nil,
	Player = nil,

	stop = function(self, notify)
		self = self or M
		if self.Downloader then
			self.Downloader.kill(M.Downloader, "sigterm")
			self.Downloader = nil
		end
		if self.Player then
			if notify then
				vim.notify("Stopping YtAudio")
			end
			self.Player.kill(M.Player, "sigterm")
			self.Player = nil
			vim.g.YtAudioTitle = ""
		end
	end,

	play = function(self, args)
		self = self or M

		local url = args
		if url == "" then
			vim.ui.input({
				prompt = "Enter URL: ",
			}, function(choice)
				url = choice
			end)
		end

		if url == "" then
			vim.notify("No URL provided")
			return
		end

		local downloader = {
			-- "yt-dlp",
			"-q",
			"--no-warnings",
			"-f",
			"234",
			"-o",
			"-",
			url,
		}
		local player = {
			-- "ffplay",
			"-i",
			"-vn",
			"-nodisp",
			"-autoexit",
			"-loglevel",
			"quiet",
			"-",
		}

		require("YtAudio").stop(self, false)

		local title = ""
		vim.system({ "yt-dlp", "-q", "--no-warnings", "-f", "234", "--print", "fulltitle", url }, {
			text = true,
		}, function(out)
			title, _ = string.gsub(out.stdout, "\n$", " ")
			vim.notify(title)
			vim.g.YtAudioTitle = title
		end)

		local pipe = vim.loop.new_pipe(true)

		---@diagnostic disable-next-line: missing-fields
		self.Player = vim.loop.spawn("ffplay", {
			args = player,
			stdio = { pipe, nil, nil },
		}, function()
			if pipe then
				pipe:close()
			end
		end)

		---@diagnostic disable-next-line: missing-fields
		self.Downloader = vim.loop.spawn("yt-dlp", {
			args = downloader,
			stdio = { nil, pipe, nil },
		}, function() end)
	end,

	getTitle = function()
		if vim.g.YtAudioTitle == "" then
			return ""
		end
		return " " .. vim.g.YtAudioTitle
	end,

	setup = function()
		local self = self or M

		vim.api.nvim_create_user_command("YAPlay", function()
			require("YtAudio").play(self, "")
		end, {})

		vim.api.nvim_create_user_command("YAFav", function(args)
			if args.args == "" then
				vim.notify("No URL provided")
				return
			end
			require("YtAudio").play(self, args.args)
		end, { nargs = "?" })

		vim.api.nvim_create_user_command("YAStop", function()
			require("YtAudio").stop(self, true)
		end, {})
	end,
}

return M
