

## some functions for showing Exp objects

function Base.show(io::IO, x::Chord)
	print(io,"Chord:\n")
	for z in x.xs ; print(io,"  $z\n") ; end
end

function Base.show(io::IO, x::Note)
	print(io,"Note:   ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "dur = %s, " "$(x.dur)" ; s = rpad(s,14)
	print(io,s)
	s = @sprintf "itv = %2d, " x.itv ; s = rpad(s,11)
	print(io,s)
	s = @sprintf "ocv = %d, " x.ocv ; s = rpad(s,10)
	print(io,s)
	s = @sprintf "vel = %.2f,  " x.vel
	print(io,s)
	print(io,"sca = $(x.sca)")
end

function Base.show(io::IO, x::Blank)
	print(io,"Blank:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "dur = %s, " "$(x.dur)" ; s = rpad(s,14)
	print(io,s)
end

function Base.show(io::IO, x::BankSel)
	print(io,"Blank-Select:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "bank = %d" x.bank
	print(io,s)
end

function Base.show(io::IO, x::ProgSel)
	print(io,"Program-Select:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "prog = %d" x.prog
	print(io,s)
end

function Base.show(io::IO, x::VolSet)
	print(io,"Volume-Set:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "vol = %.2f" x.vol
	print(io,s)
end

function Base.show(io::IO, x::PitchWheel)
	print(io,"Pitch-Wheel:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "val = %.3f" (x.val-2^13)/(2^13)
	print(io,s)
end

function Base.show(io::IO, x::ChanAfter)
	print(io,"Channel-Aftertouch:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "val = %.2f" x.val/127
	print(io,s)
end

function Base.show(io::IO, x::Control7)
	print(io,"Control-7bit:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "num = %d,  " x.num
	print(io,s)
	s = @sprintf "val = %d" x.val
	print(io,s)
end

function Base.show(io::IO, x::Control14)
	print(io,"Control-14bit:  ")
	s = @sprintf "ch%d, " x.cha ; s = rpad(s,7)
	print(io,s)	
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "num = %d,  " x.num
	print(io,s)
	s = @sprintf "val = %d" x.val
	print(io,s)
end

function Base.show(io::IO, x::Marker)
	print(io,"Marker:  ")
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "name = %s" x.name
	print(io,s)
end

function Base.show(io::IO, x::TimeSignature)
	print(io,"Time-Signature:  ")
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "num = %d,  " x.num
	print(io,s)
	s = @sprintf "den = %d,  " x.den
	print(io,s)
	s = @sprintf "clocks = %d,  " x.clocks
	print(io,s)
	s = @sprintf "sub = %d" x.sub
	print(io,s)
end

function Base.show(io::IO, x::Tempo)
	print(io,"Tempo-Set:  ")
	s = @sprintf "ofs = %d + %s, " div(x.ofs,1//1) "$(mod(x.ofs,1//1))" ; s = rpad(s,18)
	print(io,s)
	s = @sprintf "bpm = %d" x.bpm
	print(io,s)
end






