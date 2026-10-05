using BenchmarkTools
using Statistics
using LinearAlgebra
using Random
using Supposition

struct RollingWindow{T, V<:AbstractVector{T}}
    v::V
    n::Int
    function RollingWindow(v::V, n::Int) where {T, V<:AbstractVector{T}}
        1 < n < length(v) || throw(ArgumentError("need 1 <= n <= length(v)"))
        new{T, V}(v, n)
    end
end

Base.length(w::RollingWindow) = length(w.v) - w.n + 1

# Allocates
#Base.iterate(w::RollingWindow, idx=1) = idx > length(w) ? nothing : ( w.v[idx:idx + w.n - 1], idx + 1)
# Does not allocate
Base.iterate(w::RollingWindow, idx=1) = idx > length(w) ? nothing : ( view(w.v, idx:idx + w.n - 1), idx + 1)

# Forces julia to infer the type from the elements of the iterator
# Without this, you get boxed Anys
Base.IteratorEltype(::Type{<:RollingWindow}) = Base.EltypeUnknown()

# test

data = rand(10)

w = RollingWindow(data, 3)

@assert length(w) == 8 

@assert eltype(collect(w)) != Any

try
    RollingWindow(data, 0)
    throw(BoundsError()) # anything that isn't ArgumentError
catch e
    @assert e isa ArgumentError
end

try
    RollingWindow(data, 100)
    throw(BoundsError()) # anything that isn't ArgumentError
catch e
    @assert e isa ArgumentError
end

function sum_of_means(w)
    r = 0.0
    for x in w
        r += mean(x)
    end
    r
end


data2 = rand(10^5)

const w2 = RollingWindow(data2, 3)

@btime sum_of_means($w2)
