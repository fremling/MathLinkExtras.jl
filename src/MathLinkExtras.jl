module MathLinkExtras


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


include("Operators.jl")
include("MathLinkHeader.jl")

end # module
