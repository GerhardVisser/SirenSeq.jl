

## basic modifier expressors

"""
	A(v::Float64, z)

Accelirate `z`::Expi; multiplies all atom velocities by `v`.
"""
A(v::Float64, z) = accel(v,atomOrExp(z))


"""
	D(v::IR, z)

Dilate `z`; multiplies all atom durations and offsets by `v`.
"""
D(v::IR, z) = ( @assert 0<v ; dilate(Rat(v),atomOrExp(z)) )


"""
	F(v::IR, z)

Shift `z`: adds `v` to all atom offsets
"""
F(v::IR, z) = sshift(Rat(v),atomOrExp(z))


"""
	T(v::Int, z)

Translate `z`; adds `v` to all note interval values.
"""
T(v::Int, z) = transl(v,atomOrExp(z))


"""
	V(v::Int, z)

Octave `z`; sets all note octave values to `v`.
"""
V(v::Int, z) = octave(v,atomOrExp(z))


"""
	Cha(v::Int, z)

Channel `z`; sets all channel values to `v`.
"""
Cha(v::Int, z) = channel(v,atomOrExp(z))


"""
	Sca(v::Function, z)

Scale `z`; sets all note scales to `v`.  See SirenSeq.Scales
"""
Sca(v::Function, z) = sscale(v,atomOrExp(z))


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

An empty `Exp` with specified duration
"""
B(dur::IR=1//1) = ( @assert dur >= 0 ; Exp(dur,Atom[]) )


"""
	N(itv::Int)

A whole-note `Atom`; `itv` is the interval value on its scale. \\
Duration is `1//1`, offset is `0//1`, channel is `1`, velocity is `1.0`. \\
Uses default octave and scale (see `setDefaultScale` and `setDefaultOctave`).
"""
N(itv::Int) = Note(0//1,1//1,1,itv,defaultOctave,1.0,defaultScale)


## integers are converted to the default note
Base.convert(::Type{Atom}, v::Int) = N(v)


"""
	Bank(v::Int)

Bank select `Atom`; bank number is `v`.
"""
Bank(v::Int) = BankSel(0//1,1,v)

"""
	Prog(v::Int) 

Program select `Atom`; program number is `v`.
"""
Prog(v::Int) = ProgSel(0//1,1,v)

"""
	Vol(v::Float64)

Volume set `Atom`; volume is `v`.
"""
Vol(v::Float64) = VolSet(0//1,1,v)

"""
	Wh() 
	Wh(v::Float64)

Picth wheel bend `Atom`; bend value is `v` [-1,1], use Wh() for no bend (i.e. reset).
"""
Wh() = PitchWheel(0//1,1,2^13)
Wh(v::Float64) = ( v = clamp(v,-1,1) ; w = v==0 ? 2^13 : clamp(convert(Int,round(2^13*(1.0+v))),0,2^14-1) ; PitchWheel(0//1,1,w) )

"""
	Aft(v::Float64)

Channel aftertouch `Atom`; `v` [0,1] is the value.
"""
Aft(v::Float64) = ( w = clamp(convert(Int,round(v*127)),0,127) ; ChanAfter(0//1,1,w) )

"""
	Cn7(num::Int, v::Float64)
	Cn7(num::Int, v::Int)

7bit channel control `Atom`; `num` is the contol number, `v` is value ([0,1] if Float, {0..127} if Int).
"""
Cn7(num::Int, v::Float64) = ( w = clamp(convert(Int,round(v*127)),0,127) ; Control7(0//1,1,num,w) )
Cn7(num::Int, v::Int) = Control7(0//1,1,num,clamp(v,0,127))

"""
	Cn14(num::Int, v::Float64)
	Cn14(num::Int, v::Int)

14bit channel control `Atom`; `num` is the contol number, `v` is value ([0,1] if Float, {0..2^14-1} if Int).
"""
Cn14(num::Int, v::Float64) = ( w = clamp(convert(Int,round(v*(2^14-1))),0,2^14-1) ; Control14(0//1,1,num,w) )
Cn14(num::Int, v::Int) = Control14(0//1,1,num,clamp(v,0,2^14-1))

"""
	Pan()
	Pan(v::Float64) 
	Pan(v::Int)

Channel pan `Atom`; use `Pan()` for center, `v` is the value ([-1,1] if Float, {0..2^14-1} if Int).
"""
Pan() = Ch14(10,2^13)
Pan(v::Float64) = ( v = clamp(v,-1,1) ; w = v==0 ? 2^13 : clamp(convert(Int,round(2^13*(1.0+v))),0,2^14-1) ;  Cn14(10,w) )
Pan(v::Int) = Cn14(10,v)

"channel sustain off `Atom`"
Sus0() = Cn7(64,0)

"channel sustain on `Atom`"
Sus1() = Cn7(64,127)

"all sounds off system message `Atom`"
SoundsOff() = Cn7(120,0)

"all contols reset system message `Atom`"
CntrlOff() = Cn7(121,0)

"all notes off system message `Atom`"
NotesOff() = Cn7(123,0)

"""
	Mark(v::AbstractString)

