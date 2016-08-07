# SirenSeq

A tool for composing and sequencing music using [Julia](http://julialang.org/).  The goal is to remove the need for GUI tools when composing, recording and sequencing music by doing it all using Julia scripts and the SirenSeq module.  At this time only MIDI file composition is implemented.  Later versions will work by using [csound](http://www.csounds.com/) for audio recording, playing and manipulation.

- compatible only with Linux
- the submodule *SirenSeq.Render* requires that [musescore](https://musescore.org/) is installed
- the submodule *SirenSeq.Play* requires that [pmidi](http://alsa.opensrc.org/Pmidi) is installed

To get started, go to the `tutorials` folder and open the `Tutorial*.md` files from the github browser.  More tutorials will be added soon.
