include("../Intcode.jl")
using .Intcode

const input = joinpath(@__DIR__, "input.txt")

let p = Program(input)
    setinput!(p, () -> 1)
    println("""--- Part One ---
               Diagnostic code at the end""")
    intcode!(p)
end
