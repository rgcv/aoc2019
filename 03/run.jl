struct Point
    x::Int
    y::Int
end
const ORIGIN = Point(0, 0)

struct Vec
    x::Int
    y::Int
end
Base.abs(v::Vec) = v.x == 0 ? abs(v.y) :
                   v.y == 0 ? abs(v.x) :
                   Int(√(v.x^2 + v.y^2))
Base.convert(::Type{Vec}, s::AbstractString) =
    let d = first(s), l = parse(Int, s[2:end])
        d ∈ "RULD" || error("invalid direction: $d")
        let v = d == 'R' ? Vec( 1,  0) :
                d == 'U' ? Vec( 0,  1) :
                d == 'L' ? Vec(-1,  0) :
                #= 'D' =#  Vec( 0, -1)
            l*v
        end
    end
Base.:-(p::Point, q::Point) = Vec(p.x - q.x, p.y - q.y)
Base.:+(p::Point, v::Vec) = Point(p.x + v.x, p.y + v.y)

const Loc = Union{Point,Vec}
Base.show(io::IO, p::Loc) = print(io, (p.x, p.y))
Base.:(==)(p::Loc, q::Loc) = (p.x, p.y) == (q.x, q.y)
Base.:*(s::Int, p::Loc) = typeof(p)(s*p.x, s*p.y)

intersection(p₁::Point, q₁::Point, p₂::Point, q₂::Point) =
    (p₁, q₁) == (p₂, q₂) ? nothing : # we're interested in a point
    let x₁ = p₁.x, y₁ = p₁.y,
        x₂ = q₁.x, y₂ = q₁.y,
        x₃ = p₂.x, y₃ = p₂.y,
        x₄ = q₂.x, y₄ = q₂.y

        if x₁ == x₂ # s vertical
            y₁, y₂ = minmax(y₁, y₂)
            x₃, x₄ = minmax(x₃, x₄)
            if x₃ ≤ x₁ ≤ x₄ && y₁ ≤ y₃ ≤ y₂ Point(x₁, y₃) end
        elseif x₃ == x₄ # t vertical
            x₁, x₂ = minmax(x₁, x₂)
            y₃, y₄ = minmax(y₃, y₄)
            if x₁ ≤ x₃ ≤ x₂ && y₃ ≤ y₁ ≤ y₄ Point(x₃, y₁) end
        end
    end

steps2path(path, prev = ORIGIN) =
    isempty(path) ? [prev] :
    let next = prev + convert(Vec, first(path))
        vcat(prev, steps2path(path[2:end], next))
    end

const paths = steps2path.(split.(split(read(joinpath(@__DIR__, "input.txt"), String)), ','))

manhattan(x₁::Int, y₁::Int, x₂::Int, y₂::Int) = abs(x₂ - x₁) + abs(y₂ - y₁)
manhattan(p::Point, q::Point) = manhattan(p.x, p.y, q.x, q.y)

wires() =
    let distance = Inf, steps = Inf, sᵢ = 0, sⱼ = 0
        for i ∈ 1:length(paths[1]) - 1
            pᵢ, qᵢ = paths[1][i:i + 1]
            sᵢ += abs(qᵢ - pᵢ)

            for j ∈ 1:length(paths[2]) - 1
                i == j == 1 && continue
                pⱼ, qⱼ = paths[2][j:j + 1]
                sⱼ += abs(qⱼ - pⱼ)

                pᵢⱼ = intersection(pᵢ, qᵢ, pⱼ, qⱼ)
                if !isnothing(pᵢⱼ)
                    d = manhattan(ORIGIN, pᵢⱼ)
                    if d < distance distance = d end

                    sum = sᵢ - abs(qᵢ - pᵢⱼ) + sⱼ - abs(qⱼ - pᵢⱼ)
                    if sum < steps steps = sum end
                end
            end
            sⱼ = 0
        end
        distance, steps
    end

let (distance, steps) = wires()
    println("""--- Part One ---
               Closest distance: $(distance)""")
    println("""--- Part Two ---
               Fewest combined step: $(steps)""")
end
