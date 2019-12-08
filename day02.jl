abstract type AbstractInstruction end

struct HaltInstruction <: AbstractInstruction end
struct NopInstruction <: AbstractInstruction end

mutable struct MulInstruction <: AbstractInstruction
    a::Int
    b::Int
    o::Int
    MulInstruction() = new()
end

mutable struct SumInstruction <: AbstractInstruction
    a::Int
    b::Int
    o::Int
    SumInstruction() = new()
end

size(::AbstractInstruction) = 1
execute!(program, ::AbstractInstruction) = nothing

size(::MulInstruction) = 4
execute!(program, mul::MulInstruction) = program[mul.o] = mul.a * mul.b

size(::SumInstruction) = 4
execute!(program, sum::SumInstruction) = program[sum.o] = sum.a + sum.b

instruction(opcode::Int)            = instruction(Val(opcode))
instruction(opcode::Val{N}) where N = NopInstruction()

instruction(opcode::Val{ 1}) = SumInstruction()
instruction(opcode::Val{ 2}) = MulInstruction()
instruction(opcode::Val{99}) = HaltInstruction()

parse!(program, ip, ::AbstractInstruction) = nothing
function parse!(program, ip, i::Union{MulInstruction,SumInstruction})
    i.a = program[program[ip + 1] + 1]
    i.b = program[program[ip + 2] + 1]
    i.o = program[ip + 3] + 1
end

intcode!(program, ip = 1) =
    let i = instruction(program[ip])
        parse!(program, ip, i)
        execute!(program, i)
        i isa HaltInstruction ? first(program) : intcode!(program, ip + size(i))
    end

prepare!(program, noun, verb) = (program[2:3] = [noun, verb]; program)
restore1202!(program) = prepare!(program, 12, 2)

const input = parse.(Int, split(read("day02.txt", String), ','))

println("""--- Part One ---
           Result: $(intcode!(restore1202!(copy(input))))""")

println()

for noun in 0:99, verb in 0:99
    if intcode!(prepare!(copy(input), noun, verb)) == 19690720
        println("""--- Part Two ---
                   Result: $(100 * noun + verb)""")
        break
    end
end
