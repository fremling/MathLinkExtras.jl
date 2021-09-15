module MathLinkExtras


using MathLink

MLTypes=Union{MathLink.WExpr,MathLink.WSymbol}


include("Operators.jl")
include("Wprint.jl")

end # module
