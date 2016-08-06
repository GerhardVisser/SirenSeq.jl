

## for turning Exp objects to midi files


defaultBpm = 120

"""
	setDefaultBpm(bpm::Int)

Set the default beats per minute to `bpm`.
"""
setDefaultBpm(bpm::Int) = ( global defaultBpm = bpm ; )


"""
	makeMidi(x::Expi; path::AbstractString=\"temp\", verbose::Bool=false, tpq::Int=96, bpm::Int=defaultBpm)

Writes audio expression `x` to a new midi file;
`path` is the file name (do not append \".mid\", that is done automatically),
`tpq` is the ticks per quarter note, defaults to 96,
`bpm` is the beats per minute, defaults to 120 (default can be changed with `setDefaultBpm`).
"""
function makeMidi(x::Expi; path::AbstractString="temp", tpq::Int=96, bpm::Int=defaultBpm, verbose::Bool=false)
	print("parsing expression ... \t")
	mt = track(x;tpq=tpq,bpm=bpm)
	print("done\n")
	trackToMidi(mt,path=path,verbose=verbose)
	return
end


## writes a MidiTrack to a new .mid file
function trackToMidi(mt::MidiTrack; path::AbstractString="temp", verbose::Bool=false)
	file = open("$path.mid","w")
	print("writing: $(path).mid ... \t")
	writeMidiFile(file,mt,verbose)
	close(file)
	print("done\n")
	return
end


## returns a MidiTrack object
function track(x::Expi; tpq::Int=96, bpm::Int=-1)
	@assert 12<=tpq<=5040
	@assert bpm==-1 || 12<=bpm<=1728
	mt = MidiTrack(tpq)
	if bpm>0 ; tempoSet!(mt,0//1,bpm) ; end
	if isa(x,Chord) ; x = adjustChord(x) ; end
	mt.ff = toTrack!(mt,x)
	mt
end


## used to stop invalid note on/off overlapping
function adjustChord(x::Chord)
	sortChord!(x)
	xs = x.xs
	zs = Atom[]
	sz = length(xs)
	for i in 1:(sz-1)
		x1 = xs[i]
		if in(:dur,fieldnames(x1))
			ter = len(x1)
			j = i
			while j<sz
				j += 1
				x2 = xs[j]
				tt = x2.ofs
				if tt >= ter ; break ; end
				x1 = adjustAtoms(x1,x2)
				if !isa(x1,Atom) ; break ; end
			end
		end
		if isa(x1,Atom) ; push!(zs,x1) ; end
	end
	push!(zs,xs[end])
	if length(zs) == 1 ; return zs[1] ; end
	Chord(zs)
end

## used by adjustChord
adjustAtoms(x1::Atom,x2::Atom) = x1

function adjustAtoms(x1::Note,x2::Note)
	if x1.cha != x2.cha ; return x1 ; end
	if x1.ocv != x2.ocv ; return x1 ; end
	pch1::Int = x1.sca(x1.ocv,x1.itv)
	pch2::Int = x2.sca(x2.ocv,x2.itv)
	if pch1 != pch2 ; return x1 ; end
	t1 = x1.ofs ; t2 = x2.ofs
	if t1 == t2 ; return false ; end
	z = deepcopy(x1) ; z.dur = t2-t1
	z
end


## sorts the atoms in `x` by offset time
## used by track
sortChord!(x::Chord) = ( sort!(x.xs,lt=compAtoms) ; x )

## used by compAtoms
function compAtoms(x1::Atom,x2::Atom)
	if x1.ofs < x2.ofs ; return true ; end
	if x1.ofs > x2.ofs ; return false ; end
	if in(:dur,fieldnames(x1))
		if !in(:dur,fieldnames(x2)) ; return true ; end
		if x1.dur > x2.dur ; return true ; end
		if x1.dur < x2.dur ; return false ; end
		return false
	elseif in(:dur,fieldnames(x2))
		return false
	end
	return false
end






