using BenchmarkTools
using Statistics
using LinearAlgebra
using Random
using JET

function mys(x::Vector{Float64})
    s = zero(eltype(x))
    for el in x
        s += el
    end
    s
end

@code_warntype mys(rand(100))

function un(x)
    if x
        return 0
    end
    return 0.0
end


function f(x)
    if x
        x
    else
        un(x)
    end
end


@code_warntype un(false)

@code_warntype un(true)

@code_warntype f(false)

@code_warntype f(true)

g(x) = x

@code_warntype g(true)


JET.@report_opt un(false)

JET.@report_opt mys(rand(10))

a(x) = first(x) + 1

JET.@report_opt a(Any[1])

JET.@report_opt a([1])

JET.@report_opt a(Float64[1])
