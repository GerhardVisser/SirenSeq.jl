

## return copy of `a` with midi channel changed to `v`
function channel(v::Int, a::Atom)
	@assert 1 <= v <= 16
	if in(:cha,fieldnames(typeof(a)))
		a = deepcopy(a)
		a.cha = v
	end
	a
end


## return copy of `a` with duration and offset multiplied by `v`
function dilate(v::Rat, a::Atom)
	@assert v > 0
	if in(:dur,fieldnames(typeof(a)))
		a = deepcopy(a)
		a.ofs *= v
		a.dur *= v
	end
	a
end


## return copy of `a` with `v` added to offset
function sshift(v::Rat, a::Atom)
	a = deepcopy(a)
	a.ofs += v
	a
end


## return copy of `a` with velocity mutiplied by `v`
function accel(v::Float64, a::Atom)
	@assert 0 < v
	if in(:vel,fieldnames(typeof(a)))
		a = deepcopy(a)
		a.vel *= v
	end
	a
end


## return copy of `a` with `v` added to note inteval value
function transl(v::Int, a::Atom)
	if in(:itv,fieldnames(typeof(a)))
		a = deepcopy(a)
		a.itv += v 
	end
	a
end


## return copy of `a` with `v` added to note octave value
function octave(v::Int, a::Atom)
	if in(:ocv,fieldnames(typeof(a)))
		a = deepcopy(a)
		a.ocv = v
	end
	a
end


## return copy of `a` with note scale changed to `v`
function sscale(v::Function, a::Atom)
	if in(:sca,fieldnames(typeof(a)))
		a = deepcopy(a)
		a.sca = v
	end
	a
end


## tests if atom default fields have valid values
function atomTest(a::Atom)
	if in(:cha,fieldnames(typeof(a))) ; @assert 1 <= a.cha <= 16 ; end
	if isa(a,Duratom)
		if in(:dur,fieldnames(typeof(a))) ; @assert 0 < a.dur ; end
	else
		if in(:dur,fieldnames(typeof(a))) ; @assert 0 <= a.dur ; end
	end
	if in(:ocv,fieldnames(typeof(a))) ; @assert 1 <= a.ocv <= 5 ; end
	if in(:vel,fieldnames(typeof(a))) ; @assert 0 < a.vel ; end
	a
end


## play a note (on and off midi events)
type Note <: Duratom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	itv::Int			# interval value
	ocv::Int			# octave
	vel::Float64		# velocity
	sca::Function		# scale

	Note(ofs,dur,cha,itv,ocv,vel,sca) = atomTest(new(ofs,dur,cha,itv,ocv,vel,sca))
end


## select instrument bank
type BankSel <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	bank::Int			# bank number
	
	BankSel(ofs,cha,bank) = ( @assert 0<=bank<=16383 ; atomTest(new(ofs,0//1,cha,bank)) )
end


## select instrument program
type ProgSel <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	prog::Int			# program

	ProgSel(ofs,cha,prog) = ( @assert 0<=prog<=127 ; atomTest(new(ofs,0//1,cha,prog)) )
end


## set channel volume
type VolSet <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	vol::Float64		# volume [0,1]

	VolSet(ofs,cha,vol) = ( @assert 0<=vol<=1 ; atomTest(new(ofs,0//1,cha,vol)) )
end


## pitch wheel bend
type PitchWheel <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	val::Int			# value {0..2^14-1}

	PitchWheel(ofs,cha,val) = ( @assert 0<=val<=16383 ; atomTest(new(ofs,0//1,cha,val)) )
end


## channel aftertouch
type ChanAfter <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	val::Int			# value {0..127}

	ChanAfter(ofs,cha,val) = ( @assert 0<=val<=127 ; atomTest(new(ofs,0//1,cha,val)) )
end


## channel contol 7bit
type Control7 <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	num::Int			# control number {64..127}
	val::Int			# control value {0..127}

	Control7(ofs,cha,num,val) = ( @assert 0<=val<=127 && 64<=num<=127 ; atomTest(new(ofs,0//1,cha,num,val)) )
end


## channel contol 14bit
type Control14 <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	cha::Int			# channel
	num::Int			# control number {0..31}
	val::Int			# control value {0..2^14-1}

	Control14(ofs,cha,num,val) = ( @assert 0<=val<=16383 && 0<=num<=31 ; atomTest(new(ofs,0//1,cha,num,val)) )
end


## track marker
type Marker <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	name::AbstractString	# marker name

	Marker(ofs,name) = ( @assert length(name) > 0 ; atomTest(new(ofs,0//1,name)) )
end


## set track time signature
type TimeSignature <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	num::Int			# numerator
	den::Int			# denominator as logarithm of 2
	clocks::Int			# divisions per quarter note
	sub::Int			# subdivisions

	TimeSignature(ofs,num,den,clocks,sub) = ( @assert 1<=num<=32 && 0<=den<=6 && 1<=clocks<64 && 1<=sub<64 ; atomTest(new(ofs,0//1,num,den,clocks,sub)) )
end


## track tempo
type Tempo <: Atom
	ofs::Rat			# offset
	dur::Rat			# duration
	bpm::Int			# beats per minute

	Tempo(ofs,bpm) = ( @assert 12<=bpm<=1728 ; atomTest(new(ofs,0//1,bpm)) )
end


## functions for writing Atoms to a MidiTrack; uses Jumidi functions; returns a's end time in MidiTrack ticks

function toTrack!(mt::MidiTrack, a::Note)
	t1 = timm(mt,a.ofs) ; t2 = t1 + tim(mt,a.dur) ; @assert t1 < t2-1
	ve = ftoi7(a.vel) ; pch::Int = a.sca(a.ocv,a.itv) ; @assert 0 <= pch < 128
	noteOn!(mt,a.ofs,a.cha,pch,ve)
	noteOff!(mt,a.ofs+a.dur,a.cha,pch,ve)
	t2
end

toTrack!(mt::MidiTrack, a::BankSel) = bankSel!(mt,a.ofs,a.cha,a.bank)

toTrack!(mt::MidiTrack, a::ProgSel) = progSel!(mt,a.ofs,a.cha,a.prog)

toTrack!(mt::MidiTrack, a::VolSet) = control14!(mt,a.ofs,a.cha,7,ftoi14(a.vol))

toTrack!(mt::MidiTrack, a::PitchWheel) = pitchWheel!(mt,a.ofs,a.cha,a.val)

toTrack!(mt::MidiTrack, a::ChanAfter) = chanAfter!(mt,a.ofs,a.cha,a.val)

toTrack!(mt::MidiTrack, a::Control7) = control7!(mt,a.ofs,a.cha,a.num,a.val)

toTrack!(mt::MidiTrack, a::Control14) = control14!(mt,a.ofs,a.cha,a.num,a.val)

toTrack!(mt::MidiTrack, a::Marker) = trackMarker!(mt,a.ofs,a.name)

toTrack!(mt::MidiTrack, a::TimeSignature) = timeSigSet!(mt,a.ofs,a.num,a.den,a.clocks,a.sub)

toTrack!(mt::MidiTrack, a::Tempo) = tempoSet!(mt,a.ofs,a.bpm)






