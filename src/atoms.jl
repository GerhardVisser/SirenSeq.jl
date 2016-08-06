

## makes sure the atom is valid
function atomTest(x::Atom)
	if in(:cha,fieldnames(typeof(x))) ; @assert 1 <= x.cha < 16 ; end	# channel
	if in(:dur,fieldnames(typeof(x))) ; @assert 0 < x.dur ; end			# duration
	if in(:ocv,fieldnames(typeof(x))) ; @assert 1 <= x.ocv < 6 ; end	# octave
	if in(:vel,fieldnames(typeof(x))) ; @assert 0 < x.vel ; end			# velocity
	x
end

## return copy of `x` with midi channel changed to `v`
channel(v::Int, x::Atom) = in(:cha,fieldnames(typeof(x))) ? ( x = deepcopy(x) ; x.cha = v ; atomTest(x) ) : x

## return copy of `x` with duration and offset multiplied by `v`
dilate(v::Rational{Int}, x::Atom) = ( x = deepcopy(x) ; x.ofs *= v ; if in(:dur,fieldnames(typeof(x))) ; x.dur *= v ; end ; atomTest(x) )

## return copy of `x` with `v` added to offset
sshift(v::Rational{Int}, x::Atom) = ( x = deepcopy(x) ; x.ofs += v ; atomTest(x) )

## return copy of `x` with velocity mutiplied by `v`
accel(v::Float64, x::Atom) =  in(:vel,fieldnames(typeof(x))) ? ( x = deepcopy(x) ; x.vel *= v ; atomTest(x) ) : x

## return copy of `x` with `v` added to note inteval value
transl(v::Int, x::Atom) = in(:itv,fieldnames(typeof(x))) ? ( x = deepcopy(x) ; x.itv += v ; atomTest(x) ) : x

## return copy of `x` with `v` added to note octave value
octave(v::Int, x::Atom) = in(:ocv,fieldnames(typeof(x))) ? ( x = deepcopy(x) ; x.ocv = v ; atomTest(x) ) : x

## return copy of `x` with note scale changed to `v`
sscale(v::Function, x::Atom) = in(:sca,fieldnames(typeof(x))) ? ( x = deepcopy(x) ; x.sca = v ; atomTest(x) ) : x

