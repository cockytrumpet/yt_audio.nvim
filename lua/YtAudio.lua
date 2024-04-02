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
		end
	end,

	play = function(self, args)
		self = self or M

		local url = args
		if url == "" then
			vim.ui.input({
				prompt = "Enter URL: ",
				-- default = "https://www.youtube.com/watch?v=abUT5IEkwrg",
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

		vim.notify("YtAudio playing " .. url)

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

	setup = function()
		self = self or M

		vim.api.nvim_create_user_command("YAPlay", function()
			require("YtAudio").play(self, "")
		end, {})
		vim.api.nvim_create_user_command("YAFav", function(args)
			if args.args == "" then
				vim.notify("No URL provided")
				return
			end
			require("YtAudio").stop(self, false)
			require("YtAudio").play(self, args.args)
		end, { nargs = "?" })
		vim.api.nvim_create_user_command("YAStop", function()
			require("YtAudio").stop(self, true)
		end, {})

		vim.api.nvim_set_keymap("n", "<leader>yp", ":YAPlay<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap("n", "<leader>ys", ":YAStop<CR>", { noremap = true, silent = true })
		vim.api.nvim_set_keymap(
			"n",
			"<leader>y1",
			":YAFav https://www.youtube.com/watch?v=abUT5IEkwrg<CR>",
			{ noremap = true, silent = true }
		)
		-- vim.api.nvim_set_keymap("n", "<leader>y2", ":YAFav 2nd_favorite_url <CR>", { noremap = true, silent = true })
	end,
}

return M
