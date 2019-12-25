module Intcode

export Program,
       setinput!, setoutput!,
       intcode!

mutable struct Program
    pc::Int
    memory::Vector{Int}
    fin::Function
    fout::Function

    Program(memory::Vector{Int}) = new(0, copy(memory), () -> 0, println)
end
Program(s::AbstractString) =
    Program(parse.(Int, split(isfile(s) ? read(s, String) : s, ',')))

setinput!(p::Program,  f::Function) = p.fin = f
setoutput!(p::Program, f::Function) = p.fout = f

# interface implementation makes a Program's memory appear 0-indexed
# i.e. Program(memory)[0] == memory[1]
Base.first(p::Program) = first(p.memory)
Base.getindex(p::Program, i::Int) = p.memory[i + 1]
Base.setindex!(p::Program, v::Int, i::Int) = p.memory[i + 1] = v
Base.setindex!(p::Program, vs, inds) = (foreach(i->p[i] = vs[i], inds); vs)

@enum Mode begin
    position = 0
    immediate
end

abstract type AbstractInstruction end
Base.size(i::AbstractInstruction) = size(typeof(i))
Base.size(I::Type{<:AbstractInstruction}) = fieldcount(I)
Base.propertynames(I::Type{<:AbstractInstruction}) =
    Tuple(Symbol('a' + c - 1) for c ∈ 1:fieldcount(I))

exec!(::Program, ::AbstractInstruction) = nothing
run!(p::Program, i::AbstractInstruction) = (exec!(p, i); p.pc += size(i) + 1; p)

const INSTRUCTIONS = IdDict{Int,Type{<:AbstractInstruction}}()
macro instruction(name::Symbol, opcode::Int, size::Int = 0, expr = nothing)
    1 ≤ opcode ≤ 99 || throw(DomainError(opcode, "must be ∈ [0,99]"))
    haskey(INSTRUCTIONS, opcode) &&
        error("opcode $opcode already assigned to $(INSTRUCTIONS[opcode])")

    local upper = 'z' - 'a' + 1
    0 ≤ size ≤ upper || throw(DomainError(size, "must be ∈ [0,$upper]"))

    local sname = esc(name)
    quote
        struct $sname <: AbstractInstruction
            $([:($(Symbol('a' + c - 1))::Int) for c in 1:size]...)
        end
        $(esc(:exec!))($(esc(:p))::Program, $(esc(:i))::$sname) = $expr
        $INSTRUCTIONS[$opcode] = $sname
    end
end

@instruction SumInstruction     1 3 p[i.c] = i.a + i.b
@instruction MulInstruction     2 3 p[i.c] = i.a * i.b
@instruction InputInstruction   3 1 p[i.a] = p.fin()
@instruction OutputInstruction  4 1 p.fout(p[i.a])

@instruction HaltInstruction   99

itype(p::Program)  = itype(p[p.pc] % 100)
itype(opcode::Int) =
    try
        INSTRUCTIONS[opcode]
    catch
        error("unknown opcode '$opcode'")
    end

Base.parse(p::Program, I::Type{<:AbstractInstruction}) =
    let s = size(I),
        ms = map(Mode, digits(p[p.pc] ÷ 100, pad = s))

        I(map(1:s, ms) do i, mode
              v = p[p.pc + i]
              i ≠ s && mode == position ? p[v] : v
        end...)
    end

intcode!(p::Program) =
    let i
        while !((i = parse(p, itype(p))) isa HaltInstruction)
            run!(p, i)
        end
        first(p)
    end

end # module Intcode
