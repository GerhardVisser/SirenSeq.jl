using SirenSeq
using Base.Test


module Numer

testC = 0
get() = testC
inc() = ( global testC += 1 ; )

handler(r::Test.Success) = println("test $(testC):  success\n")
handler(r::Test.Failure) = println("test $(testC):  FAILURE!\n")
handler(r::Test.Error) = nothing

end


Test.with_handler(Numer.handler) do



## printing tests

Numer.inc()
s1 = string(N(7))
s2 = "Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj"

@test s1 == s2

Numer.inc()
s1 = string(S(1,2))
s2 = "Exp:    dur = 2//1
  Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  1,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  1 + 0//1,  dur = 1//1,   itv =  2,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj"

@test s1 == s2

Numer.inc()
s1 = string(C(Bank(9),Prog(3)))
s2 = "Exp:    dur = 0//1
  Blank-Select:  ch1,   ofs =  0 + 0//1,  bank = 9
  Program-Select:  ch1,   ofs =  0 + 0//1,  prog = 3"

@test s1 == s2


##



end






