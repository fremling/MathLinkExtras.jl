
export Wprint, W2Mstr, W2Tex
export HasGraphicsHead, HasRecursiveGraphicsHead

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



#### Code to produce LaTex strings
W2Tex(x::MLTypes) = weval(W`ToString@TeXForm[#]&`(x))

#### Allow latex string to be shown when supported. Relevant for the jupyter notebook.

HasRecursiveGraphicsHead(w::MathLink.WSymbol) = false

function HasRecursiveGraphicsHead(w::MathLink.WExpr)
    if HasGraphicsHead(w)
        return true
    end
    for arg in w.args
        if typeof(arg) == MathLink.WExpr
            ##Only check for MathLink Expressions
            if HasRecursiveGraphicsHead(arg)
                return true
            end
        end
    end
    return false
end

HasGraphicsHead(w::MathLink.WSymbol) = false
        
function HasGraphicsHead(w::MathLink.WExpr)
    HeadString = w.head.name
    GraphicsHeadsList = ["Graphics","GeoGraphics"]
    ###Check for names not based on ending on Plot or Plot3D
    if HeadString in GraphicsHeadsList
        return  true
    end

    ###Check if name ends with Plot or Plot3D
    ##Check the number of characters is long enough for Plot
    if length(HeadString) >= 4  
        if HeadString[end-3:end] == "Plot"
            return true
        end
    end
    ##Check the number of characters is long enough for Plot3D
    if length(HeadString) >= 6
        if HeadString[end-5:end] == "Plot3D"
            return true
        end
    end
    return false
end

import Base.show
Base.show(io,::MIME"text/latex",x::MathLink.WSymbol) = print(io,"\$"*W2Tex(x)*"\$")

import Base.Multimedia.showable
function Base.Multimedia.showable(::MIME"text/latex", w::MathLink.WExpr)
    if HasRecursiveGraphicsHead(w)
        return false
    else
        return true
    end
end
function Base.show(io,::MIME"text/latex",x::MathLink.WExpr)
    print(io,"\$"*W2Tex(x)*"\$")
end

#Base.show(io,::MIME"text/latex",x::MLTypes) = print(io,"\$"*W2Tex(x)*"\$")



