

## some functions for showing Exp objects


function offsetString(ofs::Rational{Int})
	v1, v2 = divrem(ofs,1//1)
	if v2 < 0 ; v1 -= 1//1 ; v2 += 1//1 ; end
	s = @sprintf "ofs = %2d + %s, " v1 "$v2" ; s = rpad(s,18)
	s
end


function Base.show(io::IO, x::Exp)
	print(io,"Exp:    dur = $(x.dur)")
	for a in x.as ; print(io,"\n  $a") ; end
end

function Base.show(io::IO, a::Note)
	print(io,"Note:   ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "dur = %s, " "$(a.dur)" ; s = rpad(s,14)
	print(io,s)
	s = @sprintf "itv = %2d, " a.itv ; s = rpad(s,11)
	print(io,s)
	s = @sprintf "ocv = %d, " a.ocv ; s = rpad(s,10)
	print(io,s)
	s = @sprintf "vel = %.2f,  " a.vel
	print(io,s)
	print(io,"sca = $(a.sca.name)")
end

function Base.show(io::IO, a::BankSel)
	print(io,"Blank-Select:  ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)	
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "bank = %d" a.bank
	print(io,s)
end

function Base.show(io::IO, a::ProgSel)
	print(io,"Program-Select:  ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)	
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "prog = %d" a.prog
	print(io,s)
end

function Base.show(io::IO, a::VolSet)
	print(io,"Volume-Set:  ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)	
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "vol = %.2f" a.vol
	print(io,s)
end

function Base.show(io::IO, a::PitchWheel)
	print(io,"Pitch-Wheel:  ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)	
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "val = %.3f" (a.val-2^13)/(2^13)
	print(io,s)
end

function Base.show(io::IO, a::ChanAfter)
	print(io,"Channel-Aftertouch:  ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)	
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "val = %.2f" a.val/127
	print(io,s)
end

function Base.show(io::IO, a::Control7)
	print(io,"Control-7bit:  ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)	
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "num = %d,  " a.num
	print(io,s)
	s = @sprintf "val = %d" a.val
	print(io,s)
end

function Base.show(io::IO, a::Control14)
	print(io,"Control-14bit:  ")
	s = @sprintf "ch%d, " a.cha ; s = rpad(s,7)
	print(io,s)	
	vs = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "num = %d,  " a.num
	print(io,s)
	s = @sprintf "val = %d" a.val
	print(io,s)
end

function Base.show(io::IO, a::Marker)
	print(io,"Marker:  ")
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "name = \"%s\"" a.name
	print(io,s)
end

function Base.show(io::IO, a::TimeSignature)
	print(io,"Time-Signature:  ")
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "num = %d,  " a.num
	print(io,s)
	s = @sprintf "den = %d,  " a.den
	print(io,s)
	s = @sprintf "clocks = %d,  " a.clocks
	print(io,s)
	s = @sprintf "sub = %d" a.sub
	print(io,s)
end

function Base.show(io::IO, a::Tempo)
	print(io,"Tempo-Set:  ")
	s = offsetString(a.ofs)
	print(io,s)
	s = @sprintf "bpm = %d" a.bpm
	print(io,s)
end






