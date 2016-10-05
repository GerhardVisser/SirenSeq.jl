

## shortcut
typealias Rat Rational{Int}


"a type used to enter note lengths, e.g. 1//4 == quarter note length"
IR = Union{Int,Rat}


## midi conversion helper functions

"float [0,1] to 14bit midi int conversion"
ftoi14(val::Float64) = clamp(convert(Int,round(val*16383)),0,16383)

"float [0,1] to 7bit midi int conversion"
ftoi7(val::Float64) = clamp(convert(Int,round(val*127)),0,127)

"midi int 7bit to float [0,1] conversion"
itof14(val::Int) = ( val = clamp(val,0,16383) ; val/16383. )

"midi int 14bit to float [0,1] conversion"
itof7(val::Int) = ( val = clamp(val,0,127) ; val/127. )


"""
Abstract atomic audio expression. \\
Complex audio expressions (`Exp`) contain a list of these.
"""
abstract Atom

"when non-zero duration is required"
abstract Duratom <: Atom


"""
A complex audio expression. \\
It contains zero or more `Atom`(s). \\
It has its own duration seperate of its `Atom` members.
"""
immutable Exp
	dur::Rat			# duration
	as::Vector{Atom}	# order not important, atoms contain thier own offset values
end

Exp() = Exp(0//1,Atom[])


Base.convert(::Type{Exp}, a::Atom) = Exp(a.dur,Atom[a])


"""
	atomOrExp(z)

Tries to convert input to an `Atom`. \\
If that fails, tries to convert to `Exp`.
"""
atomOrExp(a::Atom) = a
atomOrExp(x::Exp) = x

function atomOrExp(z)
	try 
		return convert(Atom,z)
	catch
		return convert(Exp,z)
	end
end

"""
	offsets(x::Exp)

Returns `(t1,t2)` where, \\
`t1` is the start of the earliest `Atom` \\
`t2` is the end of the latest `Atom`
"""
function offsets(x::Exp)
	t1 = foldr((a,v)->min(a.ofs,v),1//0,x.as)
	t2 = foldr((a,v)->max(a.ofs+a.dur,v),-1//0,x.as)
	t1, t2
end


## adds x to mt after its offset
## returns x's length in ticks for mt
## see SirenSeq.Midi for MidiTrack
toTrack!(mt::MidiTrack, x::Exp) = ( t1 = mt.ff ; for a in x.as ; t1 = max(toTrack!(mt,a),t1) ; end ; t1 )


## used by C(zs...) and atomsOp
atomsPush!(as::Vector{Atom}, a::Atom) = ( push!(as,a) ; a.dur )
atomsPush!(as::Vector{Atom}, x::Exp) = ( for a in x.as ; atomsPush!(as,a) ; end ; x.dur )
atomsPush!(as::Vector{Atom}, z) = atomsPush!(as,atomOrExp(z))


"""
	C(zs...)

Creates a non-atomic audio expression (`Exp`) with members of `zs` all played at the same time.
"""
function C(zs...)
	as = Atom[]
	dur = 0//1
	for z in zs
		dd = atomsPush!(as,z)
		dur = max(dur,dd)
	end
	Exp(dur,as)
end


atomsOp(op::Function, x::Exp) = ( as = Atom[] ; for a in x.as ; atomsPush!(as,op(a)) ; end ; as )


## return copy of `x` with midi channel of all Atoms changed to `v`
function channel(v::Int, x::Exp)
	as = atomsOp(z->channel(v,z),x)
	Exp(x.dur,as)
end


## return copy of `x` with all Atom durations and offsets multiplied by `v`
function dilate(v::Rational{Int}, x::Exp)
	as = atomsOp(z->dilate(v,z),x)
	Exp(x.dur*v,as)
end


## return copy of `x` with `v` added to all Atom offsets
function sshift(v::Rational{Int}, x::Exp)
 	as = atomsOp(z->sshift(v,z),x)
	Exp(x.dur,as)
end


## return copy of `x` with all Atom velocities mutiplied by `v`
function accel(v::Float64, x::Exp)
	as = atomsOp(z->accel(v,z),x)
	Exp(x.dur,as)
end


## return copy of `x` with `v` added to all note inteval values
function transl(v::Int, x::Exp)
	as = atomsOp(z->transl(v,z),x)
	Exp(x.dur,as)
end


## return copy of `x` with `v` added to all note octave values
function octave(v::Int, x::Exp)
	as = atomsOp(z->octave(v,z),x)
	Exp(x.dur,as)
end


## return copy of `x` with all note scales changed to `v`
function sscale(v::Function, x::Exp)
	as = atomsOp(z->sscale(v,z),x)
	Exp(x.dur,as)
end


## used by S(zs...) and R(v,z)
function seqPush!(as::Vector{Atom}, a::Atom, dur::Rational{Int})
	a2 = sshift(dur,a)
	push!(as,a2)
	dur+a2.dur
end

function seqPush!(as::Vector{Atom}, x::Exp, dur::Rational{Int})
	for a in x.as
		a2 = sshift(dur,a)
		push!(as,a2)
	end
	dur+x.dur
end

seqPush!(as::Vector{Atom}, z, dur::Rational{Int}) = seqPush!(as,atomOrExp(z),dur)


"""
	S(zs...)

Creates a non-atomic audio expression (`Exp`) with members of `zs` all played in sequence.
"""
function S(zs...)
	as = Atom[]
	dur = 0//1
	for z in zs
		dur = seqPush!(as,z,dur)
	end
	Exp(dur,as)
end


"""
	R(v::Int, z)

Returns `z` repeated `v` times in sequence.
"""
function R(v::Int, z)
	@assert v > 0
	as = Atom[]
	dur = 0//1
	for i in 1:v
		dur = seqPush!(as,z,dur)
	end
	Exp(dur,as)
end