Track marker `Atom`; `v` is the marker name.
"""
Mark(v::AbstractString) = Marker(0//1,v)

"""
	Sig(num::Int=4, den::Int=3, clocks::Int=24, sub::Int=8)

Track time signature set `Atom`; \\
`num` is the numerator (defaults to 4), \\ 
`den` is the denumerator as a logarithm of 2 (defuaults to 3), \\
`clocks` is the divisions per quarter note (defualts to 24), \\
`sub` us the subdivisions of `clocks` (defualts to 8).
"""
Sig(num::Int=4, den::Int=3, clocks::Int=24, sub::Int=8) = TimeSignature(0//1,num,den,clocks,sub)


"""
	Tpo(bpm::Int)

Track tempo `Atom`; `bpm` is the beats per minute.
"""
Tpo(bpm::Int) = Tempo(0//1,bpm)


"""
	Inst(pg::Tuple{Int,Int}, [v::Float64])

Sets instrument to bank `pg[1]` program `pg[2]`. \\
If `v` is specified it also sets the volume to `v` which shoud be in the range `[0,1]`. \\
Named (bank,program) tuple constants can be found in the `SirenSeq.GenFluidSF144` and `SirenSeq.GenMuseScoreSF144` modules.
For example, `Instr(SirenSeq.GenMuseScoreSF144.iTubularBells,0.8)` selects the tubular-bells instrument from the general musescore 144 soundfont file and sets its volume to `0.8`.
"""
Inst(pg::Tuple{Int,Int}) = S(Bank(pg[1]),Prog(pg[2]))
Inst(pg::Tuple{Int,Int}, v::Float64) = S(Bank(pg[1]),Prog(pg[2]),Vol(v))


"""
	Da(v1::IR, v2::Float64, z) = D(v1,A(v2,z))

Dilate `z` by `v1` and accelirate it by `v2`.
"""
Da(v1::IR, v2::Float64, z) = D(v1,A(v2,z))


"""
	Con(z, b1::IR, b2::IR)
	Con(z, b2::IR) = Con(0,b2)
	Con(z) = Con(0,z.dur)

Contain `z`; this function makes sure that no events happen outside the time interval [`b1`,`b2`].
Events that cross this interval may be removed or shortened.
"""
Con(z) = ( x = atomOrExp(z); Con(x,0//1,x.dur) )
Con(z, b2::IR) = ( @assert b2>0 ; Con(z,0//1,b2) )
Con(z, b1::IR, b2::IR) = ( @assert b2>b1 ; contain(convert(Exp,atomOrExp(z)),Rat(b1),Rat(b2)) )

contain(x::Exp, b1::Rational{Int}, b2::Rational{Int}) = Exp(x.dur,atomsOp(a->contain(a,b1,b2),x))

function contain(a::Atom, b1::Rational{Int}, b2::Rational{Int})
	dur = a.dur ; ofs = a.ofs
	t1 = ofs ; t2 = ofs+dur
	if t1 < b1 ; dt = b1-t1 ; ofs += dt ; dur -= dt ; end
	if t2 > b2 ; dt = t2-b2 ; dur -= dt ; end
	if dur < 0 ; return Exp(0//1,Atom[]) ; end
	if dur == 0 && isa(a,Duratom) ; return Exp(0//1,Atom[]) ; end
	y = deepcopy(a) ; y.ofs=ofs ; y.dur=dur
	y
end


"""
	Kl(v::Rational{Int}, z)

Klip `z` by `v`.  The duration of all notes in `z` is multiplied by `v`.
A rest is inserted after each note where its length is `(1-v)` times the duration of the original note.
`0 < v < 1` must hold.
"""
Kl(v::Rational{Int}, z) = ( @assert 0<v<1 ; klip(v,atomOrExp(z)) )

klip(v::Rational{Int}, a::Note) = ( y = deepcopy(a) ; y.dur*=v ; Exp(a.dur,Atom[y]) )
klip(v::Rational{Int}, a::Atom) = a
klip(v::Rational{Int}, x::Exp) = Exp(x.dur,atomsOp(z->klip(v,z),x))


"""
	Spl(v::Int, z)

Split `z` `v` times.  Replaces each note in `z` by the same note repeated `v` times in the same time interval.
"""
Spl(v::Int, z) = ( @assert 1<v ; splitt(v,atomOrExp(x)) )

splitt(v::Int, a::Note) = ( y = deepcopy(a) ; y.dur/=v ; y.ofs=0//1 ; F(x.ofs,R(v,y)) )
splitt(v::Int, a::Atom) = a
splitt(v::Int, x::Exp) = atomsOp(z->splitt(v,z),x)






