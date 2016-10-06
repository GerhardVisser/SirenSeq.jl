using SirenSeq
using Base.Test


module TestNames

testC = 0
nextName = "dummy"
testName(name::AbstractString) = ( global testC += 1 ; global nextName = name ; testC )

handler(r::Test.Success) = println("test $(testC):  success")
handler(r::Test.Failure) = println("test $(testC):  FAILURE!\n    $(nextName)")
handler(r::Test.Error) = println("test $(testC):  ERROR!\n    $(nextName)")

end


using TestNames.testName


Test.with_handler(TestNames.handler) do



## printing tests

testName("print note")
s1 = string(N(7))
s2 = "Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj"

@test s1 == s2

testName("print sequence 1")
s1 = string(S(1,2))
s2 = "Exp:    dur = 2//1
  Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  1,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  1 + 0//1,  dur = 1//1,   itv =  2,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj"

@test s1 == s2

testName("print sequence 2")
s1 = string(C(Bank(9),Prog(3)))
s2 = "Exp:    dur = 0//1
  Blank-Select:  ch1,   ofs =  0 + 0//1,  bank = 9
  Program-Select:  ch1,   ofs =  0 + 0//1,  prog = 3"

@test s1 == s2


## iseqauls tests


testName("atom equality 1")
@test isequal( N(1), N(1) )

testName("atom equality 2")
@test isequal( Bank(1113), Bank(1113) )

testName("atom equality 3")
@test isequal( Bank(1), Bank(2) ) == false

testName("atom equality 4")
@test isequal(N(1),N(2)) == false


testName("blank equality 1")
@test isequal( B(1//3), B(1//3) )

testName("blank equality 2")
@test isequal( B(1//3), B(2//3) ) == false


testName("sequence equality 1")
@test isequal( S(1,3), S(1,3) )

testName("sequence equality 2")
@test isequal( S(1,N(3)), S(N(1),3) )

testName("sequence equality 3")
@test isequal( S(1,3), S(1,4) ) == false

testName("sequence equality 4")
@test isequal( S(1,2,S(3,4)), S(1,2,3,4) )

testName("sequence equality 5")
@test isequal( S(1,2,3), S(3,2,1) ) == false


testName("chord equality 1")
@test isequal( C(1,2), C(1,2) )

testName("chord equality 2")
@test isequal( C(1,2), C(1,3) ) == false

testName("chord equality 3")
@test isequal( C(C(3,4),1,2), C(1,2,3,4) )


testName("exression equality 1")
@test isequal( C(S(1,2),S(4,5)), S(C(1,4),C(2,5)) )

testName("exression equality 2")
@test isequal( S(1,2,3,B()), C(S(1,2,3),B(4)) )


testName("accelirate equality 1")
@test isequal( A(0.5,4), A(0.5,N(4)) )

testName("accelirate equality 2")
@test isequal( N(4), A(2.0,A(0.5,4)) )

testName("accelirate equality 3")
@test isequal( A(0.7,S(1,2)), S(A(0.7,1),A(0.7,2)) )


testName("dilate equality 1")
@test isequal( D(1//3,4), D(1//3,N(4)) )

testName("dilate equality 2")
@test isequal( N(4), D(2//1,D(1//2,4)) )

testName("dilate equality 3")
@test isequal( D(3//2,S(1,2)), S(D(3//2,1),D(3//2,2)) )


end






