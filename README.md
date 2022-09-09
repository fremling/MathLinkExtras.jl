# MathLinkExtras is Deprecated and all functionality has moved into [MathLink](https://github.com/JuliaInterop/MathLink.jl) v0.5.0 #

# MathLinkExtras
The package adds extra functionality on top of the [MathLink](https://github.com/JuliaInterop/MathLink.jl) package, allowing Julia to talk to Mathematica.
For [jupyter](https://jupyter.org/) notebooks, the text/latex MIME-type is implemented. 

## Usage MathLink
MathLinkExtras is desiged to implement the basic algebraic operation that one expects to excist such as +,-,*,/ and ^.

Just like the [MathLink](https://github.com/JuliaInterop/MathLink.jl) package, the main interface consists of the `W""` string macro for specifying symbols.

```julia
julia> using MathLink

julia> W"Sin"
W"Sin"

julia> sin1 = W"Sin"(1.0)
W"Sin"(1.0)

julia> sinx = W"Sin"(W"x")
W"Sin"(W"x")
```

To parse an expression in the Wolfram Language, you can use the `W` cmd macro (note the backticks):

```julia
julia> W`Sin[1]`
W"Sin"(1)
```

`weval` evaluates an expression:

```julia
julia> weval(sin1)
0.8414709848078965

julia> weval(sinx)
W"Sin"(W"x")

julia> weval(W"Integrate"(sinx, (W"x", 0, 1)))
W"Plus"(1, W"Times"(-1, W"Cos"(1)))
```


## Usage MathLinkExtras

By default MathLinkExtras only overloads the `+`, `-`, `*`, `/`  operations

```julia
julia> using MathLink

julia> using MathLinkExtras

julia> W"a"+W"b"
W"Plus"(W"a",W"b")

julia> W"a"+W"a"
W"Plus"(W"a",W"a")

julia> W"a"-W"a"
W"Plus"(W"a",W"Minus"(W"a"))
```

But one can toggle automatic use of `weval`  on and of using `set_GreedyEval(x::Bool)`

```julia
julia>set_GreedyEval(true)
julia> W"a"+W"b"
W"Plus"(W"a",W"b")

julia> W"a"+W"a"
W"Times"(2,W"a")

julia> W"a"-W"a"
0
```


## Fractions and Complex numbers
 
The package also contains extentions to handle fractions

```julia
julia> weval(1//2)
W"Rational"(1, 2)

julia> (4//5)*W"a"
W"Times"(W"Rational"(4, 5), W"a")

julia> W"a"/(4//5)
W"Times"(W"Rational"(5, 4), W"a")
```

and complex numbers

```julia
julia> im*W"a"
W"Times"(W"Complex"(0, 1), W"a")

julia> im*(im*W"c")
W"Times"(-1, W"c")
```

## W2Tex - Latex conversion

```julia
julia> W2Tex(W`(a+b)^(b+x)`)
"(a+b)^{b+x}"

julia> W2Tex(W`a`)
"a"

julia> W2Tex(W`ab`)
"\\text{ab}"

julia> W2Tex(W`ab*cd`)
"\\text{ab} \\text{cd}"

julia> W2Tex(weval(fill(W"a",2,3)))
"\\left(\n\\begin{array}{ccc}\n a & a & a \\\\\n a & a & a \\\\\n\\end{array}\n\\right)"
```

## W2Mstr - Mathematica conversion
Sometimes one wants to be able to read the Julia MathLink expressions back into Mathematica. For that purpose, `W2Mstr` is also supplied. This implementation is currently quite defensive with parentheses, which gives a more verbose output than necessary. Here are a few examples

```julia
julia> W2Mstr(W`x`)
"x"

julia> W2Mstr(W"Sin"(W"x"))
"Sin[x]"

julia> W2Mstr(weval(W`a + c + v`))
"(a + c + v)"

julia> W2Mstr(weval(W`a^(b+c)`))
"(a^(b + c))"

julia> W2Mstr(weval(W`e+a^(b+c)`))
"((a^(b + c)) + e)"

julia> W2Mstr(W"a"+W"c"+W"v"+W"Sin"(2 +W"x" + W"Cos"(W"q")))
"(a + c + v + Sin[(2 + x + Cos[q])])"

julia> W2Mstr(im*2)
"(2*I)"

julia> W2Mstr(weval(W"Complex"(W"c",W"b")))
"(c+b*I)"

julia> W2Mstr(W"c"+im*W"b")
"(((1*I)*b) + c)"

julia> W2Mstr(W`b/(c^(a+c))`)
"(b*((c^(a + c))^-1))"
```
