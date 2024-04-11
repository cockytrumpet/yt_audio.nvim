local M = {
	notifications = true,
	volume = 50,
	icon = "", --  , 
	ytdlp_args = {
		"-q",
		"--no-warnings",
		"-f",
		"234",
		"-o",
		"-",
		-- <url>
	},
	ffplay_args = {
		"-i",
		"-vn",
		"-nodisp",
		"-autoexit",
		"-loglevel",
		"quiet",
		-- -volume
		-- <0-100>
		-- "-"
	},
}

return M
