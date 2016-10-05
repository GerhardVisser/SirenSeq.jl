

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
function makeMidi(z; path::AbstractString="temp", tpq::Int=96, bpm::Int=defaultBpm, verbose::Bool=false)
	print("parsing expression ... \t")
	x = convert(Exp,atomOrExp(z))
	mt = track(x;tpq=tpq,bpm=bpm)
	print("done\n")
	trackToMidi(mt,path=path,verbose=verbose)
	return
end


## returns a MidiTrack object
function track(x::Exp; tpq::Int=96, bpm::Int=-1)
	@assert 12<=tpq<=5040
	@assert bpm==-1 || 12<=bpm<=1728
	mt = MidiTrack(tpq)
	if bpm>0 ; tempoSet!(mt,0//1,bpm) ; end
	s1, s2 = offsets(x)
	if s1<0 ; x = C(F(-s1,x),B(-s1+s2)) ; end
	x = adjustExp(x)
	mt.ff = toTrack!(mt,x)
	mt
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


## used to stop invalid note on/off overlapping
function adjustExp(x::Exp)
	sortExp!(x)
	as = x.as
	zs = Atom[]
	sz = length(as)
	for i in 1:(sz-1)
		a1 = as[i]
		if a1.dur > 0
			ter = a1.dur
			j = i
			while j<sz
				j += 1
				a2 = as[j]
				tt = a2.ofs
				if tt >= ter ; break ; end
				a1 = adjustAtoms(a1,a2)
				if !isa(a1,Atom) ; break ; end
			end
		end
		if isa(a1,Atom) ; push!(zs,a1) ; end
	end
	push!(zs,as[end])
	Exp(x.dur,zs)
end


## used by adjustChord

function adjustAtoms(x1::Note, x2::Note)
	if x1.cha != x2.cha ; return x1 ; end
	pch1::Int = x1.sca(x1.ocv,x1.itv)
	pch2::Int = x2.sca(x2.ocv,x2.itv)
	if pch1 != pch2 ; return x1 ; end
	t1 = x1.ofs ; t2 = x2.ofs
	if t1 == t2 ; return false ; end
	z = deepcopy(x1) ; z.dur = t2-t1
	z
end

adjustAtoms(x1::Atom, x2::Atom) = x1


## sorts the atoms in `x` by offset time
## used by track
sortExp!(x::Exp) = ( sort!(x.as,lt=compAtoms) ; x )

## used by compAtoms
function compAtoms(a1::Atom, a2::Atom)
	if a1.ofs < a2.ofs ; return true ; end
	if a1.ofs > a2.ofs ; return false ; end
	if a1.dur < a2.dur ; return true ; end
	if a1.dur > a2.dur ; return false ; end
	return false
end






