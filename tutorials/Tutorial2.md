# Lesson 2: Audio Expressions


## Expressions

In *SirenSeq* you compose audio by defining **audio expressions**.  The top audio expressions type is,
```julia
abstract Exp
```
All implementations of `Exp` are immutable so you cannot alter them once created.  **Atomic audio expressions** are those that cannot be broken down into simpler expressions.  All atomic expressions belong to the type,
```julia
abstract Atom <: Exp
```
Atoms may correspond to multiple midi messages (or to recorded audio in future versions), they are atomic in that, as expressions in the siren language, they cannot be broken down further.  The way that an atom is turned into midi is only determined when the midi file is finally written; not during definition of expressions.

The most common midi atom is `Note <: Atom`.  You should not construct a `Note` object directly and the type is not exported by the *SirenSeq* module.  Instead, a note can be constructed using `N`.  Type `?N` into the julia terminal to see a description.  You should see the type `IR` mentioned.  `IR` is used in all function arguments which specify time intervals or time ratios.  For example `1::IR` is a whole-note length while `1//3::IR` is a third-note length.  The definition is simply,
```julia
IR = Union{Int,Rational{Int}}
```
If you run `N(7)` you should see,
```
Note:   ch1,   ofs = 0 + 0//1,   dur = 1//1,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
The meaning of these values was described in the previous lesson ([Tutorial1](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial1.md)).  Try running `N(-1,5//3)`, `N(4,0.7)` and `N(4,1//3,0.7)` to see how the produced notes descriptions are affected.

Compound expressions can be made by combining atomic expressions using the **chord** `C` composer.  If you run,
```julia
x = C(N(1),N(5),N(8))
renderMidi(x)
```
and open *temp.pdf* you should see that `x` is a chord made up of 3 notes.  `C` takes a list of expressions (atomic or complex) as argument. For functions which take expressions as arguments, a special type called `Expi` is defined,
```julia
Expi = Union{Int,Exp}
```
`C` takes a list of type `Expi` as argument.  If it encounters an `Int` it will turn it into a `Note`.  For example, `5` will be turned into `N(5)`; thus, our chord could be written more concisely as,
```julia
x = C(1,5,8)
```
Running,
```julia
typeof(x)
```
should return type `SirenSeq.Chord`.  This `Chord` type is the only non-atomic implementation of `Exp`.  *SirenSeq* sees all compositions of events simply as elaborate chords.  Lets look at how this applies to the **sequence** `S` cpmposer seen in lesson (([Tutorial1](https://github.com/GerhardVisser/SirenSeq.jl/blob/master/tutorials/Tutorial1.md)).  Run,
```julia
sq1 = S(1,2,3,2)
```
Note this is short for `S(N(1),N(2),N(3),N(2))` as `S` also takes a list of type `Expi` as argument.  The composer `S` simply replaces each note with a copy of itself with the offset (`ofs`) increased by the time at which the previous note ends, and then "chords" them together as `C` does.

The functions `S` and `C` can take any audio expressions as arguments. For example,
```julia
sq2 = S(x,x,x,x)
```
will repeat the chord `x` (which you constructed earlier in this tutorial) 4 times.  This can also be accomplished with,
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
Chord:
  Note:   ch1,   ofs = 0 + 0//1,   dur = 1//1,   itv =  1,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 1 + 0//1,   dur = 1//1,   itv =  2,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 2 + 0//1,   dur = 1//1,   itv =  3,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 3 + 0//1,   dur = 1//1,   itv =  4,  ocv = 3,  vel = 0.50,  sca = SirenSeq.Scales.cMaj
```
The velocities `vel` of all notes have been multiplied by 0.5.  Since all audio expressions in *Siren* are immutable, the modifier `A` did not change `sq1`, it returned a modified copy of it.  If you run,
```julia
A(0.5,A(4.0,7))
```
you should see,
```
Note:   ch1,   ofs = 0 + 0//1,   dur = 1//1,   itv =  3,  ocv = 3,  vel = 2.00,  sca = SirenSeq.Scales.cMaj
```
`A` knows that its second argument should be an `Exp` so it converts `7` to `N(7)`.  The inner `A` changes `vel` to `4.0`  while the outer `A` changes the `4.0` to `2.0`.  If you play or render this note, the velocity value `2.0` will be clipped to `1.0` just before going into the midi file.

To change the duration of a note (or any atom with a non-zero duration), the **dilate** modifier `D` can be used.  Running,
```julia
D(1//2,7)
```
should produce,
```
Note:   ch1,   ofs = 0 + 0//1,   dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
Notice that this is the note `N(7)` with its duration multiplied by `1//2` to produce a half-note.  All time durations and time multipliers in *SirenSeq* should be specified as `Int`s or as rationals of type `Rational{Int}`, never as floating points.  Now run,
```julia
D(1//4,sq1)
```
and you should see,
```
Chord:
  Note:   ch1,   ofs = 0 + 0//1,   dur = 1//4,   itv =  1,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 0 + 1//4,   dur = 1//4,   itv =  2,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 0 + 1//2,   dur = 1//4,   itv =  3,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 0 + 3//4,   dur = 1//4,   itv =  4,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
The modified sequence takes up 1 note length instead of 4.  Notice that the offsets `ofs` were also multiplied by `1//4`.  The dilate `D`modifier multiplies both atom offsets and durations by its argument.  While all `Atom`s have an offset, some will not have a duration (e.g. midi control signals).

Next is the **shift** `F` operation.  Shift moves the offsets of all atoms forward by its argument duration.  The command,
```julia
z = F(1//2,D(1//2,7))
```
should produce,
```
Note:   ch1,   ofs = 0 + 1//2,   dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
This note waits for `1//2` note lengths and then plays for a duration of `1//2`.  If `z` is repeated 4 times using,
```julia
R(4,z)
```
it will produce,
```
Chord:
  Note:   ch1,   ofs = 0 + 1//2,   dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 1 + 1//2,   dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 2 + 1//2,   dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
  Note:   ch1,   ofs = 3 + 1//2,   dur = 1//2,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
Use the `renderMidi` command to see what `R(4)` looks like.

The next modifier is **translate** `T`; it changes the interval value of all notes.  The expression `T(-4,N(1))` is therefore equivalent to `N(-3)` since 1-4 = 3.  The first argument of `T` is always an integer.  Run the following code in the julia terminal,
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
The new sequence `z` is in *D-Minor* with `N(1)` corresponding to middle D.  Notice there are no \# symbols in the new *temp.pdf* file; *musescore* has automatically figured out what key to render `z` in (unless you have an older version installed).  There are many scales defined in the *SirenSeq.Scales* submodule.  If you use `Scales.noScale` all interval values will be treated as raw midi pitch values; which is useful for percussion instruments.  For percussion instruments you will not want to use the `T` modifier.  It is possible to define your own scales provided they contain between 1 and 11 notes (*to be discussed in a future tutorial*).

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

So far, the only `Atom` shown was `Note`.  Now we will look at some atoms corresponding to the most frequently used midi control messages.  To select a different instrument, use the `Prog` constructor.  The harpsichord program number for the *general musescore soundfont* is 6.  Now run,
```julia
z4 = S(Cha(2,Prog(6)),z3)
```
You should see the sequence described starting with,
```
Chord:
  Program-Select:  ch2,   ofs = 0 + 0//1,   prog = 6
		.
		.
		.
```
The `Cha(2,` modifier had to be applied to `Prog(2)` otherwise it would be channel 1 that has its program changed.  `z3` already knows that it belongs to channel 2.  Run,
```julia
renderMidi(C(z,z4))
```
and see that musescore has the instrument correctly labeled as *harpsichord* in *temp.pdf*.  If you are using a soundfont file with program 6 as the harpsichord you should hear it when running,
```julia
playMidi(C(z,z4))
```
A bank select midi event can be created using `Bank(n)` where `n` is the desired bank number.  So to select program 8 on bank 120 for channel 2 you could use,
```julia
Cha(2,S(Bank(120),Prog(8)))
```
To change the volume of a channel use `Vol`, for example,
```julia
S(Prog(6),Vol(0.8))
```
will select the harpsichord (assuming the synthesizer is already on bank 0) on channel 1 and set its volume to 0.8.

There are more control `Atom`s which will be covered in tutorial (*not yet decided*).
