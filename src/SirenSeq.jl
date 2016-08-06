module SirenSeq



include("midi/Midi.jl")
include("scales/Scales.jl")

using SirenSeq.Midi
using SirenSeq.Scales


include("constants/GenFluidSF144.jl")
include("constants/GenMuseScoreSF144.jl")
include("constants/GmDrums.jl")


## use Julia commandline ? option for exported function descritions
export

## from basics.jl
IR, Exp, Expi, Atom,
C, S, R,
len, ftoi14, ftoi7, itof14, itof7,
chordOp, toExp,

## from shortcuts.jl
D, F, A, T, V, Cha, Sca,
setDefaultScale, setDefaultOctave,
N, B,
Bank, Prog, Vol,
Wh, Aft, Cn7, Cn14,
Sus0, Sus1,
SoundsOff, CntrlOff, NotesOff, 
Mark, Sig, Tpo,
Inst, Con, Kl, Spl, Da,

## from exportmidi.jl
setDefaultBpm, makeMidi



include("basics.jl")
include("atoms.jl")
include("shortcuts.jl")
include("display.jl")
include("exportmidi.jl")
include("playmidi.jl")
include("midirender.jl")



end
