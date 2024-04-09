# YtAudio

Simple NeoVim plugin to stream audio from YouTube.

## Dependencies

- yt-dlp
- ffmpeg

## Lazy spec

```lua
{
  'cockytrumpet/YtAudio',
  init = function()
    vim.api.nvim_set_keymap('n', '<leader>yp', ':YAPlay<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>y1', ':YAPlay https://www.youtube.com/watch?v=dQw4w9WgXcQ&pp=ygUJcmljayByb2xs<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>ys', ':YAStop<CR>', { noremap = true, silent = true })
  end,
  event = 'VeryLazy',
  opts = true,
}
```

### default opts

```lua
{
  notifications = true, -- turn off start/stop notifications
  volume = 50,          -- 0-100
  icon = ""            -- set any icon
}
```

## User Commands

| Command | Arguments | Keymap       | Description                                    |
| ------- | --------- | ------------ | ---------------------------------------------- |
| YTPlay  | \<url\>   | user-defined | Start playing (prompt for url if not provided) |
| YTStop  |           | user-defined | Stop playing                                   |

## Integrations

The title of the currently playing audio can be retrieved with the _getTitle_
function for use in other plugins. The status/tabline are redrawn when the title
changes.

Here is an example for [bufferline](https://github.com/akinsho/bufferline.nvim):

```lua
bufferline.setup {
  -- other stuff
  options = {
    custom_areas = {
      right = function()
        local YtAudioTitle = require('YtAudio').getTitle()
        if YtAudioTitle then
          -- return { { text = YtAudioTitle, guifg = '#FF0000' } }
          return { { text = YtAudioTitle } }
        end
      end,
    },
  },
}
```
