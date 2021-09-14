# MathLinkExtras
Package that adds extra functionality on top the of [MathLink](https://github.com/JuliaInterop/MathLink.jl) package, which allows Julia to talk to Mathematica.


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


##Fractions and Complex numbers
 
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


## W2Mstr
Sometimes one wants to be able to read the Julia MathLink expressions back into mathametica. For that purpouse `W2Mstr` is also supplied. This implementation is currently quite defensive with the usage of paranthesis, which gives a more verbose that nececarry result. Here are a few examples

```julia
julia> W2Mstr(W`x`)
"x"

julia> W2Mstr(W`Sin[x]`)
"Sin[x]"

julia> W2Mstr(weval(W`a + c + v`))
"(a + c + v)"

julia> W2Mstr(weval(W`a^(b+c)`))
"(a^(b + c))"

julia> W2Mstr(weval(W`e+a^(b+c)`))
"((a^(b + c)) + e)"

julia> W2Mstr(weval(W`a + c + v + Sin[2 + x + Cos[q]]`))
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
