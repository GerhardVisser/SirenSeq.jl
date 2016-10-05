
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

noScale


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


const cLydDc = Dict( 1=>0, 2=>2, 3=>4, 4=>6, 5=>7, 6=>9, 7=>11 )
const cMajDc = Dict( 1=>0, 2=>2, 3=>4, 4=>5, 5=>7, 6=>9, 7=>11 )
const cMixDc = Dict( 1=>0, 2=>2, 3=>4, 4=>5, 5=>7, 6=>9, 7=>10 )
const cDorDc = Dict( 1=>0, 2=>2, 3=>4, 4=>5, 5=>7, 6=>8, 7=>10 )
const cMinDc = Dict( 1=>0, 2=>2, 3=>3, 4=>5, 5=>7, 6=>8, 7=>10 )
const cPhrDc = Dict( 1=>0, 2=>1, 3=>3, 4=>5, 5=>7, 6=>8, 7=>10 )
const cLocDc = Dict( 1=>0, 2=>1, 3=>3, 4=>5, 5=>6, 6=>8, 7=>10 )


noScale(ocv::Int,val::Int) = clamp(val,0,127)

aLyd(ocv::Int,val::Int) = toPitch(ocv,val,cLydDc,-3)
aMaj(ocv::Int,val::Int) = toPitch(ocv,val,cMajDc,-3)
aMix(ocv::Int,val::Int) = toPitch(ocv,val,cMixDc,-3)
aDor(ocv::Int,val::Int) = toPitch(ocv,val,cDorDc,-3)
aMin(ocv::Int,val::Int) = toPitch(ocv,val,cMinDc,-3)
aPhr(ocv::Int,val::Int) = toPitch(ocv,val,cPhrDc,-3)
aLoc(ocv::Int,val::Int) = toPitch(ocv,val,cLocDc,-3)

bLyd(ocv::Int,val::Int) = toPitch(ocv,val,cLydDc,-1)
bMaj(ocv::Int,val::Int) = toPitch(ocv,val,cMajDc,-1)
bMix(ocv::Int,val::Int) = toPitch(ocv,val,cMixDc,-1)
bDor(ocv::Int,val::Int) = toPitch(ocv,val,cDorDc,-1)
bMin(ocv::Int,val::Int) = toPitch(ocv,val,cMinDc,-1)
bPhr(ocv::Int,val::Int) = toPitch(ocv,val,cPhrDc,-1)
bLoc(ocv::Int,val::Int) = toPitch(ocv,val,cLocDc,-1)

cLyd(ocv::Int,val::Int) = toPitch(ocv,val,cLydDc,0)
cMaj(ocv::Int,val::Int) = toPitch(ocv,val,cMajDc,0)
cMix(ocv::Int,val::Int) = toPitch(ocv,val,cMixDc,0)
cDor(ocv::Int,val::Int) = toPitch(ocv,val,cDorDc,0)
cMin(ocv::Int,val::Int) = toPitch(ocv,val,cMinDc,0)
cPhr(ocv::Int,val::Int) = toPitch(ocv,val,cPhrDc,0)
cLoc(ocv::Int,val::Int) = toPitch(ocv,val,cLocDc,0)

dLyd(ocv::Int,val::Int) = toPitch(ocv,val,cLydDc,2)
dMaj(ocv::Int,val::Int) = toPitch(ocv,val,cMajDc,2)
dMix(ocv::Int,val::Int) = toPitch(ocv,val,cMixDc,2)
dDor(ocv::Int,val::Int) = toPitch(ocv,val,cDorDc,2)
dMin(ocv::Int,val::Int) = toPitch(ocv,val,cMinDc,2)
dPhr(ocv::Int,val::Int) = toPitch(ocv,val,cPhrDc,2)
dLoc(ocv::Int,val::Int) = toPitch(ocv,val,cLocDc,2)

eLyd(ocv::Int,val::Int) = toPitch(ocv,val,cLydDc,4)
eMaj(ocv::Int,val::Int) = toPitch(ocv,val,cMajDc,4)
eMix(ocv::Int,val::Int) = toPitch(ocv,val,cMixDc,4)
eDor(ocv::Int,val::Int) = toPitch(ocv,val,cDorDc,4)
eMin(ocv::Int,val::Int) = toPitch(ocv,val,cMinDc,4)
ePhr(ocv::Int,val::Int) = toPitch(ocv,val,cPhrDc,4)
eLoc(ocv::Int,val::Int) = toPitch(ocv,val,cLocDc,4)

fLyd(ocv::Int,val::Int) = toPitch(ocv,val,cLydDc,6)
fMaj(ocv::Int,val::Int) = toPitch(ocv,val,cMajDc,6)
fMix(ocv::Int,val::Int) = toPitch(ocv,val,cMixDc,6)
fDor(ocv::Int,val::Int) = toPitch(ocv,val,cDorDc,6)
fMin(ocv::Int,val::Int) = toPitch(ocv,val,cMinDc,6)
fPhr(ocv::Int,val::Int) = toPitch(ocv,val,cPhrDc,6)
fLoc(ocv::Int,val::Int) = toPitch(ocv,val,cLocDc,6)

gLyd(ocv::Int,val::Int) = toPitch(ocv,val,cLydDc,7)
gMaj(ocv::Int,val::Int) = toPitch(ocv,val,cMajDc,7)
gMix(ocv::Int,val::Int) = toPitch(ocv,val,cMixDc,7)
gDor(ocv::Int,val::Int) = toPitch(ocv,val,cDorDc,7)
gMin(ocv::Int,val::Int) = toPitch(ocv,val,cMinDc,7)
gPhr(ocv::Int,val::Int) = toPitch(ocv,val,cPhrDc,7)
gLoc(ocv::Int,val::Int) = toPitch(ocv,val,cLocDc,7)



end






