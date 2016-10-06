# Lesson 3:  Principles by Example


## Principles

*SirenSeq* is designed to be easily customised so each user can develope thier own scripting style.  For this reason, the package is designed to have few standard expressors defined.  The user should define thier own complex expressors using the standard ones.  There are non-standard expressors that can be included from the `SirenSeq.Extra` (*TODO: not yet uploaded*) submodule, but they are simply shortcuts and nothing they do can't be accomplished using the standard expressors which are all exported by the `SirenSeq` base module.

This tutorial presents some general principles for how to best construct expressions when restricted to the standard expressors.  Don't feel bound by this guide, it is simply meant as a good layout to start with.  Once non-standard expressors are introduced it will possible to streamline the scripting process/layout further (*TODO: future tutorial*).


## Top-Down vs. Bottom-Up

*SirenSeq* is meant to depart from traditional music notation and common midi editors by using a bottom-up approach to scripting.  If you think of writing sheet music, top level variables are written first and lower level details last.  First, the time signature is defined, then the instruments, then the instrument volumes, then the scale, then the first bar is written and then notes are added to it.  With *SirenSeq's* bottom-up approach much of this is reverse.  As an example, here is one way to do it *bottom-up*: first the notes are defined, then thier relations relative to nearby notes are defined, then the time duration of those notes are defined, then the instruments and thier volumes, and then the scales of different parts.  The next subsection gives a more concrete example.


## Delay Default Modification

Many attributes of atoms have default values.  For example: The default duration `dur` of any event is usually `1//1`, unless the atom type has not duration (as with control events).  The default offset `ofs` is `0//1`.  The default note velocity `vel` is `1.0`.  The default octave `ocv` is `3`.  The default scale is `Scales.cMaj`.  The default channel is `1`.

When defining expressions, delay modification of these defaults as long as possible.  First we will give an example of how not to do it.
```julia
sq1 = S(1,A(0.9,2),3,A(0.9,2))
sq1 = D(1//4,sq1)
sq1 = A(0.7,sq1)
sq1 = Cha(2,sq1)
sq1 = Sca(Scales.dMin,sq1)

sq2 = S(C(1,5),C(3,5))
sq2 = D(1//2,sq2)
sq2 = A(0.7,sq2)
sq2 = Cha(3,sq2)
sq2 = Sca(Scales.dMin,sq2)

part1 = R(8,C(sq1,sq2))
```
In this example, notes in `sq2` all have a velocity of `0.7` while odd-offset notes in `sq1` have velocity `0.7` and even ones have `0.7*0.9`.  If I want to re-use `sq1` and `sq2` in a different parts with a different velocity, I would have to remember that the defaults for both have been set to `0.7`.  It would be better to have written,
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
Now, if I have a lot of `sq`'s defined and want to use them in different parts with various modifications, I can more easily reason about them since they all have the default velocities, scales and channel.  With multiple parts defined, it could also be possible to move the `A` and `Sca` modifiers further out.

There is no single best way to apply this principle, but; retaining defaults and moving modifiers outwards generally leads to more re-useable expressions, less vebose definitions and makes reasoning about patterns easier.


## Assert Expression Durations

When combining expressions, it can become difficult to come up with names for each and to track their durations (especially when using unusual and irregular time signatures).  Use `@assert`s to double check expression durations in your scripts.  Here is an example,
```julia
# three variations on a melody of length 1//1
# assume that sq1,sq2,sq3,sq2b,sq3b and sq3c have already been defined
melA = S(sq1,sq2,sq1,sq3)
melB = S(sq1,sq2,sq1,sq3b)
melC = S(sq1,sq2b,sq1,sq3c)

@assert melA.dur == melB.dur == melC.dur == 1//1

# three expansions of the melody with length 4//1
partMelA = R(4,melA))
partMelB = S(melA,melB,melA,melB)
partMelC = S(melA,melB,melA,melC)

@assert partMelA.dur == partMelB.dur == partMelC.dur == 4//1

# different instruments parts for a verse of length 8//1
# assume that bq1,dq1 and dq2 have already been defined
verseMelA = S(partMelA,partMelA)
verseMelB = S(partMelB,partMelC)
verseBass = R(8,bq1)
verseDrums = R(4,S(dq1,dq2))

@assert verseMelA.dur == verseMelB.dur == verseBass.dur == verseDrums.dur == 8//1

# instruments combined to form the final verse
verse = C( Cha(1,verseBass), Cha(10,verseDrums), Cha(4,verseMelA), Cha(5,verseMelB) )
verse = A(0.7,verse)

# setup the instruments
Player(cha,inst,vol) = Cha(cha,Inst(inst,vol))

bassPlayer = Inst(1,GenMuseScoreSF144.iFingerBass),0.8)
drumPlayer = Inst(8,GenMuseScoreSF144.iRoomDrums),1.0)
melPlayer1 = Inst(4,GenMuseScoreSF144.iBrightPiano),0.9)
melPlayer2 = Inst(5,GenMuseScoreSF144.iHarpsichord),0.9)

band = C(bassPlayer,drumPlayer,melPlayer1,melPlayer2)

# render verse to .pdf file
renderMidi(S(band,verse))
```


Goto: [Previous Tutorial](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial2.md)



