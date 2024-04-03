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
    vim.api.nvim_set_keymap('n', '<leader>ys', ':YAStop<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>y1', ':YAFav https://www.youtube.com/watch?v=abUT5IEkwrg<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>y2', ':YAFav <url for second favorite>', { noremap = true, silent = true})
  end,
  event = 'VeryLazy',
  opts = true,
}
```

## User Commands

| Command | Arguments | Keymap       | Description                 |
| ------- | --------- | ------------ | --------------------------- |
| YTPlay  |           | \<leader\>yp | Start playing (ask for url) |
| YTStop  |           | \<leader\>ys | Stop playing                |
| YTFav   | \<url\>   | user defined | Start playing favorite      |

## Integrations

The title of the currently playing audio can be retrieved with the _getTitle_
function for use in other plugins. Here is an example for [bufferline](https://github.com/akinsho/bufferline.nvim):

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
