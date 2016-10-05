

"""
Submodule of `SirenSeq`.
Used for writing MIDI files.
"""
module Midi


export 

## from this midi.jl

MidiTrack, writeMidiFile, tim, timm,

## from chanmess.jl

progSel!, bankSel!, noteOn!, noteOff!, pitchWheel!, chanAfter!, polyAfter!, control14!, control7!,

## from sysmess.jl

timeSigSet!, tempoSet!, trackEnd!, trackMarker!


abstract MidiMes
abstract ChanMes <: MidiMes
abstract SysMes <: MidiMes


"a collection of midi messages in a track"
type MidiTrack
	ms::Vector{MidiMes}		# set of midi messages, order in `ms` is irrelevant
	tpq::Int				# ticks per quarter note
	ff::Int					# current track head offset in ticks
	
	function MidiTrack(tpq::Int)
		@assert tpq > 0
		new(Any[],tpq,0)
	end
end


"""
	tim(mt::MidiTrack, v::Rational{Int}) -> Int

converts note length `v` to midi ticks for `mt`
"""
function tim(mt::MidiTrack, v::Rational{Int})
	x = v*mt.tpq*4 ;  @assert x >= 0
	round(Int,x)
end


"""
	timm(mt::MidiTrack, v::Rational{Int}) -> Int

converts note length `v` to midi ticks for `mt` and adds offset of `mt`
"""
function timm(mt::MidiTrack, v::Rational{Int})
	x = v*mt.tpq*4 + mt.ff ;  @assert x >= 0
	round(Int,x)
end


include("inout.jl")
include("sysmess.jl")
include("chanmess.jl")


## if events occur on the same tick in the track 
## these numbers are used to determine thier order

precValMidiMes(m::NoteOff) = 0
precValMidiMes(m::TrackMarker) = 1
precValMidiMes(m::TimeSigSet) = 2
precValMidiMes(m::TempoSet) = 3
precValMidiMes(m::BankSel) = 4
precValMidiMes(m::ProgSel) = 5
precValMidiMes(m::Control14) = 6
precValMidiMes(m::Control7) = 7
precValMidiMes(m::ChanAfter) = 8
precValMidiMes(m::NoteOn) = 9
precValMidiMes(m::PolyAfter) = 10
precValMidiMes(m::PitchWheel) = 11
precValMidiMes(m::TrackEnd) = 12


compMidiEvByType(m1::MidiMes, m2::MidiMes) = precValMidiMes(m1) < precValMidiMes(m2)


function compMidiMes(m1::MidiMes, m2::MidiMes)
	m1.time < m2.time && return true
	m1.time > m2.time && return false
	compMidiEvByType(m1,m2)
end


## used for verbose mode of `writeMidiFile`

function midiMesDesc(m::MidiMes)
	"$(typeof(m))"
end

function midiMesDesc(m::NoteOn)
	"$NoteOn    $(m.pitch)"
end

function midiMesDesc(m::NoteOff)
	"$NoteOff   $(m.pitch)"
end

function midiMesDesc(m::TrackMarker)
	"$TrackMarker   $(m.mes)"
end


function midiMessToBytes(mt::MidiTrack, verbose::Bool)
	ms::Vector{Any} = sort(mt.ms,lt=compMidiMes)
	if verbose
		println()
		for m::MidiMes in ms
			print("$(lpad(m.time,6))    $(lpad(round(10*m.time/(mt.tpq*4))/10,4))    $(midiMesDesc(m))\n")
		end
		println()
	end
	bs = UInt8[]
	tm = 0
	for m::MidiMes in ms
		@assert typeof(m) != TrackEnd
		append!(bs,bytesev(m,tm))
		tm = m.time
	end
	tm = max(tm,mt.ff)
	append!(bs,bytesev(TrackEnd(mt.ff+1),mt.ff))
	bs
end


"""
	writeMidiFile(out::IOStream, mt::MidiTrack, [verbose::Bool])

Writes `mt` as a midi file to `out`. If `verbose` is true, it will write a description of all events to standard output
"""
function writeMidiFile(out::IOStream, mt::MidiTrack, verbose::Bool)
	bs = midiMessToBytes(mt,verbose)
	writeFileHeaderT0(out,mt.tpq)
	writeTrackHeader(out,length(bs))
	write(out,bs)
end



end



 


