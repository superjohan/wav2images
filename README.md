# wav2images

Generate images based on the waveform of an audio file. More features will be added as needed.

No exceptions are handled, so any and all errors crash the app.

## Example config

```json
{
    "input_file": "/Users/rm/Desktop/pink master video.wav",
    "output_dir": "/Users/rm/master1",
    "sample_rate": 44100,
    "channels": 1,
    "frame_rate": 60,
    "wave_color": "000000",
    "background_color": "FFFF19",
    "line_width": 50,
    "test": true
}
```

## ffmpeg tips

image sequence to ok quality h264:

    ffmpeg -r 60 -f image2 -pattern_type glob -i "*?png" -vcodec libx264 -crf 20 -pix_fmt yuv420p output.mp4

add aac audio:

    ffmpeg -i output.mp4 -i ~/Desktop/acid-video.wav -c:v copy -c:a aac -b:a 320k output2.mp4
