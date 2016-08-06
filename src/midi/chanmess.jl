

## a program select event
immutable ProgSel <: ChanMes
	time::Int
	chan::Int
	prog::Int

	function ProgSel(tm::Int, ch::Int ,pr::Integer) 
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=pr<128
		new(tm,ch,round(Int,pr))
	end
end

"""
	progSel!(mt::MidiTrack, tm::Rational{Int}, ch::Int ,pr::Integer) 

Writes a program select event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel and `pr` {1..127} the program number.
"""
function progSel!(mt::MidiTrack, tm::Rational{Int}, ch::Int ,pr::Integer) 
	push!(mt.ms,ProgSel(timm(mt,tm),ch,pr))
	timm(mt,tm)
end


## a bank select event
immutable BankSel <: ChanMes
	time::Int
	chan::Int
	bank::Int

	function BankSel(tm::Int, ch::Int, bk::Integer) 
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=bk<2^14
		new(tm,ch,round(Int,bk))
	end
end

"""
	bankSel!(mt::MidiTrack, tm::Rational{Int}, ch::Int, bk::Integer) 

Writes a bank select event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel and `bk` the program bank number.
"""
function bankSel!(mt::MidiTrack, tm::Rational{Int}, ch::Int, bk::Integer) 
	push!(mt.ms,BankSel(timm(mt,tm),ch,bk))
	timm(mt,tm)
end


## a note on event
immutable NoteOn <: ChanMes
	time::Int
	chan::Int
	pitch::Int
	vel::Int

	function NoteOn(tm::Int, ch::Int, pch::Int, vel::Int)
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=pch<128 ;  @assert 0<=vel<128 
		new(tm,ch,pch,vel)
	end
end

"""
	noteOn!(mt::MidiTrack, tm::Rational{Int}, ch::Int, pch::Int, vel::Int)

Writes a note on event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, `pch` {0..127} the pitch, and `vel` {0..127} the velocity.
"""
function noteOn!(mt::MidiTrack, tm::Rational{Int}, ch::Int, pch::Int, vel::Int)
	push!(mt.ms,NoteOn(timm(mt,tm),ch,pch,vel))
	timm(mt,tm)
end


## a note off event
immutable NoteOff <: ChanMes
	time::Int
	chan::Int
	pitch::Int
	vel::Int

	function NoteOff(tm::Int, ch::Int, pch::Int, vel::Int)
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=pch<128 ;  @assert 0<=vel<128 
		new(tm,ch,pch,vel)
	end
end

"""
	noteOff!(mt::MidiTrack, tm::Rational{Int}, ch::Int, pch::Int, vel::Int)

Writes a note off event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, `pch` {0..127} the pitch, and `vel` {0..127} the velocity.
"""
function noteOff!(mt::MidiTrack, tm::Rational{Int}, ch::Int, pch::Int, vel::Int)
	push!(mt.ms,NoteOff(timm(mt,tm)-1,ch,pch,vel))
	timm(mt,tm)
end


## a pitch wheel bend event
immutable PitchWheel <: ChanMes
	time::Int
	chan::Int
	val::Int

	function PitchWheel(tm::Int, ch::Int, val::Int)
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=val<2^14
		new(tm,ch,val)
	end
end

"""
	pitchWheel!(mt::MidiTrack, tm::Rational{Int}, ch::Int, val::Int)

Writes a pitch wheel bend event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, and `val` {0..2^14-1} the value.
"""
function pitchWheel!(mt::MidiTrack, tm::Rational{Int}, ch::Int, val::Int)
	push!(mt.ms,PitchWheel(timm(mt,tm),ch,val))
	timm(mt,tm)
end


## a channel aftertouch event
immutable ChanAfter <: ChanMes
	time::Int
	chan::Int
	val::Int

	function ChanAfter(tm::Int, ch::Int, val::Int)
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=val<128
		new(tm,ch,val)
	end
end

"""
	chanAfter!(mt::MidiTrack, tm::Rational{Int}, ch::Int, val::Int)

Writes a channel aftertouch event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, and `val` {0..127} the value.
"""
function chanAfter!(mt::MidiTrack, tm::Rational{Int}, ch::Int, val::Int)
	push!(mt.ms,ChanAfter(timm(mt,tm),ch,val))
	timm(mt,tm)
