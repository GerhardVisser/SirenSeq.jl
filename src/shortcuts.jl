

## basic modifier expressors

"""
	A(v::Float64, x::Expi)

Accelirate `x`::Expi; multiplies all atom velocities by `v`.
"""
A(v::Float64, x::Expi) = accel(v,toExp(x))

"""
	D(v::IR, x::Expi)

Dilate `x`::Expi; multiplies all atom durations and offsets by `v`.
"""
D(v::IR, x::Expi) = ( @assert 0<v ; dilate(v//1,toExp(x)) )

"""
	F(v::IR, x::Expi) = sshift(v//1,toExp(x))

Shift `x`::Expi: adds `v` to all atom offsets
"""
F(v::IR, x::Expi) = sshift(v//1,toExp(x))

"""
	T(v::Int, x::Expi) = transl(v,toExp(x))

Translate `x`::Expi; adds `v` to all atom interval values.
"""
T(v::Int, x::Expi) = transl(v,toExp(x))

"""
	V(v::Int, x::Expi)

Octave `x`::Expi; sets all note octave values to `v`.
"""
V(v::Int, x::Expi) = octave(v,toExp(x))

"""
	Cha(v::Int, x::Expi) = channel(v,toExp(x))

Channel `x`::Expi; sets all channel values to `v`.
"""
Cha(v::Int, x::Expi) = channel(v,toExp(x))

"""
	Sca(v::Function, x::Expi)

Scale `x`::Expi; sets all note scales to `v`.  See SirenSeq.Scales
"""
Sca(v::Function, x::Expi) = sscale(v,toExp(x))


## used by constructor N
defaultScale = Scales.cMaj
defaultOctave = 3

"""
	setDefaultScale(sca::Function) 

Sets the default scale for `N` constructor (defualt value is cMaj).
"""
setDefaultScale(sca::Function) = ( global defaultScale = sca ; )

"""
	setDefaultOctave(ocv::Function) 

Sets the default octave for `N` constructor (defualt value is 3).
"""
setDefaultOctave(ocv::Function) = ( global defaultOctave = ocv ; )


## basic constructor expressors

"""
	B(dur::IR=1//1)

A blank/rest Atom; duration is `dur`.
"""
B(dur::IR=1//1) = Blank(1,0//1,dur//1)

"""
	N(itv::Int, dur::IR=1//1, vel::Float64=1.0)
	N(itv::Int, vel::Float64=1.0)

A note Atom; `itv` is the interval value on its scale, duration is `dur`, velocity is `vel`.
"""
N(itv::Int,dur::IR=1//1,vel::Float64=1.0) = Note(1,0//1,itv,dur//1,defaultOctave,vel,defaultScale)
N(itv::Int,vel::Float64=1.0) = Note(1,0//1,itv,1//1,defaultOctave,vel,defaultScale)


## integers are converted to the default note
toExp(v::Int) = N(v)
len(x::Int) = 1//1


"""
	Bank(v::Int)

Bank select Atom; bank number is `v`.
"""
Bank(v::Int) = BankSel(1,0//1,v)

"""
	Prog(v::Int) 

Program select Atom; program number is `v`.
"""
Prog(v::Int) = ProgSel(1,0//1,v)

"""
	Vol(v::Float64)

Volume set Atom; volume is `v`.
"""
Vol(v::Float64) = VolSet(1,0//1,v)

"""
	Wh() 
	Wh(v::Float64)

Picth wheel bend Atom; bend value is `v` [-1,1], use Wh() for no bend (i.e. reset).
"""
Wh() = PitchWheel(1,0//1,2^13)
Wh(v::Float64) = ( v = clamp(v,-1,1) ; w = v==0 ? 2^13 : clamp(convert(Int,round(2^13*(1.0+v))),0,2^14-1) ; PitchWheel(1,0//1,w) )

"""
	Aft(v::Float64)

Channel aftertouch Atom; `v` [0,1] is the value.
"""
Aft(v::Float64) = ( w = clamp(convert(Int,round(v*127)),0,127) ; ChanAfter(1,0//1,w) )

"""
	Cn7(num::Int, v::Float64)
	Cn7(num::Int, v::Int)

7bit channel control Atom; `num` is the contol number, `v` is value ([0,1] if Float, {0..127} if Int).
"""
Cn7(num::Int, v::Float64) = ( w = clamp(convert(Int,round(v*127)),0,127) ; Control7(1,0//1,num,w) )
Cn7(num::Int, v::Int) = Control7(1,0//1,num,clamp(v,0,127))

"""
	Cn14(num::Int, v::Float64)
	Cn14(num::Int, v::Int)

14bit channel control Atom; `num` is the contol number, `v` is value ([0,1] if Float, {0..2^14-1} if Int).
"""
Cn14(num::Int, v::Float64) = ( w = clamp(convert(Int,round(v*(2^14-1))),0,2^14-1) ; Control14(1,0//1,num,w) )
Cn14(num::Int, v::Int) = Control14(1,0//1,num,clamp(v,0,2^14-1))

"""
	Pan()
	Pan(v::Float64) 
	Pan(v::Int)

Channel pan Atom; use Pan() for center, `v` is the value ([-1,1] if Float, {0..2^14-1} if Int).
"""
Pan() = Ch14(10,2^13)
Pan(v::Float64) = ( v = clamp(v,-1,1) ; w = v==0 ? 2^13 : clamp(convert(Int,round(2^13*(1.0+v))),0,2^14-1) ;  Cn14(10,w) )
Pan(v::Int) = Cn14(10,v)

"channel sustain off Atom"
Sus0() = Cn7(64,0)

"channel sustain on Atom"
Sus1() = Cn7(64,127)

"all sounds off system message Atom"
SoundsOff() = Cn7(120,0)

"all contols reset system message Atom"
CntrlOff() = Cn7(121,0)

"all notes off system message Atom"
NotesOff() = Cn7(123,0)

"""
	Mark(v::AbstractString)

Track marker Atom; `v` is the marker name.
"""
Mark(v::AbstractString) = Marker(0//1,v)

"""
	Sig(num::Int=4, den::Int=3, clocks::Int=24, sub::Int=8)

Track time signature set Atom;
`num` is the numerator (defaults to 4),
`den` is the denumerator as a logarithm of 2 (defuaults to 3),
`clocks` is the divisions per quarter note (defualts to 24),
`sub` us the subdivisions of `clocks` (defualts to 8).
"""
Sig(num::Int=4, den::Int=3, clocks::Int=24, sub::Int=8) = TimeSignature(num,den,clocks,sub)


"""
	Tpo(bpm::Int)

Track tempo event; `bpm` is the beats per minute.
"""
Tpo(bpm::Int) = Tempo(0//1,bpm)






