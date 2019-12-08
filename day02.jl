# interface implementation makes a Program's memory appear 0-indexed
# i.e. Program(memory)[0] == memory[1]
mutable struct Program
    memory::Vector{Int}
    pc::Int
    Program(memory::Vector{Int}) = new(copy(memory), 0)
end
Base.first(p::Program) = first(p.memory)
Base.getindex(p::Program, i::Int) = p.memory[i + 1]
Base.setindex!(p::Program, v::Int, i::Int) = p.memory[i + 1] = v
Base.setindex!(p::Program, vs, inds) = (foreach(i->p[i] = vs[i], inds); vs)

abstract type AbstractInstruction end
Base.size(I::Type{<:AbstractInstruction}) = fieldcount(I)
Base.size(i::AbstractInstruction) = size(typeof(i))

execute!(::Program, ::AbstractInstruction) = nothing

run!(p::Program, i::AbstractInstruction) = (execute!(p, i); p.pc += size(i) + 1; p)

struct HaltInstruction <: AbstractInstruction end

struct MulInstruction <: AbstractInstruction
    a::Int
    b::Int
    c::Int
end
execute!(p::Program, mul::MulInstruction) = p[mul.c] = mul.a * mul.b

struct SumInstruction <: AbstractInstruction
    a::Int
    b::Int
    c::Int
end
execute!(p::Program, sum::SumInstruction) = p[sum.c] = sum.a + sum.b

itype(p::Program)  = itype(p[p.pc])
itype(opcode::Int) = itype(Val(opcode))

itype(::Val{ N}) where N = error("Unknown instruction: opcode=$N")
itype(::Val{ 1})         = SumInstruction
itype(::Val{ 2})         = MulInstruction
itype(::Val{99})         = HaltInstruction

Base.parse(I::Type{<:AbstractInstruction}, ::Program) = I()
Base.parse(I::Union{Type{MulInstruction},Type{SumInstruction}}, p::Program) =
    let a = p[p[p.pc + 1]],
        b = p[p[p.pc + 2]],
        c = p[p.pc + 3]
        I(a, b, c)
    end

intcode!(p::Program) =
    let i = parse(itype(p), p)
        run!(p, i)
        (i isa HaltInstruction ? first : intcode!)(p)
    end

prepare!(p::Program, noun, verb) = (p[1:2] = [noun, verb]; p)

const input = parse.(Int, split(read("day02.txt", String), ','))

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
