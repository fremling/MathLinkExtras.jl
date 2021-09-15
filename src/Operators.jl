
import Base.+
import Base.*
import Base.-
import Base./
import Base.//
import Base.^
import Base.zero
#### + ####


####If the flag for greedy evaluation does not exist
## create it and set it to false.
if !@isdefined(MLGreedyEval)
    MLGreedyEval=false
end

function MLeval(x::MLTypes)
    #println("MLGreedyEval=$MLGreedyEval")
    if MLGreedyEval
        return weval(x)
    else
        return x
    end
end

export set_GreedyEval

function set_GreedyEval(x::Bool)
    global MLGreedyEval
    MLGreedyEval=x
end


###A special case of weval on rationals that was not handled
zero(x::MLTypes)=0

+(a::MLTypes)=MLeval(a)
+(a::MLTypes,b::MLTypes)=MLeval(W"Plus"(a,b))
+(a::MLTypes,b::Number)=MLeval(W"Plus"(a,b))
+(a::Number,b::MLTypes)=MLeval(W"Plus"(a,b))
+(a::MLTypes,b::Complex)=a+WComplex(b)
+(a::Complex,b::MLTypes)=WComplex(a)+b
#### - ####
-(a::MLTypes)=MLeval(W"Minus"(a))
-(a::MLTypes,b::MLTypes)=MLeval(W"Plus"(a,W"Minus"(b)))
-(a::MLTypes,b::Number)=MLeval(W"Plus"(a,W"Minus"(b)))
-(a::Number,b::MLTypes)=MLeval(W"Plus"(a,W"Minus"(b)))
-(a::MLTypes,b::Complex)=a-WComplex(b)
-(a::Complex,b::MLTypes)=WComplex(a)-b


#### * ####
*(a::MLTypes,b::MLTypes)=MLeval(W"Times"(a,b))
*(a::MLTypes,b::Number)=MLeval(W"Times"(a,b))
*(a::Number,b::MLTypes)=MLeval(W"Times"(a,b))
*(a::MLTypes,b::Rational)=a*WRational(b)
*(a::Rational,b::MLTypes)=WRational(a)*b
*(a::MLTypes,b::Complex)=a*WComplex(b)
*(a::Complex,b::MLTypes)=WComplex(a)*b


#### // ####
//(a::MLTypes,b::MLTypes)=MLeval(W"Times"(a, W"Power"(b, -1)))
//(a::MLTypes,b::Number)=MLeval(W"Times"(a, W"Power"(b, -1)))
//(a::Number,b::MLTypes)=MLeval(W"Times"(a, W"Power"(b, -1)))
//(a::MLTypes,b::Rational)=a//WRational(b)
//(a::Rational,b::MLTypes,)=WRational(a)//b
//(a::MLTypes,b::Complex)=a//WComplex(b)
//(a::Complex,b::MLTypes,)=WComplex(a)//b
                               

#### / ####
/(a::MLTypes,b::MLTypes)=a//b
/(a::MLTypes,b::Number)=a//b
/(a::Number,b::MLTypes)=a//b


#### ^ ####
^(a::MLTypes,b::MLTypes)=MLeval(W"Power"(a,b))
^(a::MLTypes,b::Number)=MLeval(W"Power"(a,b))
^(a::Number,b::MLTypes)=MLeval(W"Power"(a,b))

WRational(x::Rational) = W"Times"(x.num, W"Power"(x.den, -1))
WComplex(x::Complex) = W"Complex"(x.re,x.im)
function WComplex(x::Complex{Bool})
    if x.re
        re = 1
    else
        re = 0
    end
    if x.im
        im = 1
    else
        im = 0
    end
    return W"Complex"(re,im)
end

###Added a function to put that handles rationals
import MathLink.put
MathLink.put(x::MathLink.Link,r::Rational)=MathLink.put(x,WRational(r))
MathLink.put(x::MathLink.Link,z::Complex)=MathLink.put(x,WComplex(z))


###Morf Int128 into BigInt to plug a hole where int128 was not implemented in MathLink.
MathLink.put(x::MathLink.Link,i128::Int128)=MathLink.put(x,big(i128))

