

## functions for writing the midi codes as byte sequences


brev(v::UInt8) = v
brev(v::UInt16) = UInt8[(v>>8)%UInt8,(v)%UInt8]
brev(v::UInt32) = UInt8[(v>>24)%UInt8,(v>>16)%UInt8,(v>>8)%UInt8,(v)%UInt8]
brev(v::UInt64) = UInt8[(v>>56)%UInt8,(v>>48)%UInt8,(v>>40)%UInt8,(v>>32)%UInt8,(v>>24)%UInt8,(v>>16)%UInt8,(v>>8)%UInt8,(v)%UInt8]


msb14(v::UInt16) = (v>>7)%UInt8&0x7f
lsb14(v::UInt16) = (v)%UInt8&0x7f


function write14(out::IOStream, v::Integer)
	@assert 0 <= v < 2^14
	write(out,msb14(v%UInt16)) ;  write(out,lsb14(v%UInt16))
end


function varb(v::Integer)
	@assert 0 <= v < 2^28
	if v<2^7
		return UInt8[(v)%UInt8]
	elseif v<2^14
		return UInt8[(v>>7)%UInt8|0x80,(v)%UInt8&0x7f]
	elseif v<2^21
		return UInt8[(v>>14)%UInt8|0x80,(v>>7)%UInt8|0x80,(v)%UInt8&0x7f]
	else
		return UInt8[(v>>21)%UInt8|0x80,(v>>14)%UInt8|0x80,(v>>7)%UInt8|0x80,(v)%UInt8&0x7f]
	end
end


function writeFileHeaderT0(out::IOStream, tpq::Int)
	@assert 0 < tpq < 2^15
	write(out,ascii("MThd"))
 	write(out,UInt8[0x00,0x00,0x00,0x06,0x00,0x00,0x00,0x01])
	write(out,brev(tpq%UInt16))
end


function writeTrackHeader(out::IOStream, sz::Int)
	@assert 0 <= sz < 2^31
	write(out,ascii("MTrk"))
	write(out,brev(sz%UInt32))
end


function bytesTimeSig(num::Int, den::Int, clocks::Int, sub::Int)
	@assert 0 < num <= 32 ;  @assert 0 <= den <= 5
	@assert 0 < clocks < 128 ;  @assert 0 < sub <= 128
	UInt8[0xff,0x58,0x04,num%UInt8,den%UInt8,clocks%UInt8,sub%UInt8]
end


bytesDt(v::Int)  = varb(v)


function bytesTempo(bpm::Int)
	@assert 0 < bpm
	micspq = (div(10^6*60,bpm))%UInt32
	@assert 0 < micspq < 2^24
	vcat(UInt8[0xff,0x51,0x03],brev(micspq%UInt32)[2:4])
end


function bytesProgSelect(chan::Int, prog::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= prog < 128
	UInt8[0xC0|chan%UInt8,prog%UInt8]
end


function bytesNoteOn(chan::Int, pch::Int, vel::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= pch < 128 ;  @assert 0 <= vel < 128 
	UInt8[0x90|chan%UInt8,pch%UInt8,vel%UInt8]
end


function bytesNoteOff(chan::Int, pch::Int, vel::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= pch < 128 ;  @assert 0 <= vel < 128 
	UInt8[0x80|chan%UInt8,pch%UInt8,vel%UInt8]
end


function bytesPitchWheel(chan::Int, val::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= val < 2^14
	UInt8[0xe0|chan%UInt8,lsb14(val%UInt16),msb14(val%UInt16)]
end


function bytesChanAfter(chan::Int, val::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= val < 128
	UInt8[0xd0|chan%UInt8,val%UInt8]
end


function bytesPolyAfter(chan::Int, pitch::Int, val::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= pitch < 128 ;  @assert 0 <= val < 128
	UInt8[0xa0|chan%UInt8,pitch%UInt8,val%UInt8]
end


function bytesControl7(chan::Int, num::Int, val::Int)
	@assert 0 <= chan < 16 ;  @assert 64 <= num < 102 || 120 <= num < 128 ;  @assert 0 <= val < 128
	UInt8[0xb0|chan%UInt8,num%UInt8,val%UInt8]
end


function bytesControlMsb14(chan::Int, num::Int, val::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= num < 32 ;  @assert 0 <= val < 2^14
	UInt8[0xb0|chan%UInt8,num%UInt8,msb14(val%UInt16)]
end

function bytesControlLsb14(chan::Int, num::Int, val::Int)
	@assert 0 <= chan < 16 ;  @assert 0 <= num < 32 ;  @assert 0 <= val < 2^14
	UInt8[0xb0|chan%UInt8,(num+32)%UInt8,lsb14(val%UInt16)]
end


function bytesTrackEnd()
	UInt8[0xff,0x2f,0x00]
end


function bytesTrackMarker(mes::ASCIIString)
	len = length(mes) ;  @assert 0<len<128
	bs = UInt8[0xff,0x06,len%UInt8]
	for x in mes
		push!(bs,x%UInt8)
	end
	bs
end





