
"""
Submodule of `SirenSeq`.
Standard musical scales are defined here.
"""
module Scales



## a scale is a function that takes (ocv::Int, val::Int) as input and outputs a midi pitch value {0..127}
## `ocv` is an octave offset while `val` is the note interval on the scale
## scales can be any length between 1 and 11


export

## standard 7 note scales

aLyd,aMaj,aMix,aDor,aMin,aPhr,aLoc,
bLyd,bMaj,bMix,bDor,bMin,bPhr,bLoc,
cLyd,cMaj,cMix,cDor,cMin,cPhr,cLoc,
dLyd,dMaj,dMix,dDor,dMin,dPhr,dLoc,
eLyd,eMaj,eMix,eDor,eMin,ePhr,eLoc,
fLyd,fMaj,fMix,fDor,fMin,fPhr,fLoc,
gLyd,gMaj,gMix,gDor,gMin,gPhr,gLoc,

## a scale which ignores `ocv` and uses `val` as the midi pitch value
## useful for percussion tracks

noScale,

## returns the pitch value for a given scale and given (octave,interval) pair

getPitch


abstract Scale

type ChromaticMode <: Scale
	pmap::Dict{Int,Int}
	basev::Int
	name::AbstractString
end

type PercussionScale <: Scale
	name::AbstractString
end


function Base.isequal(x::ChromaticMode, y::ChromaticMode)
	if !isequal(x.pmap,y.pmap) ; return false ; end
	if !isequal(x.basev,y.basev) ; return false ; end
	if !isequal(x.name,y.name) ; return false ; end
	true
end

function Base.isequal(x::PercussionScale, y::PercussionScale)
	true
end

function Base.isequal(x::PercussionScale, y::ChromaticMode)
	false
end

function toPitch(ocv::Int, val::Int, scaleDict::Dict{Int,Int}, ofs::Int)
	ssz = length(scaleDict) ;  @assert  0 < ssz < 12
	while val < 1
		val += ssz
		ocv -= 1
	end
	while val > ssz
		val -= ssz
		ocv += 1
	end
	clamp(ofs+scaleDict[val]+60+12*(ocv-4),0,127)
end


## returns the pitch value for a given scale and given (octave,interval) pair
function getPitch(sca::ChromaticMode, ocv::Int, val::Int)
	toPitch(ocv,val,sca.pmap,sca.basev)
end

function getPitch(sca::PercussionScale, ocv::Int, val::Int)
	clamp(val,0,127)
end


const cLydDc = Dict{Int,Int}( 1=>0, 2=>2, 3=>4, 4=>6, 5=>7, 6=>9, 7=>11 )
const cMajDc = Dict{Int,Int}( 1=>0, 2=>2, 3=>4, 4=>5, 5=>7, 6=>9, 7=>11 )
const cMixDc = Dict{Int,Int}( 1=>0, 2=>2, 3=>4, 4=>5, 5=>7, 6=>9, 7=>10 )
const cDorDc = Dict{Int,Int}( 1=>0, 2=>2, 3=>4, 4=>5, 5=>7, 6=>8, 7=>10 )
const cMinDc = Dict{Int,Int}( 1=>0, 2=>2, 3=>3, 4=>5, 5=>7, 6=>8, 7=>10 )
const cPhrDc = Dict{Int,Int}( 1=>0, 2=>1, 3=>3, 4=>5, 5=>7, 6=>8, 7=>10 )
const cLocDc = Dict{Int,Int}( 1=>0, 2=>1, 3=>3, 4=>5, 5=>6, 6=>8, 7=>10 )


noScale = PercussionScale("perc")

aLyd = ChromaticMode(cLydDc,-3,"cLyd")
aMaj = ChromaticMode(cMajDc,-3,"cMaj")
aMix = ChromaticMode(cMixDc,-3,"cMix")
aDor = ChromaticMode(cDorDc,-3,"aDor")
aMin = ChromaticMode(cMinDc,-3,"aMin")
aPhr = ChromaticMode(cPhrDc,-3,"aPhr")
aLoc = ChromaticMode(cLocDc,-3,"aLoc")

bLyd = ChromaticMode(cLydDc,-1,"bLyd")
bMaj = ChromaticMode(cMajDc,-1,"bMaj")
bMix = ChromaticMode(cMixDc,-1,"bMix")
bDor = ChromaticMode(cDorDc,-1,"bDor")
bMin = ChromaticMode(cMinDc,-1,"bMin")
bPhr = ChromaticMode(cPhrDc,-1,"bPhr")
bLoc = ChromaticMode(cLocDc,-1,"bLoc")

cLyd = ChromaticMode(cLydDc,0,"cLyd")
cMaj = ChromaticMode(cMajDc,0,"cMaj")
cMix = ChromaticMode(cMixDc,0,"cMix")
cDor = ChromaticMode(cDorDc,0,"cDor")
cMin = ChromaticMode(cMinDc,0,"cMin")
cPhr = ChromaticMode(cPhrDc,0,"cPhr")
cLoc = ChromaticMode(cLocDc,0,"cLoc")

dLyd = ChromaticMode(cLydDc,2,"dLyd")
dMaj = ChromaticMode(cMajDc,2,"dMaj")
dMix = ChromaticMode(cMixDc,2,"dMix")
dDor = ChromaticMode(cDorDc,2,"dDor")
dMin = ChromaticMode(cMinDc,2,"dMin")
dPhr = ChromaticMode(cPhrDc,2,"dPhr")
dLoc = ChromaticMode(cLocDc,2,"dLoc")

eLyd = ChromaticMode(cLydDc,4,"eLyd")
eMaj = ChromaticMode(cMajDc,4,"eMaj")
eMix = ChromaticMode(cMixDc,4,"eMix")
eDor = ChromaticMode(cDorDc,4,"eDor")
eMin = ChromaticMode(cMinDc,4,"eMin")
ePhr = ChromaticMode(cPhrDc,4,"ePhr")
eLoc = ChromaticMode(cLocDc,4,"eLoc")

fLyd = ChromaticMode(cLydDc,6,"fLyd")
fMaj = ChromaticMode(cMajDc,6,"fMaj")
fMix = ChromaticMode(cMixDc,6,"fMix")
fDor = ChromaticMode(cDorDc,6,"fDor")
fMin = ChromaticMode(cMinDc,6,"fMin")
fPhr = ChromaticMode(cPhrDc,6,"fPhr")
fLoc = ChromaticMode(cLocDc,6,"fLoc")

gLyd = ChromaticMode(cLydDc,7,"gLyd")
gMaj = ChromaticMode(cMajDc,7,"gMaj")
gMix = ChromaticMode(cMixDc,7,"gMix")
gDor = ChromaticMode(cDorDc,7,"gDor")
gMin = ChromaticMode(cMinDc,7,"gMin")
gPhr = ChromaticMode(cPhrDc,7,"gPhr")
gLoc = ChromaticMode(cLocDc,7,"gLoc")



end






