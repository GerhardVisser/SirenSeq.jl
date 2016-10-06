# Lesson 2:  Audio Expressions


## Audio Expressions

In *SirenSeq*, you compose audio by defining **audio expressions**.  There are two types of audio expressions, **complex** and **atomic**.  **Atomic audio expressions** are those that cannot be broken down into simpler expressions.  All atomic expressions belong to the type,
```julia
abstract Atom
```
Atoms may correspond to multiple midi messages (or to recorded audio in future versions), they are atomic in that, as expressions in the siren language, they cannot be broken down into smaller events.  The way that an atom is turned into midi is only determined when the midi file is finally written; not during definition of expressions.

As before, start by importing the needed modules,
```julia
using SirenSeq, SirenSeq.Play, SirenSeq.Render
```
The most common midi atom is `Note <: Atom`.  You should not construct a `Note` object directly and the type is not exported by the `SirenSeq` module.  Instead, a note can be constructed using `N`.  Type `?N` into the julia terminal to see a description.  If you run `N(7)` you should see,
```
Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
The meaning of these displayed values was described in the previous lesson ([Tutorial1](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial1.md#creating-a-note-sequence)).

There is only one **complex audio expression** type,
```julia
immutable Exp
	dur::Rational{Int}	# duration
	as::Vector{Atom}	# order not important, atoms contain thier own offset values
end
```
`dur` is the duration in whole-note lengths of the expression.  `as` is a list of the atoms that make up the expression.  Do not attempt to alter the elements of `as` directly.  Expressions are meant to be handeled as immutable by the user.



## Composers

Complex expressions can be made by combining atomic expressions using **composers**.

The first composer we will look at is the **chord** `C` composer.  If you run,
```julia
x = C(N(1),N(5),N(8))
renderMidi(x)
```
and open *temp.pdf* you should see that `x` is a chord made up of 3 notes.  `C` takes a list of expressions (atomic or complex) as argument.  If one of `C`'s arguments is not an `Atom` or `Exp` it will try to convert it using `Base.convert`.  Arguments of type `Int` will automatically be converted to notes.  For example, `5` will be turned into `N(5)`; thus, our chord could be written more concisely as,
```julia
x = C(1,5,8)
```


Next we will look at the **sequence** `S` composer (first seen in lesson [Tutorial1](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial1.md#creating-a-note-sequence)).  Run,
```julia
sq1 = S(1,2,3,2)
```
Note, this is short for `S(N(1),N(2),N(3),N(2))` as `S` also automatically converts its arguments to expressions.  The composer `S` simply replaces each note with a copy of itself with the offset (`ofs`) increased by the time at which the previous note ends, and then "chords" them together as `C` does.  It also sets the total duration of the produced complex expression to the sum of the argument durations.

The functions `S` and `C` can also take complex audio expressions as arguments. For example,
```julia
sq2 = S(x,x,x,x)
```
will repeat the chord `x` (constructed earlier in this tutorial) 4 times.  This can also be accomplished using the **repeat** `R` composer,
```julia
sq2 = R(4,x)
```


## Modifiers

So far we have seen how to construct atoms using `N` and how to compose them using `C`, `S` and `R`; now we will look at some basic operations that can be used to modify them.  The **accelerate** modifier `A` can be used to modify the velocity of notes.  If you run,
```julia
A(0.5,sq1)
```
you should see,
```
Exp:    dur = 4//1
  Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  1,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  1 + 0//1,  dur = 1//1,   itv =  2,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  2 + 0//1,  dur = 1//1,   itv =  3,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  3 + 0//1,  dur = 1//1,   itv =  2,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
