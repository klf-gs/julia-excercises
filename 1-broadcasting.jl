using BenchmarkTools
using Statistics
using LinearAlgebra
using Random
using Supposition

prices = rand(10^6) .+ 1

function simple_return(pp)
    # could also have used `similar`
    r = Vector{Float64}(undef, length(pp) - 1)
    for i in 1:(length(pp)-1)
        push!(r, (pp[i+1] - pp[i]) / pp[i])
    end
    r
end

simple_return_dot(pp) = (pp[2:end] .- pp[1:end-1]) ./ pp[1:end-1]

simple_return_fused(pp) = @views @. (pp[2:end] - pp[1:end-1]) / pp[1:end-1]

simple_return_fast(pp) = @views @. (pp[2:end] / pp[1:end-1]) - 1

simple_return_fast2(pp) = @views @. pp[2:end] / pp[1:end-1] - 1


@btime simple_return_fast($prices) ;
@btime simple_return_fast2($prices) ;
@btime simple_return_fused($prices) ;
@btime simple_return($prices) ;

@btime simple_return_dot(prices)
@btime simple_return_fused(prices)

@btime simple_return(prices)

all(simple_return(prices) .== simple_return_dot(prices))
all(simple_return_fused(prices) .== simple_return_dot(prices))

function log_return(pp)
    r = Float64[]
    for i in 1:(length(pp)-1)
        push!(r, log(pp[i+1]/pp[i]))
    end
    r
end

log_return_dot(pp) = log.(pp[2:end] ./ pp[1:end-1])
log_return_fused(pp) = @. log(pp[2:end] / pp[1:end-1])

@time log_return(prices)
@time log_return_dot(prices)
@time log_return_fused(prices)

all(log_return(prices) .== log_return_dot(prices))
all(log_return_fused(prices) .== log_return_dot(prices))

zscore(x, pp) = (x - mean(pp)) / std(pp)

@assert zscore(2, prices) > 0
@assert zscore(1, prices) < 0

@btime zscore(1, prices);

# nice idea, but floats are just too easy to prove counterexamples from
# floatgen = Supposition.Data.Floats{Float64}()
#
# @check function simp(a=floatgen, b=floatgen)
#     ab = [a,b]
#     simple_return(ab) == simple_return_dot(ab)
# end
