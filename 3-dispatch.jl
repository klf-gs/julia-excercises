using BenchmarkTools
using Statistics
using LinearAlgebra
using Random
using Supposition

abstract type Instrument end

struct Equity{T<:Real} <: Instrument
    px::T
    qty::Int
end
struct Option{T<:Real} <: Instrument
    px::T
    qty::Int
end
struct Future{T<:Real} <: Instrument
    px::T
    qty::Int
    scale::Int
end
struct Spread{A<:Instrument, B<:Instrument} <: Instrument
    a::A
    b::B
end

notional(x::Future) = x.scale * x.qty * x.px
notional(x::Instrument) = x.qty * x.px
notional(s::Spread) = notional(s.a) + notional(s.b)

Base.show(io::IO, x::Future) = print(io, "Future(px=$(x.px), qty=$(x.qty), scale=$(x.scale))")
Base.show(io::IO, x::Spread) = print(io, "Spread(a=$(x.a), b=$(x.b)")
Base.show(io::IO, x::Instrument) = print(io, "$(nameof(typeof(x)))(px=$(x.px), qty=$(x.qty))")

# tests

notional(Future(1.0, 3.0, 2))
notional(Equity(1.0, 3.0))
notional(Option(1.0, 3.0))

Future(1.0, 3.0, 2)

a = Future(1.0, 3.0, 2)
b = Equity(1.0, 3.0)

@assert notional(a) + notional(b) == notional(Spread(a,b))

Spread(a,b)
