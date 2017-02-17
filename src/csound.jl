
"""
Submodule of `SirenSeq`.
Used for playing `SirenSeq` expressions using `csound` or writing them to audio files.
Must have `csound` installed.
"""
module Csound


export

CsHead, SoundFont, FluidInst, ChanMap,
makeOrc, makeScore


using SirenSeq

include("csoundgen.jl")


ChanMap = Dict{Int,CsInstr}


"""
	makeScore(chs::ChanMap, z; path::AbstractString=\"temp\", bpm::Int=defaultBpm)

Writes audio expression `z` to a new `.sco` csound score file;

`chs` mapping channel numbers to instruments \\
`path` is the file name (do not append \".sco\", that is done automatically), \\
`bpm` is the beats per minute, defaults to 120 (default can be changed with `setDefaultBpm`).
"""
function makeScore(chs::ChanMap, z; path::AbstractString="temp", bpm::Int=SirenSeq.defaultBpm)
	print("parsing expression ... \t")
	x = convert(Exp,atomOrExp(z))
	if isa(x,Atom) ; x = C(x) ; end
	SirenSeq.sortExp!(x)
	file = open("$(path).sco","w")
	for a in x.as
		csScoreAtom(file,chs,bpm,a)
	end
	close(file)
	println("score file written to:\n  $(path).sco")
	return
end


## write a single note atom as a csound note
function csScoreAtom(out::IOStream, chs::ChanMap, bpm::Int, a::SirenSeq.Note)
	if !haskey(chs,a.cha) ; throw(ErrorException("no instrument specified for channel $a.cha")) ; end
	n = chs[a.cha]
	ofs = convert(Float64,a.ofs*(240//bpm))
	dur = convert(Float64,a.dur*(240//bpm))
	pch = Scales.getPitch(a.sca,a.ocv,a.itv)
	vel = clamp(convert(Int,round(a.vel*127)),0,127)
	frq = 440*2^((pch-69)/12)
	write(out,"i \"$(instrName(n))\" $(@sprintf("%.6f",ofs)) $(@sprintf("%.6f",dur)) $(convert(Int,floor(frq))) $(vel)\n")
end


## most atoms are ignored as not yet supported
function csScoreAtom(chs::ChanMap, bpm::Int, a::Atom)
end



end
