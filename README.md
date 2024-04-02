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
| YTPlay  |           | <leader>yp   | Start playing (ask for url) |
| YTStop  |           | <leader>ys   | Stop playing                |
| YTFav   | <url>     | user defined | Start playing favorite      |
