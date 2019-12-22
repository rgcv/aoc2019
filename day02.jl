include("intcode.jl")

const input = parse.(Int, split(read("day02.txt", String), ','))

prepare!(p::Program, noun, verb) = (p[1:2] = [noun, verb]; p)
restore1202!(p::Program) = prepare!(p, 12, 2)
println("""--- Part One ---
           Result: $(intcode!(restore1202!(Program(input))))""")

println()

for noun in 0:99, verb in 0:99
    if intcode!(prepare!(Program(input), noun, verb)) == 19690720
        println("""--- Part Two ---
                   Result: $(100 * noun + verb)""")
        break
    end
end
