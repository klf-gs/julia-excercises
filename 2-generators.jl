using BenchmarkTools
using Statistics
using LinearAlgebra
using Random

nrows = 10^6

# keep these const to avoid lookups and allocation
const vols = rand(1:256, nrows)
const fvols = Float64.(vols)
const prices = rand(nrows) .+ 1

const Ticks = Vector{Tuple{Float64, Int}}

const tcks :: Ticks = collect(zip(prices, vols))

function vwap(tt::Ticks)
    pxv = sum(p * v for (p, v) in tt)
    vol = sum(v for (_, v) in tt)
    pxv / vol
end

function vwap_fast(vv, pp)
    dot(pp, vv) / sum(vv)
end

# Does not allocate at all
@btime vwap(tcks)

# use $-notation to avoid allocation (although shouldn't be needed with const)
@btime vwap_fast($vols, $prices)

@btime vwap_fast($fvols, $prices)



function above_vwap(tt::Ticks)
    vw = vwap(tt)
    count( first(t) > vw for t in tt)
end

function above_vwap_idio(tt::Ticks)
    vw = vwap(tt)
    count(((p, _),) -> p > vw, tt)
end

@btime above_vwap(tcks)

@btime above_vwap_idio(tcks)

function vwap_simd(vv, pp)
    s = 0.0
    @inbounds @simd for i in eachindex(pp, vv)
        s += pp[i] * vv[i]
    end
    s / sum(vv)
end

# same as BLAS with a single thread
@btime vwap_simd($fvols, $prices)

# slightly slower than single-threaded blas
@btime vwap_simd($vols, $prices)
