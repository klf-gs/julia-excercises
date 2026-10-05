using BenchmarkTools
using Statistics
using LinearAlgebra
using Random

function parse_line(line)
    sym, px, vol = split(line, ',')
    sym = String(sym) # copy from SubString
    px = parse(Float64, px)
    vol = parse(Int, vol)
    (sym, px, vol)
end

for line in eachline(IOBuffer(join(["a,1,2", "b,2,4", "c,3,5"], "\n")))
    @info parse_line(line)
end

abstract type CSVProcessor end

struct CSVArray <: CSVProcessor
    ret :: Vector{Tuple{String, Float64, Int}}
end
CSVArray() = CSVArray(Tuple{String, Float64, Int}[])
process!(p::CSVArray, row) = push!(p.ret, row)

struct VolAggregate <: CSVProcessor
    ret :: Dict{String, Int}
end
VolAggregate() = VolAggregate(Dict{String, Int}())
process!(p::VolAggregate, (sym, _, vol)) = p.ret[sym] = vol + get(p.ret, sym, 0)

function parse_csv(io::IO, p :: CSVProcessor = CSVArray())
    for line in eachline(io)
        process!(p, parse_line(line))
    end
    p.ret
end
parse_csv(
    path::AbstractString,
    p::CSVProcessor = CSVArray()
) = open(io -> parse_csv(io, p), path)

parse_csv("5-input.csv")

parse_csv("5-input.csv", VolAggregate())

fold_csv(io::IO) = foldl(
    eachline(io);
    init = Dict{String, Int}()) do d, line
        (sym, _, vol) = parse_line(line)
        d[sym] = vol + get(d, sym, 0)
        # i presume this just hands back a reference to the dict, not a copy
        d
    end
   
fold_csv(path::AbstractString) = open(fold_csv, path)

fold_csv("5-input.csv")

@assert parse_csv("5-input.csv", VolAggregate()) == fold_csv("5-input.csv")