## returns the length::IR (in whole-notes) of `x`, includes offset
len(x::Atom) = x.ofs + ( in(:dur,fieldnames(typeof(x))) ? x.dur : 0//1 )


## silence
type Blank <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	dur::Rational{Int}	# duration

	Blank(cha,ofs,dur) = atomTest(new(cha,ofs,dur))
end


## play a note (on and off midi events)
type Note <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	itv::Int			# interval value
	dur::Rational{Int}	# duration
	ocv::Int			# octave
	vel::Float64		# velocity
	sca::Function		# scale

	Note(cha,ofs,itv,dur,ocv,vel,sca) = atomTest(new(cha,ofs,itv,dur,ocv,vel,sca))
end


## select instrument bank
type BankSel <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	bank::Int			# bank number
	
	BankSel(cha,ofs,bank) = ( @assert 0<=bank<=16383 ; atomTest(new(cha,ofs,bank)) )
end


## select instrument program
type ProgSel <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	prog::Int			# program

	ProgSel(cha,ofs,prog) = ( @assert 0<=prog<=127 ; atomTest(new(cha,ofs,prog)) )
end


## set channel volume
type VolSet <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	vol::Float64		# volume [0,1]

	VolSet(cha,ofs,vol) = ( @assert 0<=vol<=1 ; atomTest(new(cha,ofs,vol)) )
end


## pitch wheel bend
type PitchWheel <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	val::Int			# value {0..2^14-1}

	PitchWheel(cha,ofs,val) = ( @assert 0<=val<=16383 ; atomTest(new(cha,ofs,val)) )
end


## channel aftertouch
type ChanAfter <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	val::Int			# value {0..127}

	ChanAfter(cha,ofs,val) = ( @assert 0<=val<=127 ; atomTest(new(cha,ofs,val)) )
end


## channel contol 7bit
type Control7 <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	num::Int			# control number {64..127}
	val::Int			# control value {0..127}

	Control7(cha,ofs,num,val) = ( @assert 0<=val<=127 && 64<=num<=127 ; atomTest(new(cha,ofs,num,val)) )
end


## channel contol 14bit
type Control14 <: Atom
	cha::Int			# channel
	ofs::Rational{Int}	# offset
	num::Int			# control number {0..31}
	val::Int			# control value {0..2^14-1}

	Control14(cha::Int,ofs::Rational{Int},num::Int,val::Int) = ( @assert 0<=val<=16383 && 0<=num<=31 ; atomTest(new(cha,ofs,num,val)) )
end


## track marker
type Marker <: Atom
	ofs::Rational{Int}		# offset
	name::AbstractString	# marker name

	Marker(ofs,name) = ( @assert length(name) > 0 ; atomTest(new(name)) )
end


## set track time signature
type TimeSignature <: Atom
	ofs::Rational{Int} 	# offset
	num::Int			# numerator
	den::Int			# denominator as logarithm of 2
	clocks::Int			# divisions per quarter note
	sub::Int			# subdivisions

	TimeSignature(ofs,num,den,clocks,sub) = ( @assert 1<=num<=32 && 0<=den<=6 && 1<=clocks<64 && 1<=sub<64 ; atomTest(new(ofs,num,dem,clocks,sub)) )
end


## track tempo
type Tempo <: Atom
	ofs::Rational{Int}	# offset
	bpm::Int			# beats per minute

	Tempo(ofs,bpm) = ( @assert 12<=bpm<=1728 ; atomTest(new(ofs,bpm)) )
end


## functions for writing Atoms to a MidiTrack; uses Jumidi functions; returns `x` end time in MidiTrack ticks

toTrack!(mt::MidiTrack, x::Blank) = timm(mt,x.ofs) + timm(mt,x.dur)

function toTrack!(mt::MidiTrack, x::Note)
	t1 = timm(mt,x.ofs) ; t2 = t1 + tim(mt,x.dur) ; @assert t1 < t2-1
	ve = ftoi7(x.vel) ; pch::Int = x.sca(x.ocv,x.itv) ; @assert 0 <= pch < 128
	noteOn!(mt,x.ofs,x.cha,pch,ve)
	noteOff!(mt,x.ofs+x.dur,x.cha,pch,ve)
	t2
end

toTrack!(mt::MidiTrack, x::BankSel) = bankSel!(mt,x.ofs,x.cha,x.bank)

toTrack!(mt::MidiTrack, x::ProgSel) = progSel!(mt,x.ofs,x.cha,x.prog)

toTrack!(mt::MidiTrack, x::VolSet) = control14!(mt,x.ofs,x.cha,7,ftoi14(x.vol))

toTrack!(mt::MidiTrack, x::PitchWheel) = pitchWheel!(mt,x.ofs,x.cha,x.val)

toTrack!(mt::MidiTrack, x::ChanAfter) = chanAfter!(mt,x.ofs,x.cha,x.val)

toTrack!(mt::MidiTrack, x::Control7) = control7!(mt,x.ofs,x.cha,x.num,x.val)

toTrack!(mt::MidiTrack, x::Control14) = control14!(mt,x.ofs,x.cha,x.num,x.val)

toTrack!(mt::MidiTrack, x::Marker) = trackMarker!(mt,x.ofs,x.name)

toTrack!(mt::MidiTrack, x::TimeSignature) = timeSigSet!(mt,x.ofs,x.num,x.den,x.clocks,x.sub)

toTrack!(mt::MidiTrack, x::Tempo) = tempoSet!(mt,x.ofs,x.bpm)






