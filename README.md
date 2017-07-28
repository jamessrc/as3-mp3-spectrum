# Mp3 Graphic Equalizer

![Mp3 Equalizer Player](images/mp3-equalizer-player.gif)

The animated gif above was generated from a quicktime screen section capture and converted with:
```bash
ffmpeg -i ac-dc.mov -vf palettegen palette.png
ffmpeg -ss 4 -t 48 -i ac-dc.mov -i palette.png -filter_complex paletteuse -r 15 mp3-equalizer-grid.gif
```

I brought this project back to life to show you some code.
This code is not up to par with the code I would write today.
I slapped a web page together that is hosted on Heroku.
I used the subclass.digital domain I purchased when I created an LLC for the work I am doing here.

http://www.subclass.digital (Heroku free instances, such as this, go to sleep, so there may be a ten second latency).

I added a few styles to try to make it look a little better. It looks ok, I could spend a lot more time making it look pretty. Perhaps if I ever touch this project again and modernize it, I will spend the time doing so.

## Why ... Flash?

This mp3 player w/ graphic equalizer was made in **late 2011** as a side project I threw together to help my little brother's band. The code is very poorly structured, not to mention it was written for a language/platform that was just about to go out of style, `ActionScript3`/`flash`. However, at the time, the web needed plugins to make what I aimed to make. I chose flash.

## How to Modernize

I would like to think I've learned a little in 6 years. Rewriting this today, to serve the same purpose, it would be written in `ES7` and leverage `HTML5` (which now has apis for `FFT` frequency information), and perhaps `WebGL`. As a matter of fact, if I were starting at this very moment, most of the view components would be written with Facebook's `React`.

It would also be restuctured into more solid and modular classes. There is a terrible pattern followed how Sprites are created in that they are super manual. Adobe had an sdk for rendering view components at the time called `Flex`, which I had some experience in, but I wanted to avoid any frameworks/sdks, and write raw `AS3`, to learn, and I bet I thought it would be lighter, so I wrote some sloppy sprite heirarchies.

## Code and Flow Structure

The code and flow are structured as follows:

* The actionscript source needs to be compiled into a `swf`. The Player was compiled into a swf that had a framerate of 15fps.

* The swf is then mounted via the `swfobject.js` javascript mounter, which uses some adobe pre-compiled swfs to help mount the flash component onto an Html DOM element. The mounter passes flash variables into the component. Two way communication can be set up here, I never got to it.

* Using the settings passed from JavaScript to flash, the UI elements are constructed as heierarchical sprites with appropriate colors, sizes, transparencies, fonts, audio file to play, images, etc.

* To run code every time we enter a frame, we listen to an event fired by the flash runtime, `ENTER_FRAME`.
```actionscript
this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
```

* The heart of what we do when we enter a new frame is *read* the fft spectrum, and *render* the result.
```actionscript
this.graphicEqualizer.readAndRender();
```

* We *read* sound spectrum from a flash built in.
```actionscript
SoundMixer.computeSpectrum(bytes, true, 0); // Compute the FFT sampled at 44.1kHz.
```

* Quantize the resultant data. The fft spectrum spits 256 values per channel, on any given read. I make an equalizer visualization with less than 256 bars, as a matter of fact there are 16 graphic equalizer bars. There is more than one mathematical way to generate quantized values from 256 discrete values. Many of those methods, including the one I chose, groups the 256 samples into 16 buckets. I decided then to take the max value of each bucket, as opposed to say, the mean, because it looked better. The important thing, and it's a gotcha, is that hearing is logarithmic but the spectrum produced from `SoundMixer.computeSpectrum` is linear, so the number of points in each bucket actually grows as the index into the spectrum (frequency) increases. This helps put out a visual that is more in line with what we think we hear.

* With this nice, length 16, array we create a graphic euqalizer visualization, again, with sprites.

It plays mp3 files that were created from m4a files in my old iTunes Library.
```bash
ffmpeg -i 01\ Dirty\ Deeds\ Done\ Dirt\ Cheap.m4a ac-dc.mp3
```

# Results

Although the technology is dated, and the code is very sloppy, the result isn't horrendous, I don't think.

Also note, you will need to install flash or have it enabled, I know, bummer.

http://www.subclass.digital

![Mp3 Equalizer Grid](images/mp3-equalizer-grid.gif)






