include("../Intcode.jl")
using .Intcode

const input = joinpath(@__DIR__, "input.txt")

prepare!(p::Program, noun, verb) = (p[1:2] = [noun, verb]; p)
restore1202!(p::Program) = prepare!(p, 12, 2)
println("""--- Part One ---
           Result: $(intcode!(restore1202!(Program(input))))""")

println()

for noun ∈ 0:99, verb ∈ 0:99
    if intcode!(prepare!(Program(input), noun, verb)) == 19690720
        println("""--- Part Two ---
                   Result: $(100 * noun + verb)""")
        break
    end
end
