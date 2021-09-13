using MathLink

if !@isdefined(TabLevel)
    TabLevel = ""
end
println(TabLevel*"Open MathLinkHeader.jl")
TabLevel=TabLevel*"    "

import Base.+
import Base.*
import Base.-
import Base./
import Base.//
import Base.^
import Base.zero
#### + ####

MLTypes=Union{MathLink.WExpr,MathLink.WSymbol}


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



function Wprint(WExpr)
    weval(W"Print"(WExpr))
    return
end


###Adda function that prints the form back to Mathematica Input-language

W2Mstr(x::Number) = "$x"
W2Mstr(x::Rational) = "($(x.num)/$(x.den))"
function W2Mstr(x::Array)
    Dim = length(size(x))
    Str="{"
    for j in 1:size(x)[1]
        if j>1
            Str*=","
        end
        if Dim == 1
            Str*=W2Mstr(x[j])
        elseif Dim == 2
            Str*=W2Mstr(x[j,:])
        else
            ###Arrays with larger dimension: $Dim != 1,2 not implemented yet
        end
    end
    Str*="}"
    return Str
end

W2Mstr(x::MathLink.WSymbol) = x.name
function W2Mstr(x::MathLink.WExpr)
    #println("W2Mstr::",x.head.name)
    if x.head.name == "Plus"
        Str = W2Mstr_PLUS(x.args)
    elseif x.head.name == "Times"
        Str = W2Mstr_TIMES(x.args)
    elseif x.head.name == "Power"
        Str = W2Mstr_POWER(x.args)
    elseif x.head.name == "Complex"
        Str = W2Mstr_COMPLEX(x.args)
    else
        Str=x.head.name*"["
        for j in 1:length(x.args)
            if j>1
                Str*=","
            end
            Str*=W2Mstr(x.args[j])
        end
        Str*="]"
    end
    return Str
end
            
function W2Mstr_PLUS(x::Union{Array,Tuple})
    #println("W2Mstr_PLUS:",x)
    Str="("
    for j in 1:length(x)
        if j>1
            Str*=" + "
        end
        Str*=W2Mstr(x[j])
    end
    Str*=")"
end
    
function W2Mstr_TIMES(x::Union{Array,Tuple})
    #println("W2Mstr_TIMES:",x)
    Str="("
    for j in 1:length(x)
        if j>1
            Str*="*"
        end
        Str*=W2Mstr(x[j])
    end
    Str*=")"
end
    
    
function W2Mstr_POWER(x::Union{Array,Tuple})
    #println("W2Mstr_POWER:",x)
    if length(x) != 2
        error("Power takes two arguments")
    end
    Str="("*W2Mstr(x[1])*"^"*W2Mstr(x[2])*")"
end


    
function W2Mstr_COMPLEX(x::Union{Tuple,Array})
    #println("W2Mstr_COMPLEX:",x)
    if length(x) != 2
        error("Complex takes two arguments")
    end
    if x[1] == 0
        ###Imaginary
        Str="("*W2Mstr(x[2])*"*I)"
    elseif x[2] == 0
        ### Real
        ###Complex
        Str=W2Mstr(x[1])
    else
        ###Complex
        Str="("*W2Mstr(x[1])*"+"*W2Mstr(x[2])*"*I)"
    end
end




###Added a function to put that handles rationals
import MathLink.put
MathLink.put(x::MathLink.Link,r::Rational)=MathLink.put(x,WRational(r))
###Perform a prime factorization to keep large numbers from overflowing to int128
MathLink.put(x::MathLink.Link,i128::Int128)=MathLink.put(x,WPrimeFac(i128))



using Primes
function WPrimeFac(n::Integer)
    ###Perform a prime factorization
    PrimFacs=factor(n)
    println("$n=:",PrimFacs)


    ###Do some checks that the factors are smaller than Int128
    ####Loop through the list and create the powers
    Factors = [ W"Power"(WInt64Reduce(x.first),x.second) for x in PrimFacs.pe]
    return prod(Factors)
end

function do_WInt64Reduce(n::Integer,iters::Integer)
    ErrText="The number $n bigger than what can be represented using Int64."
    MaxVal=typemax(Int64)
    if abs(n) > MaxVal
        TooLarge=exp(log(abs(n)) - log(MaxVal))
        if TooLarge > 50
            ErrText="The number $n is $TooLarge times bigger than what can be represented using Int64."
        end
        if n<0
            return do_WInt64Reduce(n+MaxVal,iters-1)
        else
            return do_WInt64Reduce(n-MaxVal,iters+1)
        end
    else
        if iters == 0
            return Int64(n)
        else
            return W"Plus"(Int64(n),W"Times"(iters,MaxVal))
        end
    end
end

WInt64Reduce(n::Integer) = do_WInt64Reduce(n,0)





WtoWolframStr(x::MathLink.WSymbol) = x.name
function WtoWolframStr(x::MathLink.WExpr)
    return "$x"
end




TabLevel=TabLevel[1:end-4]
println(TabLevel*"Close MathLinkHeader.jl")
