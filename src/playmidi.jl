

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
	print("parsing expression ... \t")
	makeMidi(x;path=path,tpq=tpq,bpm=bpm)
	sleep(0.2)
	print("done\n")
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


"""
	playQuick(; port=defaultPlayPort, path=\"stop\")

Plays the file specified by `path` on ALSA port `port` using the program pmidi.
Do not use this for anything other that muting all sequencers.
"""
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






