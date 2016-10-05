
"""
Submodule of `SirenSeq`.
Used for rendering `SirenSeq` expression to a `.pdf` file.
Must have `musescore` 2.0 installed.
"""
module Render



export renderMidi


using SirenSeq
using SirenSeq.defaultBpm


"""
	renderMidi(path=\"temp\", name=path)

Renders \"`path`.mid\" to \"`name`.pdf\" using musescore. \\
Make sure musescore 2.0 or higher is installed.
"""
function renderMidi(; path::AbstractString="temp", name::AbstractString=path)
	print("rendering: $(name).pdf ... \t")
	try
		run(`mscore -o $(name).pdf $(path).mid`)
		print("done\n")
	catch err
		print("failed!\n")
		throw(err)
	end
	return
end


"""
	renderMidi(x::Expi; path=\"temp\", name=path, tpq=96, bpm=defaultBpm)

Creates a midi file caled \"`path`.mid\" (do not include the \".mid\" part) using audio expression `x`. \\
`tpq` is the midi ticks per quarter note.  `bpm` is the intial beats per minute (may be changed within `x` at any time). \\
Renders \"`path`.mid\" to \"`name`.pdf\" using musescore. \\
Make sure musescore 2.0 or higher is installed.
"""
function renderMidi(x; path::AbstractString="temp", name=path, tpq::Int=96, bpm::Int=defaultBpm)
	makeMidi(x;path=path,tpq=tpq,bpm=bpm)
	sleep(0.2)
	renderMidi(path=path,name=name)
	return
end



end
