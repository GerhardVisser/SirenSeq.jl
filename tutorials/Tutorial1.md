# Lesson 1


## Setup

It is assumed that you are running Linux and know how to setup some synthesizer such as [qsynth](http://apps.linuxaudio.org/apps/all/qsynth).  Make sure you can get some sounds out of it before proceeding.

You should also have [musescore]((https://musescore.org/)) installed; which is needed to render *.mid* files as *.pdf* musical notation.  Installing it should be as simple as, `apt-get install musescore`.

You should also have [pmidi](http://alsa.opensrc.org/Pmidi) is installed since the functions in SirenSeq.Play uses it.  Later versions might allow you to specify what program to play midi files with and whether it should use Jack or ALSA for midi control.  For now, it uses ALSA.  You can use [a2jmidi_bridge](http://manpages.ubuntu.com/manpages/wily/man1/a2jmidi_bridge.1.html) to make a bridge from ALSA midi to Jack midi if your synthesizer needs Jack midi inputs.



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
Chord:
  Note:   ch1,   ofs = 0 + 0//1,   dur = 1//1,   itv =  1,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 1 + 0//1,   dur = 1//1,   itv =  2,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 2 + 0//1,   dur = 1//1,   itv =  3,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 3 + 0//1,   dur = 1//1,   itv =  2,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
The top line `Chord:` just means that `sq` is a collection; in this case, 4 Notes.  Let's look at these notes.  `ch1` means that the note will be played on channel 1.  `ofs` represents and *offset*.  `ofs = 2 + 0//1` means that the note starts 2 whole-note lengths after the start of `sq` (at 0).  `dur` represents duration.  `dur = 1//1` means that the note is held for 1 whole-note.  `itv` represents an interval on some scale; in this case the scale is `sca = SirenSeq.Scales.cMaj` which is the *C Major* scale.  When `itv` is less than 1, the scale moves an octave down.  When `itv` is greater than 7, the scale moves an octave up.  `ocv` represents the note octave which is 3 for these notes.  Finally, `vel` represents the note velocity.  Velocity should be in the range `[0,1]`, otherwise it will be clipped.


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
Notice that it returns the *pmidi* process playing `sq`.  If you go to your working directory you should see that a file called *temp.mid* was created containing the sequence just played.  By default, `playMidi` always writes to *temp.mid*.  Now try running,
```julia
playMidi(sq,path="foo",bpm=200)
```
This tells `playMidi` to write to *foo.mid* and play at 200 beats per minute (instead of the default 120).  For more detail on `playMidi` or any other exported function in *SirenSeq*, type `?playMidi` in the Julia terminal.


## Interrupting Play

Sometimes you will want to stop a midi file from playing.  One problem that can occur when simply killing the *pmidi* is that some note keeps playing indefinitely because the interrupt occurred before a note-off midi event.  To prevent this *SirenSeq* must play a special midi file called *stop.mid* immediately after the interrupt which tells the sequencer to stop all sounds.  To make this more customizable the *stop.mid* should reside in your project working directory so you can replace it with anything you like later.  To generate the default *stop.mid* in your project working directory, run,
```julia
makeStopMidi()
```
Now you can use the function `stop()` to interrupter play.  Running,
```julia
playMidi(R(8,sq))
```
will repeat `sq` 8 times.  While it is running stop it using,
```julia
stop()
```
Since `playMidi` returns a process there is also the option,
```julia
p = playMidi(R(8,sq))
stop(p)
```
which is perhaps a more clean way to stop a playback process since the `stop()` asks the operating system to kill all instances of *pmidi* where `stop(p)` targets the specific process.


## Rendering a Note Sequence

Next we are going to render `sq` to a *.pdf* file in traditional music notation.  From the Julia terminal, run,
```julia
renderMidi()
```
There is a good chance that *musescore* will throw up some error messages and possibly a segmentation fault.  *This is still unresolved and I don't know if the bug is in my code or musescore.*  Despite this, there should now be a file called *temp.pdf* in the working directory.  Open it too see what `sq` looks like.  To render *foo.mid* to *bar.pdf* you can run, 
```julia
renderMidi(path="foo",name="bar")
```

This concludes the first lesson.






