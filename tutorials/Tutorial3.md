# Lesson 3:  Principles by Example


## Principles

*SirenSeq* is designed to be easily customised so each user can develope thier own scripting style.  For this reason the package is designed to have few expressors defined and very few complex expressors; the user should define thier own.  There still some general principles for how to best construct expressions that are presented in this tutorial.


## Delay Default Modification

Many attributes of atoms have default values.  For example: The default duration `dur` of any event is usually `1//1` unless they atom type has not duration (as with control events).  The default offset `ofs` is `0//1`.  The default note velocity `vel` is `1.0`.  The default octave `ocv` is 3.  The default scale is `Scales.cMaj`.  The default channel is 1.

When defining expressions, delay modification of these defaults as long as possible.  First we will give an example of how not to do it.
```julia
sq1 = S(1,A(0.9,2),3,A(0.9,2))
sq1 = D(1//4,sq1)
sq1 = A(0.7,sq1))
sq1 = Cha(2,sq1)
sq1 = Sca(Scales.dMin,sq1)

sq2 = S(C(1,5),C(3,5))
sq2 = D(1//2,sq2)
sq2 = A(0.7,sq2)
sq2 = Cha(3,sq2)
sq2 = Sca(Scales.dMin,sq2)

part1 = R(8,C(sq1,sq2))
```
In this example notes in `sq2` all have a velocity of `0.7` while odd-offset notes in `sq1` have velocity `0.7` while the even ones are `0.7*0.9`.  If I what to re-use `sq1` ans `sq2` in a different parts with a different velocity, I would have to remember that the defaults for both have been set to `0.7`.  It would be better to have written,
```julia
sq1 = S(1,A(0.9,2),3,A(0.9,2))
sq1 = D(1//4,sq1)
sq1 = Cha(2,sq1)
sq1 = Sca(Scales.dMin,sq1)

sq2 = S(C(1,5),C(3,5))
sq2 = D(1//2,sq2)
sq2 = Cha(3,sq2)
sq2 = Sca(Scales.dMin,sq2)

part1 = R(8,C(sq1,sq2))
part1 = A(0.7,part1)
```
Similarly, the channel and scale modifiers can be moved outwards.
```julia
sq1 = S(1,A(0.9,2),3,A(0.9,2))
sq1 = D(1//4,sq1)

sq2 = S(C(1,5),C(3,5))
sq2 = D(1//2,sq2)

part1 = C(Cha(2,sq1),Cha(3,sq2))
part1 = R(8,part1)
part1 = A(0.7,part1)
part1 = Sca(Scales.dMin,part1)
```
Now, if I have a lot of `sq*`s defined and want to use them in different parts with various modifications, I can easily reason about them and since they all have the same default velocities, scales and channel.  With multiple parts defined, it could also be possible to move the `A` and `Sca` modifiers further out.

There is no exact best way to apply this principle, but; retaining defaults and moving modifiers outwards generally leads to more easily re-useable expressions.


## Assert Expression Lengths

When combining expressions, it can become difficult to come up with names for each and to track their durations.  Use the `len` command to double-check and place `@assert`s in your scripts.  Here is an example,
```julia
# three variations on a melody of length 1//1
# assume that sq1,sq2,sq3,sq2b,sq3b and sq3c have already been defined
melA = S(sq1,sq2,sq1,sq3)
melB = S(sq1,sq2,sq1,sq3b)
melC = S(sq1,sq2b,sq1,sq3c)

@assert len(melA) == len(melB) == len(melC) == 1//1

# three expansions of the melody with length 4//1
partMelA = R(4,melA))
partMelB = S(melA,melB,melA,melB)
partMelC = S(melA,melB,melA,melC)

@assert len(partMelA) == len(partMelB) == len(partMelC) == 4//1

# different instruments parts for a verse of length 8//1
# assume that bq1,dq1 and dq2 have already been defined
verseMelA = S(partMelA,partMelA)
verseMelB = S(partMelB,partMelC)
verseBass = R(8,bq1)
verseDrums = R(4,S(dq1,dq2))

@assert len(verseMelA) == len(verseMelB) == len(verseBass) == len(verseDrums) == 8//1

# instruments combined to form the final verse
# notice that the drums are made louder while the bass is made less loud
verse = C( Cha(1,verseBass), A(1.1,Cha(10,verseDrums)), Cha(4,verseMelA), A(0.8,Cha(6,verseMelB)) )
verse = A(0.7,verse)
```
