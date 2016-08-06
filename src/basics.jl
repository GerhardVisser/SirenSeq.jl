

"a type used to enter note lengths, e.g. 1//4 == quarter note length"
IR = Union{Int,Rational{Int}}


## midi conversion helper functions

"float [0,1] to 14bit midi int conversion"
ftoi14(val::Float64) = clamp(convert(Int,round(val*16383)),0,16383)

"float [0,1] to 7bit midi int conversion"
ftoi7(val::Float64) = clamp(convert(Int,round(val*127)),0,127)

"midi int 7bit to float [0,1] conversion"
itof14(val::Int) = ( val = clamp(val,0,16383) ; val/16383. )

"midi int 14bit to float [0,1] conversion"
itof7(val::Int) = ( val = clamp(val,0,127) ; val/127. )


## audio expression abstract types

"abstract audio expression"
abstract Exp
"abstract atomic audio expression <: Exp"
abstract Atom <: Exp


"allows Int(s) to be interpreted as Exp(s)"
Expi = Union{Exp,Int}

"converts input to Exp"
toExp(x::Exp) = x


"A complex audio expression; an Exp made of zero or more Atom(s).  This is the only non-Atom implementation of Exp"
immutable Chord <: Exp
	xs::Vector{Atom}	# order not important, atoms contain thier own offset values
	
	Chord(xs::Vector{Atom}) = new(xs)
end

Chord() = Chord(Atom[])


## adds Chord to `mt` after its offset
## returns Chord length in ticks for `mt`
## see SirenSeq.Midi for MidiTrack
toTrack!(mt::MidiTrack, x::Chord) =  ( t1 = mt.ff ; for z in x.xs ; t1 = max(toTrack!(mt,z),t1) ; end ; t1 )


## used by C(xs...)
chordPush!(xs::Vector{Atom}, x::Atom) = push!(xs,x)
chordPush!(xs::Vector{Atom}, x::Chord) = for z in x.xs ; chordPush!(xs,z) ; end


"""
	C(xs...)

Creates a non-atomic audio expression (Chord) with members of `xs` all played at the same time.
"""
function C(xs...)
	zs = Atom[]
	for x::Expi in xs
		chordPush!(zs,toExp(x))
	end
	Chord(zs)
end


"""
	chordOp(op::Function, x::Expi)

Applies function `op` (Atom)->(Exp) to all members of `x`.

"""
chordOp(op::Function, x::Int) = chordOp(op,toExp(x))  
chordOp(op::Function, x::Atom) = ( zs = Atom[] ; chordPush!(zs,op(x)) ; length(zs) == 1 ? zs[1] : Chord(zs) )
chordOp(op::Function, x::Chord) = ( zs = Atom[] ; for y in x.xs ; chordPush!(zs,op(y)) ; end ; Chord(zs) )


## return copy of `x` with midi channel of all Atoms changed to `v`
channel(v::Int, x::Chord) = chordOp(z->channel(v,z),x)

## return copy of `x` with all Atom durations and offsets multiplied by `v`
dilate(v::Rational{Int}, x::Chord) = chordOp(z->dilate(v,z),x)

## return copy of `x` with `v` added to all Atom offsets
sshift(v::Rational{Int}, x::Chord) = chordOp(z->sshift(v,z),x)

## return copy of `x` with all Atom velocities mutiplied by `v`
accel(v::Float64, x::Chord) =  chordOp(z->accel(v,z),x)

## return copy of `x` with `v` added to all note inteval values
transl(v::Int, x::Chord) = chordOp(z->transl(v,z),x)

## return copy of `x` with `v` added to all note octave values
octave(v::Int, x::Chord) = chordOp(z->octave(v,z),x)

## return copy of `x` with all note scales changed to `v`
sscale(v::Function, x::Chord) = chordOp(z->sscale(v,z),x)


"""
	len(x::Expi)

Returns the length::IR (in whole-notes) of `x`.
"""
len(x::Chord) = reduce((z1,z2)->max(z1,len(z2)),0//1,x.xs)


## used by S(xs...)
seqPush!(xs::Vector{Atom}, x::Atom, t::Rational{Int}) = push!(xs,sshift(t,toExp(x)))
seqPush!(xs::Vector{Atom}, x::Chord, t::Rational{Int}) = for z in x.xs ; seqPush!(xs,z,t) ; end

"""
	S(xs...)

Creates a non-atomic audio expression (Chord) with members of `xs` all played in sequence.
"""
function S(xs...)
	zs = Atom[]
	t = 0//1
	for x::Expi in xs
		seqPush!(zs,toExp(x),t)
		t += len(x)
	end
	Chord(zs)
end






