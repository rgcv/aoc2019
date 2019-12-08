const modules = parse.(Int, split(read("day01.txt", String)))

fuel(m) = m ÷ 3 - 2

println("""--- Part One ---
           Fuel requirements: $(map(fuel, modules) |> sum)""")
