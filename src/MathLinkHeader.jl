

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

