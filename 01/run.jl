const modules = parse.(Int, split(read(joinpath(@__DIR__, "input.txt"), String)))

fuel(m) = m ÷ 3 - 2
requirements(f) = mapreduce(f, +, modules)

println("""--- Part One ---
           Fuel requirements: $(requirements(fuel))""")

println()

totalfuel(m) = m ≤ zero(m) ? -m :
               let f = fuel(m)
                   f + totalfuel(f)
               end

println("""--- Part Two ---
           Fuel requirements: $(requirements(totalfuel))""")
