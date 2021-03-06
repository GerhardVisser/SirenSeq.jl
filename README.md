# SirenSeq

A tool for composing and sequencing music using [Julia](http://julialang.org/).  The goal is to remove the need for GUI tools when composing, recording and sequencing music by doing it all using Julia scripts and the SirenSeq module.  At this time only MIDI file composition is implemented.  Later versions will work by using [csound](http://www.csounds.com/) for audio recording, playing and manipulation.  Note, if you want to program MIDI more directly using Julia, use the [MIDI.jl](https://github.com/JoelHobson/MIDI.jl) package, SirenSeq implements MIDI scripting at a higher level.

Dependencies:

 - playback and rendering features are currently compatible only with Linux
 - the submodule `SirenSeq.Render` requires that [musescore](https://musescore.org/) is installed
 - the submodule `SirenSeq.Play` requires that [pmidi](http://alsa.opensrc.org/Pmidi) is installed

Use these links to get started,

 - [Tutorial1:  Playback and Rendering](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial1.md)
 - [Tutorial2:  Audio Expressions](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial2.md)
 - [Tutorial3:  Principles by Example](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial3.md)

More tutorials will be added soon.



