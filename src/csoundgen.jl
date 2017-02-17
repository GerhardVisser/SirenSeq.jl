


using SirenSeq


"""
Options for a `csound` orchestra file `.orc` file to be generated.
"""
type CsHead
	dacStr::AbstractString  # csound options string
	sr::Int  # sample rate
	ksmps::Int  # samples per control cycle
end

CsHead() = CsHead("-odac",44100,32)


"""
A sound font `sf2` file reference.
"""
type SoundFont
	path::AbstractString
end


function Base.isequal(x::SoundFont, y::SoundFont)
	isequal(x.path,y.path)
end


"""
Abstract type for all `csound` instruments
"""
abstract CsInstr


"""
A single fluid synth instrument.
Give each instrument a unique name.
The same names will be used in the generated `csound` orchestra file.
"""
type FluidInst <: CsInstr
	name::AbstractString
	soundfont::SoundFont
	bank::Int # bank number in soundfont file
	prog::Int # program number in soundfont file
	isMono::Bool # else is stereo
end

FluidInst(name::AbstractString, sf::SoundFont, bank::Int, prog::Int) = FluidInst(name,sf,bank,prog,false)

FluidInst(name::AbstractString, sf::SoundFont, inst::Tuple{Int,Int}) = FluidInst(name,sf,inst[1],inst[2],false)


## name of oinstrument as will appear in the csound files
function instrName(n::FluidInst)
	"fluidI_$(n.name)"
end


"""
	makeOrc(head::CsHead, ns; path::AbstractString=\"temp\")

Generates a `csound` orchestra file at `path.orc`.

`head` defines some options of to-be-generated file \\
`ns` is a list of instruments (`<:CsInstr`) \\
`path` is the file name (do not append \".orc\", that is done automatically)
"""
function makeOrc(head::CsHead, ns; path::AbstractString="temp")
	file = open("$(path).orc","w")
	s = 
"""

sr = $(head.sr)
ksmps = $(head.ksmps)
nchnls = 2
0dbfs = 1

"""
	write(file,s)
	sfs = Set{SoundFont}()
	nsns = Set{AbstractString}()
	for n in ns
		if !isa(n,CsInstr) ; throw(ErrorException("second argument (ns) must be a list of instruments (<:CsInstr)")) ; end
		pushSfs!(sfs,n)
		push!(nsns,n.name)
		for ch in n.name
			if 'A'>ch || 'z'<ch ; throw(ErrorException("invalid instrument name: $(n.name)")) ; end
		end
	end
	if length(nsns) < length(ns) ; throw(ErrorException("all instruments must have unique names")) ; end
	i = 1
	sfd = Dict{SoundFont,Int}()
	for sf in sfs
		sfd[sf] = i
		s = generateSfOrg(sf,i)
		i += 1
		write(file,s)
	end
	if i>1 ; write(file,"\n") ; end
	for n in ns
		s = generateInstrOrg(n,sfd)
		write(file,s)
	end
	close(file)
	println("orchestra file written to:\n  $(path).orc")
end


function pushSfs!(sfs::Set{SoundFont}, n::FluidInst)
	push!(sfs,n.soundfont)
end


## Generates the `csound` orchestra file part for a single soundfont
function generateSfOrg(sf::SoundFont, i::Int)
	s = "giSf$(i)  sfload  \"$(sf.path)\"\n"
	s
end


## Generates the `csound` orchestra file part for a single instrument
function generateInstrOrg(n::FluidInst, sfd::Dict{SoundFont,Int})
	nn = instrName(n)
	s = 
"""
giPre_$(n.name)  sfpreset  $(n.prog), $(n.bank), giSf$(sfd[n.soundfont]), 0

	instr $(nn)

ivel = p5
ifrq = p4
ikey = int(69 + 12*log2(ifrq/440))
iamp = 0dbfs/16384
iamp = iamp*ivel/127
aVl, aVr  sfplay3  ivel, ikey, iamp, ifrq, giPre_$(n.name), 1
	outs  aVl, aVr

	endin

"""
	s
end



