const input = parse.(Int, split(read("day02.txt", String), ','))

op(opcode) = get([+, *], opcode, (xs...) -> nothing)
process!(program, opcode, a, b, pos) =
    let result = op(opcode)(a, b)
        if !isnothing(result)
            program[pos] = result
        end
        program
    end
intcode!(program, pos = 1) = pos > length(program) ? first(program) :
    let opcode = program[pos]
        opcode == 99 && return first(program)
        a, b = map(p->program[p + 1], program[pos + 1:pos + 2])
        newpos = program[pos + 3] + 1
        process!(program, opcode, a, b, newpos)
        return intcode!(program, pos + 4)
    end

restore1202!(program) = (program[2:3] = [12, 2]; program)

println("""--- Part One ---
           Result: $(intcode!(restore1202!(copy(input))))""")
