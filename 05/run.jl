include("../Intcode.jl")
using .Intcode

const input = joinpath(@__DIR__, "input.txt")

let p = Program(input)
    setinput!(p, () -> 1)
    @show intcode!(p)
end
