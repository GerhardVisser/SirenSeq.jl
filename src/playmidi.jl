module Play



export setDefaultPlayPort, playMidi, stop, makeStopMidi


using SirenSeq
using SirenSeq.defaultBpm


## default ALSA midi port to play to
defaultPlayPort = "130:0"

"""
	setDefaultPlayPort(pp::AbstractString) 

Sets the default ALSA midi port to which `playMidi` will play to. 
For example, if 128:0 is the qsynth midi input port then use, `setDefaultPlayPort(\"130:0\")`.
"""
setDefaultPlayPort(pp::AbstractString) = ( global defaultPlayPort = pp ; )


"""
	playMidi([x::Expi]; port=defaultPlayPort, path=\"temp\", tpq=96, bpm=defaultBpm)

Creates a midi file caled \"`path`.mid\" (do not include the \".mid\" part) using audio expression `x`.
It then plays the file on ALSA port `port` (e.g. \"130:0\") using the program pmidi, which must be installed on the system. 
`tpq` is the midi ticks per quarter note.  `bpm` is the intial beats per minute (may be changed within `x` at any time).
If `x` is not specified it will look for a file called \"temp.mid\" and play that.
"""
function playMidi(x::Expi; port::AbstractString=defaultPlayPort, path::AbstractString="temp", tpq::Int=96, bpm::Int=defaultBpm)
	makeMidi(x;path=path,tpq=tpq,bpm=bpm)
	sleep(0.2)
	playMidi(port=port,path=path)
end


function playMidi(; port::AbstractString=defaultPlayPort, path::AbstractString="temp")
	try
		println("playing: $(path).mid ... \t")
		p = spawn(`pmidi -d 0.5 -p $(port) $(path).mid`)
		if !process_running(p) ; throw(error("failed to run pmidi")) ; end
		sleep(0.5)
		return p
	catch err
		if isa(err,InterruptException)
			print("interrupted!\n")
			return
		else
			throw(err)
		end
	end
end


## used by stop
function playMidiQuick(; port::AbstractString=defaultPlayPort, path::AbstractString="stop")
	try
		run(`pmidi -d 0.1 -p $(port) $(path).mid`)
		sleep(0.1)
	catch err
		if isa(err,InterruptException)
			print("interrupted!\n")
			return
		else
			throw(err)
		end
	end
end


"""
	stop([p]; port=defaultPlayPort, path=\"stop\"

Stops the process `p`, which is assumed to be the one returned by `playMidi`.
If `p` is not given, it will simply kill all instances of the program pmidi.
Plays the file \"`path`.mid\" on ALSA port `port` using the program pmidi.
By default, `path` == \"stop.mid\", which is assumed to be a short midi file that tells a sequencers to be quiet.
Use the function `makeStopMidi` to generate this file in your project directory.
"""
function stop(p; port::AbstractString=defaultPlayPort, path::AbstractString="stop")
	if process_running(p) ; kill(p) ; end
	sleep(0.1)
	playMidiQuick(port=defaultPlayPort,path="stop")
	sleep(0.1)
	print("play stopped\n")
	return
end


function stop()
	try
		run(`killall pmidi`)
	catch err
	end
	sleep(0.1)
	playMidiQuick(port=defaultPlayPort,path="stop")
	sleep(0.1)
	print("play stopped\n")
	return
end


"""
	makeStopMidi(path::AbstractString=\"stop\")

Writes a midi file called \"`path`.mid\" where `path` defaults to \"stop\".
The file contains a midi messages to turn all notes off and stop all sounds.
This function should be run once to make the file in you projec directory so it can be used by the `stop` function.
"""
function makeStopMidi(path::AbstractString="stop")
	x = S(NotesOff(),B(1//32),SoundsOff(),B(1//32))
	makeMidi(x;path=path,bpm=-1)
end



end
