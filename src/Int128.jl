
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

