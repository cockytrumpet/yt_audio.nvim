# YtAudio

Simple NeoVim plugin to stream audio from YouTube.

## Dependencies

- yt-dlp
- ffmpeg

## Lazy spec

```lua
{
  'cockytrumpet/YtAudio',
  event = 'VeryLazy',
  opts = true,
}
```

## User Commands

| Command | Arguments | Keymap     | Description                        |
| ------- | --------- | ---------- | ---------------------------------- |
| YTPlay  | url       | <leader>yp | If not provided, a default is used |
| YTStop  |           | <leader>ys | Stop playing                       |
