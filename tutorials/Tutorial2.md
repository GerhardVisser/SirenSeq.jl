# Lesson 2


## Expressions

In *SirenSeq* you compose audio by defining audio expressions.  The top audio expressions type is,
```julia
abstract Exp
```
All implementations of `Exp` are immutable so you cannot alter them once created.  Atomic audio expressions are those that cannot be broken down into simpler expressions.  All atomic expressions belong to the type,
```julia
abstract Atom <: Exp
```
Atoms may correspond to multiple midi messages, they are atomic in that as expressions in the siren language they are atomic.  The way that a atom is turned into midi is only determined when the midi is finally written; not during definition of expressions.

The most common atom is `Note <: Atom`.  You should not construct a `Note` object directly and it is not exported.  Instead, a note can be constructed using `N`.  Type `?N` into the julia terminal to see a description.  You should see the type `IR` mentioned.  `IR` is used to in all function arguments which specify time intervals or time ratios.  For example `1::IR` is a whole-note length while `1//3::IR` is a third-note length.  The definition is simply
```julia
IR = Union{Int,Rational{Int}}
```
If you run `N(7)` you should see,
```
Note:   ch1,   ofs = 0 + 0//1,   dur = 1//1,   itv =  7,  ocv = 3,  vel = 1.00,  sca = SirenSeq.Scales.cMaj
```
The meaning of these values was described in the previous lesson (*Tutorial1.md*).  Try running `N(-1,5//3)`, `N(4,0.7)` and `N(4,1//3,0.7)` to see how the produced notes are affected.

Compound expressions can be made by combining atomic expressions.  If you run,
```julia
x = C(N(1),N(5),N(8))
renderMidi(x)
```
and open *temp.pdf* you should see that `x` is a chord made up of 3 notes.  `C` takes a list of expressions (atomic or complex) as argument. For functions which take expressions as arguments a special type called `Expi` is defined,
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
should return type `SirenSeq.Chord`.  This `Chord` type is the only non-atomic implementation of `Exp`.  *SirenSeq* sees all compositions of events simply as elaborate chords.  Lets look at how this applies to the sequence from the lesson (*Tutorial1.md*).  Run,
```julia
sq1 = S(1,2,3,2)
```
Note this is short for `S(N(1),N(2),N(3),N(2))` as `S` also takes a list of type `Expi` as argument.  The composer `S` simply replaces each note with a copy of itself with the offset (`ofs`) increased by the time at which the previous note ends, and then chords them together as is `C` does.

The functions `S` and `C` can take any audio expressions as arguments. For example,
```julia
sq2 = S(x,x,x,x)
```
will repeat the chord `x` 4 times.  This can also be accomplished with,
```julia
sq2 = R(4,x)
```

## Modifiers

TODO
