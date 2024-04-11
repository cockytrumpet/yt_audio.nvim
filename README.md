# yt_audio

Simple Neovim plugin to stream audio from YouTube.

## Dependencies

- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [ffmpeg](https://ffmpeg.org/download.html)

## Lazy plugin spec

```lua
{
  'cockytrumpet/YtAudio',
  init = function()
    vim.api.nvim_set_keymap('n', '<leader>yp', ':YAPlay<CR>', { noremap = true, silent = true }) -- prompt for url
    vim.api.nvim_set_keymap('n', '<leader>y1', ':YAPlay https://www.youtube.com/watch?v=dQw4w9WgXcQ&pp=ygUJcmljayByb2xs<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>ys', ':YAStop<CR>', { noremap = true, silent = true })
  end,
  event = 'VeryLazy',
  opts = true,
}
```

### Changing default options

```lua
opts = {
  volume = 50,          -- 0-100
  icon = ""            -- set any font icon or emoji:  , 🎧, 
  notifications = true, -- toggle notifications
  ytdlp_args = {        -- yt-dlp arguments
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
  ffplay_args = {      -- ffplay arguments
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
```

## User Commands

| Command | Arguments | Keymap       | Description                                    |
| ------- | --------- | ------------ | ---------------------------------------------- |
| YTPlay  | \<url\>   | user-defined | Start playing (prompt for url if not provided) |
| YTStop  |           | user-defined | Stop playing                                   |

## Integrations

The title of the currently playing audio can be retrieved with the _get_title_ function for use in other plugins.

Here is an example for [bufferline](https://github.com/akinsho/bufferline.nvim):

```lua
bufferline.setup {
  -- other stuff
  options = {
    custom_areas = {
      right = function()
        local title = require('yt_audio').get_title()
        if title then
          -- return { { text = title, guifg = '#FF0000' } }
          return { { text = title } }
        end
      end,
    },
  },
}
```