end


## a polyphonic aftertouch event
immutable PolyAfter <: ChanMes
	time::Int
	chan::Int
	pitch::Int
	val::Int

	function PolyAfter(tm::Int, ch::Int, pch::Int, val::Int)
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=pch<128 ;  @assert 0<=val<128
		new(tm,ch,pch,val)
	end
end

"""
	polyAfter!(mt::MidiTrack, tm::Rational{Int}, ch::Int, pch::Int, val::Int)

Writes a polyphonic aftertouch event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, `pch` {0..127} is the pitch, and `val` {0..127} the value.
"""
function polyAfter!(mt::MidiTrack, tm::Rational{Int}, ch::Int, pch::Int, val::Int)
	push!(mt.ms,PolyAfter(timm(mt,tm),ch,pch,val))
	timm(mt,tm)
end


## a 14bit channel control event
immutable Control14 <: ChanMes
	time::Int
	chan::Int
	num::Int
	val::Int

	function Control14(tm::Int, ch::Int, nm::Integer, val::Int)
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 0<=nm<32 ;  @assert 0<=val<2^14
		new(tm,ch,round(Int,nm),val)
	end
end

"""
	control14!(mt::MidiTrack, tm::Rational{Int}, ch::Int, nm::Integer, val::Int)

Writes a 14bit channel control event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, `nm` {0..31} is the contol number, and `val` {0..2^14-1} the value.
"""
function control14!(mt::MidiTrack, tm::Rational{Int}, ch::Int, nm::Integer, val::Int)
	push!(mt.ms,Control14(timm(mt,tm),ch,nm,val))
	timm(mt,tm)
end


## a 7bit channel control event
immutable Control7 <: ChanMes
	time::Int
	chan::Int
	num::Int
	val::Int

	function Control7(tm::Int, ch::Int, nm::Integer, val::Int)
		@assert 0 <= tm ;  @assert 1<=ch<=16 ;  @assert 64<=nm<102 || 120 <= nm < 128 ;  @assert 0<=val<128
		new(tm,ch,round(Int,nm),val)
	end
end

"""
	control7!(mt::MidiTrack, tm::Rational{Int}, ch::Int, nm::Integer, val::Int)

Writes a 7bit channel control event to `mt` at the current track offset plus `tm` note lengths.  `ch` {1..16} is the channel, `nm` {64..101,120..127} is the contol number, and `val` {0..127} the value.
"""
function control7!(mt::MidiTrack, tm::Rational{Int}, ch::Int, nm::Integer, val::Int)
	push!(mt.ms,Control7(timm(mt,tm),ch,nm,val))
	timm(mt,tm)
end


## these convert ChanMes objects to byte sequences in the MIDI format

bytesev(m::ProgSel,tm::Int) = vcat(bytesDt(m.time-tm),bytesProgSelect(m.chan-1,m.prog))

function bytesev(m::BankSel,tm::Int)
	tb = bytesDt(m.time-tm)
	vcat(tb, bytesControlMsb14(m.chan-1,0,m.bank), tb,bytesControlLsb14(m.chan-1,0,m.bank))
end

bytesev(m::NoteOn,tm::Int) = vcat(bytesDt(m.time-tm),bytesNoteOn(m.chan-1,m.pitch,m.vel))

bytesev(m::NoteOff,tm::Int) = vcat(bytesDt(m.time-tm),bytesNoteOff(m.chan-1,m.pitch,m.vel))

bytesev(m::PitchWheel,tm::Int) = vcat(bytesDt(m.time-tm),bytesPitchWheel(m.chan-1,m.val))

bytesev(m::ChanAfter,tm::Int) = vcat(bytesDt(m.time-tm),bytesChanAfter(m.chan-1,m.val))

bytesev(m::PolyAfter,tm::Int) = vcat(bytesDt(m.time-tm),bytesPolyAfter(m.chan-1,m.pitch,m.val))

function bytesev(m::Control14,tm::Int)
	tb = bytesDt(m.time-tm)
	vcat(tb,bytesControlMsb14(m.chan-1,m.num,m.val),tb,bytesControlLsb14(m.chan-1,m.num,m.val))
end

bytesev(m::Control7,tm::Int) = vcat(bytesDt(m.time-tm),bytesControl7(m.chan-1,m.num,m.val))






