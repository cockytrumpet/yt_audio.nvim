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
		-- url is appended to this table
	},
	ffplay_args = {
		"-i",
		"-vn",
		"-nodisp",
		"-autoexit",
		"-loglevel",
		"quiet",
		-- "-" is appended after volume options
	},
}

return M
