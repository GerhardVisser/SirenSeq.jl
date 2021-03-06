# Lesson 1:  Playback and Rendering


## Setup

It is assumed that you are running Linux and know how to setup some synthesizer (e.q. [qsynth](http://apps.linuxaudio.org/apps/all/qsynth)).  Make sure you can get sound out of it before proceeding.

You should also have [musescore](https://musescore.org/) (at least 2.0) installed as the submodule `SirenSeq.Render` uses it.  Musescore is needed to render *.mid* files as *.pdf* musical notation.  Installing it should be as simple as, `apt-get install musescore`.

You should also have [pmidi](http://alsa.opensrc.org/Pmidi) installed as the submodule `SirenSeq.Play` uses it.  Later versions might allow you to specify what program to play midi files with and whether it should use Jack or ALSA for midi control.  For now, it uses ALSA.  You can use [a2jmidi_bridge](http://manpages.ubuntu.com/manpages/wily/man1/a2jmidi_bridge.1.html) to make a bridge from ALSA midi to Jack midi if your synthesizer needs Jack midi inputs.



## Creating a Note Sequence

Create a project folder and open the Julia terminal in it.  Now run,
```julia
using SirenSeq, SirenSeq.Play, SirenSeq.Render
```
then enter the line,
```julia
sq = S(1,2,3,2)
```
You should see,
```
Exp:    dur = 4//1
  Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  1,  ocv = 3,  vel = 1.00,  sca = cMaj
  Note:   ch1,   ofs =  1 + 0//1,  dur = 1//1,   itv =  2,  ocv = 3,  vel = 1.00,  sca = cMaj
  Note:   ch1,   ofs =  2 + 0//1,  dur = 1//1,   itv =  3,  ocv = 3,  vel = 1.00,  sca = cMaj
  Note:   ch1,   ofs =  3 + 0//1,  dur = 1//1,   itv =  2,  ocv = 3,  vel = 1.00,  sca = cMaj
```
The top line `Exp:` just means that `sq` is a collection of events; in this case, 4 Notes.  `dur = 4//1` means that `sq` has a duration of 4 whole-note lengths.  Let's look at the 4 notes.  `ch1` means that the note will be played on channel 1.  `ofs` represents an *offset*.  `ofs = 2 + 0//1` means that the note starts 2 whole-note lengths after the start of `sq` (at offset `ofs = 0`).  `dur` represents duration.  `dur = 1//1` means that the note is held for 1 whole-note duration.  `itv` represents an interval on some scale; in this case the scale is `sca = cMaj` which is the *C Major* scale.  When `itv` is less than 1, the scale moves an octave down.  When `itv` is greater than 7, the scale moves an octave up.  `ocv` represents the note octave which is 3 for these notes.  As an example, if `ocv = 3` and `itv = -2`, the note played will be on the 2nd octave as `itv` is taken relative to the `ocv` value.  Finally, `vel` represents the note velocity.  Velocity should be in the range `(0,1]`, otherwise it will be clipped.  Clipping happens when the midi file is written but not when the object is created so values greater than `1.0` can be used in intermediate calculations.


## Playing a Note Sequence

To play `sq` on your sequencer, first identify its ALSA midi input port.  You can find it using *pmidi*,
```
pmidi -l
 Port     Client name                       Port name
 14:0     Midi Through                      Midi Through Port-0
 16:0     M Audio Audiophile192             ICE1724 MIDI
128:0     Client-128                        qjackctl
130:0     FLUID Synth (3808)                Synth input port (3808:0)

```
In this example output, the *fluidsynth* port is "130:0".  Running,
```julia
setDefaultPlayPort("130:0")
```
tells *SirenSeq* to play all midi files to that port unless otherwise specified.  To hear `sq`, run,
```julia
playMidi(sq)
```
you should see,
```
parsing expression ... 	done
writing: temp.mid ... 	done
playing: temp.mid ...
Process(\`pmidi -d 0.5 -p 130:0 temp.mid\`, ProcessExited(1))
```
Notice that `playMidi(sq)` returns the *pmidi* process playing `sq`.  If you look in your working directory you should see that a file called *temp.mid* was created containing the sequence just played.  By default, `playMidi` always writes to *temp.mid* before playback.  Now run,
```julia
playMidi(sq,path="foo",bpm=200)
```
This tells `playMidi` to write to *foo.mid* and play at 200 beats per minute (instead of the default 120).  If `sq` is not passed as an argument, it will assume that the `path`*.mid* file already exists.  For more detail on `playMidi` or any other exported function of *SirenSeq*, type `?playMidi` in the Julia terminal.


## Interrupting Play

Sometimes you will want to interrupt playback.  One problem that can occur when simply killing the *pmidi* process is that some note keeps playing indefinitely because the interrupt occurred before a note-off midi event.  To prevent this, *SirenSeq* must play a special midi file called *stop.mid* immediately after the interrupt which tells the sequencer to stop all sounds.  The *stop.mid* will reside in your project working directory.  If it does not exist there, it will be created the first time `stop()` is run.  You can replace it with anything you like later if you want a customised sequence of midi events to be sent when `stop()` is run.

Let's test it, running,
```julia
playMidi(R(8,sq))
```
will repeat `sq` 8 times.  While it is running, stop it using,
```julia
stop()
```
Since `playMidi` returns a process there is also the option,
```julia
p = playMidi(R(8,sq))
stop(p)
```
which is perhaps a more clean way to stop a playback process since `stop()` asks the operating system to kill all instances of *pmidi* where `stop(p)` targets the specific process.


## Rendering a Note Sequence

Next we are going to render `sq` to a *.pdf* file in traditional music notation.  From the Julia terminal, run,
```julia
renderMidi(sq)
```
There is a good chance that *musescore* will throw up some error messages and possibly a segmentation fault.  *This is still unresolved and I don't know if the bug is in my code or musescore.*  Despite this, there should now be a file called *temp.pdf* in the working directory.  Open it too see what `sq` looks like.  With `renderMidi(sq)`, `sq` was first written to *temp.mid* before rendering *temp.pdf* .  If argument `sq` is omitted (`renderMidi()`), it will assume *temp.mid* already exists.  To write `sq` to *foo.mid* and then render to *bar.pdf* you can run, 
```julia
renderMidi(sq,path="foo",name="bar")
```
Both `path` and `name` default to `"temp"`.  If `sq` were not specified (`renderMidi(path="foo",name="bar")`), it will assume *foo.mid* already exists.


Goto: [Next Tutorial](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial2.md)



