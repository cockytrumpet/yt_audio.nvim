local M = {
	Downloader = nil,
	Player = nil,
	opts = {
		notifications = true,
	},

	stop = function(self)
		if self.Downloader then
			self.Downloader.kill(self.Downloader, "sigterm")
			self.Downloader = nil
		end
		if self.Player then
			if self.opts.notifications then
				vim.notify("Stopping YtAudio")
			end
			self.Player.kill(self.Player, "sigterm")
			self.Player = nil
			vim.g.YtAudioTitle = ""
		end
	end,

	play = function(self, args)
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
			"-volume",
			"20",
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
			if M.opts.notifications then
				vim.notify(title)
			end
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
		--  , 
		return " " .. vim.g.YtAudioTitle
	end,

	setup = function(self, opts)
		M.opts = vim.tbl_deep_extend("force", M.opts, opts)

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
