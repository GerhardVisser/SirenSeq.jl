
"""
Submodule of `SirenSeq`.
Used for playing `SirenSeq` expressions using `csound` or writing them to audio files.
Must have `csound` installed.
"""
module Csound


export

CsHead, SoundFont, FluidInst,
generateOrc


using SirenSeq


"""
Options for a `csound` orchestra file `.orc` file to be generated.
"""
type CsHead
	str::AbstractString  # csound options string
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


"""
Generates a `csound` orchestra file at `path.orc`.
Do not include the `.orc` in your path
`ns` is a list of instruments (`<:CsInstr`)
"""
function generateOrc(head::CsHead, ns; path::AbstractString="temp")
	file = open("$(path).orc","w")
	s = 
"""
<CsoundSynthesizer>

<CsOptions>
$(head.str)
</CsOptions>

<CsInstruments>

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
s = 
"""
</CsInstruments>

</CsoundSynthesizer>
"""
	write(file,s)
	close(file)
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
	s = 
"""
giPre_$(n.name)	sfpreset	14, 0, giSf$(sfd[n.soundfont]), 0 

	instr fluidI_$(n.name)

ivel = p6
ifrq = p5
ikey = int(69 + 12*log2(ifrq/440))
iamp = 0dbfs/16384
iamp = iamp*ivel/127
aVl, aVr  sfplay3  ivel, ikey, iamp, ifrq, giPre_$(n.name), 1
	outs  aVl, aVr

	endin

"""
	s
end





end
