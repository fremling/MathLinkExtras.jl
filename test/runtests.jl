
using Test
using MathLink
using MathLinkExtras


###The operations mentioned in the README
sin1 = W"Sin"(1.0)
@test sin1 == W"Sin"(1.0)

sinx = W"Sin"(W"x")
@test sinx == W"Sin"(W"x")
@test W`Sin[1]` == W"Sin"(1)

@test weval(sin1) == 0.8414709848078965

@test weval(sinx) == W"Sin"(W"x")

@test weval(W"Integrate"(sinx, (W"x", 0, 1))) == W"Plus"(1, W"Times"(-1, W"Cos"(1)))



###Testing turning on and turning of the greedy evaluation
###The default is "false"
@test W"a"+W"b" == W"Plus"(W"a",W"b")
@test W"a"+W"a" == W"Plus"(W"a",W"a")
@test W"a"-W"a" == W"Plus"(W"a",W"Minus"(W"a"))
set_GreedyEval(true)
@test W"a"+W"b" == W"Plus"(W"a",W"b")
@test W"a"+W"a" == W"Times"(2,W"a")
@test W"a"-W"a" == 0
set_GreedyEval(false)
@test W"b"+W"b" == W"Plus"(W"b",W"b")
set_GreedyEval(true)

#### Test Rationals parts
@test (4//5)*W"a" == weval(W`4 a/5`)
@test W"a"*(4//5) == weval(W`4 a/5`)
@test (4//5)/W"a" == weval(W`4/(a 5)`)
@test W"a"/(4//5) == weval(W`5 a/4`)


@test weval(1//2) == weval(W`1/2`)
@test weval([1//2,W`a`]) == W"List"(weval(W`1/2`),W`a`)

@test Wprint(1//2) == nothing

#### Test imaginary parts
@test im*W"a" == weval(W`I * a`)
@test (2*im)*W"a" == weval(W`2 I a`)
@test im/W"a" == weval(W`I / a`)
@test W"a"/(2* im) == weval(W`- I a/2`)
@test im*(im*W"c") == weval(W`-c`)

@test +W"b" == W"b"
@test +W`a+b` == W`a+b`

#####Testing that complex nubmers can be put in weval
@test weval(im+2) == weval(W`I+2`)
@test weval(im*2) == weval(W`I*2`)
@test weval(im) == weval(W`I`)


@test (3*im)*(2*im)*W"a" == weval(W`-6 a`)
@test (3*im) + (2*im)*W"a" == weval(W`3 I + 2 I a`)
@test (3*im) - (2*im)*W"a" == weval(W`3 I - 2 I a`)




###Test of a naive MathLink to Mathematica converter function (to resuts can be copied into mathematica directly"
@test W2Mstr(W`x`) == "x"
@test W2Mstr(W"Sin"(W"x")) == "Sin[x]"
@test W2Mstr(W`Sin[x]`) == "Sin[x]"
@test W2Mstr(weval(W`a + c + v`)) == "(a + c + v)"
@test W2Mstr(weval(W`a + c*b + v`)) == "(a + (b*c) + v)"
@test W2Mstr(weval(W`(a + c)*(b + v)`)) == "((a + c)*(b + v))"
@test W2Mstr(weval(W`a^(b+c)`)) == "(a^(b + c))"
@test W2Mstr(weval(W`a^2`)) == "(a^2)"
@test W2Mstr(weval(W`e+a^(b+c)`)) == "((a^(b + c)) + e)"
@test W2Mstr(weval(W`a + c + v + Sin[2 + x + Cos[q]]`)) == "(a + c + v + Sin[(2 + x + Cos[q])])"
@test W2Mstr(W"a"+W"c"+W"v"+W"Sin"(2 +W"x" + W"Cos"(W"q"))) == "(a + c + v + Sin[(2 + x + Cos[q])])"


@test W2Mstr(weval(W`2*I`)) == "(2*I)"
@test W2Mstr(weval(W`2/I`)) == "(-2*I)"
@test W2Mstr(W`2 + 0*I`) == "(2 + (0*I))"
@test W2Mstr(W"Complex"(W"c",0)) == "c"
@test W2Mstr(weval(W"Complex"(W"c",0))) == "c"
@test W2Mstr(weval(W"Complex"(W"c",W"b"))) == "(c+b*I)"

@test W2Mstr(W"a") == "a"
@test W2Mstr(W"x") == "x"
@test W2Mstr(W"x"+W"y") == "(x + y)"
@test W2Mstr(W`Sqrt[a + b]`) == "Sqrt[(a + b)]"
@test W2Mstr(W`Pow[x,2]`) == "Pow[x,2]"
@test W2Mstr(W`x^2`) == "(x^2)"
@test W2Mstr(W`a+b`) == "(a + b)"
@test W2Mstr(2) == "2"
@test W2Mstr(W`Sqrt[x+Sin[y]+z^(3/2)]`) == "Sqrt[(x + Sin[y] + (z^(3*(2^-1))))]"
@test W2Mstr(W`3/4`) == "(3*(4^-1))"
@test W2Mstr(3//4) == "(3/4)"
@test W2Mstr(W`b/c`) == "(b*(c^-1))"
@test W2Mstr(W`b/(c^(a+c))`) == "(b*((c^(a + c))^-1))"
@test W2Mstr(W`(b^2)/(c^3)`) == "((b^2)*((c^3)^-1))"
@test W2Mstr(weval(W`(b^2)/(c^3)`)) == "((b^2)*(c^-3))"

@test W2Mstr([W`x`,W`a`]) == "{x,a}"
@test W2Mstr([W`x`]) == "{x}"
@test W2Mstr([W`x` W`y`; W`z` W`x`]) == "{{x,y},{z,x}}"

@test W2Mstr(im) == "(1*I)"
@test W2Mstr(2*im) == "(2*I)"





P12 = [ 0 1 ; 1 0 ]
@test P12 * [W"a" W"b" ; W`a+b` 2] == [ W`a+b` 2 ; W"a" W"b"]
@test [W"a" W"b" ; W`a+b` 2] * P12  == [ W"b" W"a" ; 2 W`a+b`]

#### test larger matrix
@test P12 * [W"a" W"b" ; W`a+b` W`v+2`] == [ W`a+b` W`2+v` ; W"a" W"b"]
@test [W"a" W"b" ; W`a+b` W`v+2`] * P12  == [ W"b" W"a" ; W`2+v` W`a+b`]



#### test larger matrix
P13 = fill(0,(3,3))
P13[1,3]=1
P13[3,1]=1
P13[2,2]=1
Mat = fill(W`a+d`,3,3)
Mat[:,:] = [W`a+d` W`a+d` W`f*g`; W`a+b` W`v+2` W`f*g` ;  W`d+b`  W`a+b`  W`a+b`]
P13 * Mat * P13
#HM2 = P13*Mat*P13



###A real live eample
P14 = fill(0,(4,4))
P14[1,4]=1
P14[4,1]=1
P14[2,2]=1
P14[3,3]=1
Mat = MathLink.WExpr[W"Plus"(W"J1245", W"J1346", W"J2356") W"Plus"(W"Times"(W"Complex"(0, 1), W"J1356"), W"Times"(W"Complex"(0, -1), W"J2346")) W"Plus"(W"Times"(W"Complex"(0, -1), W"J1256"), W"Times"(W"Complex"(0, 1), W"J2345")) W"Plus"(W"J1246", W"Times"(-1, W"J1345")); W"Plus"(W"Times"(W"Complex"(0, -1), W"J1356"), W"Times"(W"Complex"(0, 1), W"J2346")) W"Plus"(W"J1245", W"Times"(-1, W"J1346"), W"Times"(-1, W"J2356")) W"Plus"(W"J1246", W"J1345") W"Plus"(W"Times"(W"Complex"(0, -1), W"J1256"), W"Times"(W"Complex"(0, -1), W"J2345")); W"Plus"(W"Times"(W"Complex"(0, 1), W"J1256"), W"Times"(W"Complex"(0, -1), W"J2345")) W"Plus"(W"J1246", W"J1345") W"Plus"(W"Times"(-1, W"J1245"), W"J1346", W"Times"(-1, W"J2356")) W"Plus"(W"Times"(W"Complex"(0, -1), W"J1356"), W"Times"(W"Complex"(0, -1), W"J2346")); W"Plus"(W"J1246", W"Times"(-1, W"J1345")) W"Plus"(W"Times"(W"Complex"(0, 1), W"J1256"), W"Times"(W"Complex"(0, 1), W"J2345")) W"Plus"(W"Times"(W"Complex"(0, 1), W"J1356"), W"Times"(W"Complex"(0, 1), W"J2346")) W"Plus"(W"Times"(-1, W"J1245"), W"Times"(-1, W"J1346"), W"J2356")]
####WE just want to see that the numbers can be computed
Mat * P14
P14 * Mat
P14 * Mat* P14




set_GreedyEval(false)

using Primes

###These tets try a workaround for then the integer is larger than int64.
A0=3^3 * 199 * 3797 * Int128(372928745438657)
A=7608224128671509719617
@test A0 == A
B=1216448257343019439234
AB = A+B
@test typeof(A) == Int128
@test typeof(B) == Int128
AB1=weval(W"Plus"(W"a", 7608224128671509719617))
AB2=weval(W"a"+A)
@test AB1 == AB2
###For numbers of this size there is a special WInteger used
@test weval(AB1 - W"a").value == "$A"
@test weval(AB1 - W"a"+B).value == "$AB"

@test WInt64Reduce(372928745) == 372928745
@test WInt64Reduce(-28745) == -28745

@test WInt64Reduce(10880297241027479779) == W"Plus"(1656925204172703972, W"Times"(1, 9223372036854775807))
@test WInt64Reduce(210880297241027479779) == W"Plus"(7966112430222412025, W"Times"(22, 9223372036854775807))