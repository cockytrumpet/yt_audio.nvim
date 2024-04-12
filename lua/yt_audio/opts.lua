local O = {
	notifications = true,
	volume = 50,
	icon = "", --  , 
	ytdlp_args = {
		"-q",
		"--no-warnings",
		"-f",
		"234",
		"-P",
		"temp:/tmp",
		"--downloader", -- stops '--Frag' files from being written to disk
		"ffmpeg",
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

return O
