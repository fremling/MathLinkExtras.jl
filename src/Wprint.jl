
export Wprint, W2Mstr, WInt64Reduce

function Wprint(WExpr)
    weval(W"Print"(WExpr))
    return
end


###Adda function that prints the form back to Mathematica Input-language

W2Mstr(x::Number) = "$x"
W2Mstr(z::Complex) = W2Mstr(WComplex(z))
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