```
The velocities `vel` of all notes have been multiplied by 0.5.  The modifier `A` did not change `sq1`, it returned a modified copy of it.  None of the exported *SirenSeq* functions that take audio expressions (`Atom` or `Exp`) as arguments will modify those arguments.

If you run,
```julia
A(0.5,A(4.0,7))
```
you should see,
```
Note:   ch1,   ofs =  0 + 0//1,  dur = 1//1,   itv =  7,  ocv = 3,  vel = 2.00,  sca = SirenSeq.Scales.cMaj
```
`A` knows that its second argument should be an audio expression so it converts `7` to `N(7)`.  Most exported *SirenSeq* functions that take audio expressions (`Atom` or `Exp`) as arguments will have this property; using the `Base.convert` function to convert to `Atom` or `Exp`.  The inner `A` changes `vel` to `4.0`  while the outer `A` changes the `4.0` to `2.0`.  If you play or render this note, the velocity value `2.0` will be clipped to `1.0` just before going into the midi file.


To change the duration of a note (or any atom with a non-zero duration), the **dilate** modifier `D` can be used.  Running,
```julia
D(1//2,7)
```
should produce,
```
Note:   ch1,   ofs =  0 + 0//1,  dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
Notice that this is the note `N(7)` with its duration multiplied by `1//2` to produce a half-note.  All time durations and time multipliers in *SirenSeq* should be specified as `Int`s or as rationals of type `Rational{Int}`, never as floating points.  If you run `?D` the following description should come up,
```
D(v::IR, z)

Dilate z; multiplies all atom durations and offsets by v.
```
Notice that the multiplier argument `v` is of type `IR`.  The exported functions of *SirenSeq* which take time intervals or time ratios as argument all use type `IR`.  The definition is simply,
```julia
IR = Union{Int,Rational{Int}}
```
Now run,
```julia
D(1//4,sq1)
```
and you should see,
```
Exp:    dur = 1//1
  Note:   ch1,   ofs =  0 + 0//1,  dur = 1//4,   itv =  1,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  0 + 1//4,  dur = 1//4,   itv =  2,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  0 + 1//2,  dur = 1//4,   itv =  3,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  0 + 3//4,  dur = 1//4,   itv =  2,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
The modified sequence takes up 1 note length instead of 4.  Notice that the offsets `ofs` were also multiplied by `1//4`.  The dilate `D` modifier multiplies both atom offsets and durations by its argument.  While all `Atom`s have an offset, some will not have a duration (e.g. midi control signals).


Next is the **shift** `F` operation.  Shift moves the offsets of all atoms forward by its argument duration.  The command,
```julia
z = F(1//2,D(1//2,7))
```
should produce,
```
Note:   ch1,   ofs =  0 + 1//2,  dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
This note waits for `1//2` note lengths and then plays for a duration of `1//2`.  If `z` is repeated 4 times using,
```julia
R(4,z)
```
it will produce,
```
Exp:    dur = 2//1
  Note:   ch1,   ofs =  0 + 1//2,  dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  1 + 0//1,  dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  1 + 1//2,  dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs =  2 + 0//1,  dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
Use the `renderMidi` command to see what `R(4)` looks like.  Notice here that the first note begins playing one half-note duration after the start of the experssion while the last note ends one half half-note duration after the expression ends (`dur = 2//1`).  This behaviour may seem odd at first but using shift `F` to create small offsets can be usefull (*to be discussed in a future tutorial TODO*).


The next modifier is **translate** `T`; it changes the interval value of all notes.  The expression `T(-4,N(1))` is therefore equivalent to `N(-3)` since 1-4 = -3.  The first argument of `T` is always an integer.  Run the following code in the julia terminal,
```julia
x = D(1//4,S(1,2,3,4)) ;
y = S(x,T(3,x),T(-1,x),T(0,x)) ;
renderMidi(y)
```
and look at the *temp.pdf* file in the working directory too see the result.  Notice that all translations remain on the *C-Major* scale.  This is because each note `Atom` has its own scale variable.  To change the scale of an expression, use the **scale** modifier `Sca`.  Now run,
```julia
using SirenSeq.Scales
z = Sca(dMin,y) ;
renderMidi(z)
```
The new sequence `z` is in *D-Minor* with `N(1)` corresponding to middle D.  Notice that there are no \# symbols in the new *temp.pdf* file; *musescore* has automatically figured out what key to render `z` in (unless you have an older version installed).  There are many scales defined in the *SirenSeq.Scales* submodule.  If you use `Scales.noScale`, all interval values will be treated as raw midi pitch values; which is useful for percussion instruments.  For percussion instruments you will not want to use the `T` modifier.  It is possible to define your own scales, provided they contain between 1 and 11 notes (*to be discussed in a future tutorial TODO*).


Next we are going to use the **octave** modifier `V`.  By default all notes are constructed in octave 3.  The default value can be changed by running `setDefaultOctave`.  Now run,
```julia
z2 = V(2,z) ;
renderMidi(C(z,z2))
```
The new sequence `z2` starts with `N(1)` on octave 2.  The `C(z,z2)` creates an expression where `z` and `z2` are played together on the same channel starting at the same time.


The **channel** `Cha` modifier changes the channel that an `Atom` is played on.  You can play the two sequences on separate channels using,
```julia
z3 = Cha(2,z2) ;
renderMidi(C(z,z3))
```
Now `z` is on the default channel 1 while `z3` is on channel 2.



## Control Atoms

So far, the only `Atom` shown was `Note`.  Now we will look at some atoms corresponding to the most frequently used midi control messages.


To select a different instrument, use the `Prog` constructor.  The harpsichord program number for the *general musescore soundfont* is 6.  Now run,
```julia
z4 = S(Cha(2,Prog(6)),z3)
```
You should see the sequence described starting with,
```
Chord:
  Program-Select:  ch2,   ofs =  0 + 0//1,  prog = 6
		.
		.
		.
```
The `Cha(2,` modifier had to be applied to `Prog(2)` otherwise it would be channel 1 that has its program changed.  `z3` already knows that it belongs to channel 2.  Run,
```julia
renderMidi(C(z,z4))
```
and see that musescore has the instrument correctly labeled as *harpsichord* in *temp.pdf* (may vary depending on musescore version).  If you are using a soundfont file with program 6 as the harpsichord you should hear it when running,
```julia
playMidi(C(z,z4))
```


A bank select midi event can be created using `Bank(n)` where `n` is the desired bank number.  To select program 8 on bank 120 for channel 2 you could use,
```julia
Cha(2,S(Bank(120),Prog(8)))
```


To change the volume of a channel use `Vol`, for example,
```julia
S(Prog(6),Vol(0.8))
```
will select the harpsichord (assuming the synthesizer is already on bank 0) on channel 1 and set its volume to 0.8.


There are more control `Atom`s which will be covered in tutorial (*TODO*).



## Blanks

A **blank** is an expression similar to a *rest* in musical notation.  Blanks are used to to create buffers between notes.  To make a blank, use the `B` constructor.  Here is an example,
```julia
B(1//2)
```
which should produce,
```
Exp:    dur = 1//2
```
This expression simply has a duration.  Using `B()` will produce a blank of duration `1//1`.

Imagine that you want to repeat the sequence `sq3 = D(1//4,S(1,2,3))` four times but with a quarter-note rest at the end of each repetition.  Using `R(4,sq3)` or `S(sq3,sq3,sq3,sq3)` will produce a sequence of duration `4*3//4` with no rests in between.  You can use a blank to create a buffer at the end of the sequence.  Now run,
```julia
sq3 = D(1//4,S(1,2,3))
sq4 = D(1//4,S(1,2,3,B()))
```
The field `dur` records duration of an expression.  The following inequalities should hold true,
```julia
sq3.dur == 3//4
sq4.dur == 1//1
R(4,sq3).dur == 3//1
R(4,sq4).dur == 4//1
```

Blanks do not silence notes that are played at the same time.  The commands `S(1,2,3,B())` and `C(S(1,2,3),B(4))` should produce the same result.



## Terminology

Music is scripted in *SirenSeq* using **audio expressions**.  Expressions that cannot be decomposed into smaller expressions are called *atoms*.  Non-atomic expressions are called **complex expressions** and all complex expressions are of the type `Exp`.  Blanks are also of type `Exp` even though they may be thought of as atomic.  Expressions are created using three types of functions, **constructors**,  **modifiers** and **composers**.  Together these will be referred to as **expressors**.


### Constructors

Constructors are those functions that return an expression without taking any expressions as input.  Examples include,

 - `N`, a note
 - `B`, a blank
 - `Prog`, program-select
 - `Bank`, bank-select
 - `Vol`, set-volume

These five all belong to a single channel (1 by default) but there are others like midi system messages which do not.  These examples are all **atomic constructors** because they all return a single atom (except `B`).  Constructors which return complex expressions (containing more than one atom or a blank) are called **complex constructors**.  Some standard complex constructors will be presented in (*TODO: future tutorial*) but it is intended that the user relies more on defining their own shortcuts.


### Modifiers

Modifiers take an expression as input and return some modified version of it.  Examples include,

 - `A`, accelerate: multiply all note velocities by a argument
 - `D`, dilate: multiply all atom durations and offsets by argument
 - `F`, shift: increase all atom offsets by argument
 - `T`, translate: move all note intervals up their scale by argument
 - `V`, octave: set all note octave values to argument

These are all examples of **basic-modifiers**, modifiers which are applied directly to all atoms.  If `M1` is a basic-modifier then the following will be true,
```julia
M1(args,C(x1,x2,...,xN)) == C(M1(args,x1),M1(args,x2),...,M1(args,xN))
M1(args,S(x1,x2,...,xN)) == S(M1(args,x1),M1(args,x2),...,M1(args,xN))
```
where `args` represents the non-expression arguments of `M1` while `x1` through to `xN` can be any expressions.  Modifiers for which these equalities do not hold are called **complex-modifiers** and are discussed in (*TODO: future tutorial*).


### Composers

Composers take multiple expressions as arguments and combines them is some way.  Examples include,

 - `C`, chord: play argument expressions at the same time
 - `S`, sequence: play argument expressions in sequence
 - `R`, repeat: repeat argument expressions a specified number of times


### Expressor Naming Convention

The convention in Julia is that functions be lower-case while types are upper-case.  For expressors, *SirenSeq* breaks this convention by making all "expressors" upper-case.  The reason is that expressors are meant to be used to script music and so must be short (preferably between 1 and 3 characters long, depending on how often they will be used).  Expressions must be easy to read and write compactly.  Since lower-case single letter symbols tend to be used by programmers for short-term variable names, using them for expressors would lead to too much confusion.


Goto: [Previous Tutorial](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial1.md),  [Next Tutorial](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial3.md)



