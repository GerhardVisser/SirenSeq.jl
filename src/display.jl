

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






