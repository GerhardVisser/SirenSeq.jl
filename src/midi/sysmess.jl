

## a time signature set event
immutable TimeSigSet <: SysMes
	time::Int
	num::Int
	den::Int
	clocks::Int
	sub::Int

	function TimeSigSet(tm::Int, num::Int, den::Int, clocks::Int, sub::Int)
		@assert 0 <= tm ;  @assert 0 < num <= 32 ;  @assert 0 <= den <= 5
		@assert 0 < clocks < 128 ;  @assert 0 < sub <= 128
		new(tm,num,den,clocks,sub)
	end
end

"""
	timeSigSet!(mt::MidiTrack, tm::Rational{Int}, num::Int, den::Int, clocks::Int, sub::Int)

Writes a time signature set event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, `num` {0..32} the numerator, 2^`den` {0..5} the denomenator, while `clocks` and `sub` are the clocks and subclocks values.
"""
function timeSigSet!(mt::MidiTrack, tm::Rational{Int}, num::Int, den::Int, clocks::Int, sub::Int)
	push!(mt.ms,TimeSigSet(timm(mt,tm),num,den,clocks,sub))
	timm(mt,tm)
end


## a tempos set event
immutable TempoSet <: SysMes
	time::Int
	bpm::Int

	function TempoSet(tm::Int, bpm::Int) 
		@assert 0 <= tm ;  @assert 0<bpm
		new(tm,bpm)
	end
end

"""
	tempoSet!(mt::MidiTrack, tm::Rational{Int}, bpm::Int)

Writes a tempos set event to `mt` at the current track offset plus `tm` note lengths.  `bpm` is the number of beats per minute.
"""
function tempoSet!(mt::MidiTrack, tm::Rational{Int}, bpm::Int)
	push!(mt.ms,TempoSet(timm(mt,tm),bpm))
	timm(mt,tm)
end


## a track end event
immutable TrackEnd <: SysMes
	time::Int

	function TrackEnd(tm::Int)
		@assert 0 <= tm
		new(tm)
	end
end

"""
	trackEnd!(mt::MidiTrack, tm::Rational{Int})

Writes a track end event  to `mt` at the current track offset plus `tm` note lengths.
"""
function trackEnd!(mt::MidiTrack, tm::Rational{Int})
	push!(mt.ms,TrackEnd(timm(mt,tm)))
	timm(mt,tm)
end


## a track marker event
immutable TrackMarker <: SysMes
	time::Int
	mes::ASCIIString

	function TrackMarker(tm::Int, mes::AbstractString)
		@assert 0 <= tm ;  @assert 0<length(mes)<128
		new(tm,ascii(mes))
	end
end

"""
	trackMarker!(mt::MidiTrack, tm::Rational{Int}, mes::AbstractString)

Writes a track marker event to `mt` at the current track offset plus `tm` note lengths. `mes` is the message
"""
function trackMarker!(mt::MidiTrack, tm::Rational{Int}, mes::AbstractString)
	push!(mt.ms,TrackMarker(timm(mt,tm),mes))
	timm(mt,tm)
end


## these convert ChanMes objects to byte sequences in the MIDI format

bytesev(m::TimeSigSet,tm::Int) = vcat(bytesDt(m.time-tm),bytesTimeSig(m.num,m.den,m.clocks,m.sub))

bytesev(m::TempoSet,tm::Int) = vcat(bytesDt(m.time-tm),bytesTempo(m.bpm))

bytesev(m::TrackEnd,tm::Int) = vcat(bytesDt(m.time-tm),bytesTrackEnd())

bytesev(m::TrackMarker,tm::Int) = vcat(bytesDt(m.time-tm),bytesTrackMarker(m.mes))






