@enum Orientation begin
    up = 1
    left
    down
    right
end
Base.convert(::Type{Orientation}, c::Char) =
    let ds = map(uppercase ∘ first ∘ string, instances(Orientation)),
        i = findfirst(isequal(c), ds)
        isnothing(i) && error("invalid direction: $c")
        Orientation(i)
    end
Base.:-(o::Orientation) =
    o == up   ? down  :
    o == down ? up    :
    o == left ? right :
    #= right =# left

struct Step
    orientation::Orientation
    magnitude::Int
end
Base.convert(::Type{Step}, s::AbstractString) =
    let o = convert(Orientation, first(s)),
        m = parse(Int, s[2:end])
        Step(o, m)
    end
Base.:-(s::Step) = Step(-s.orientation, s.magnitude)

struct Point
    x::Int
    y::Int
end
const ORIGIN = Point(0, 0)
Base.getindex(p::Point, i::Int) = getfield(p, fieldname(typeof(p), i))
Base.show(io::IO, p::Point) = print(io, "($(p.x), $(p.y))")
Base.:+(p::Point) = p
Base.:+(p::Point, s::Step) =
    let o = s.orientation, m = s.magnitude
        o == up   ? Point(p.x, p.y + m) :
        o == down ? Point(p.x, p.y - m) :
        o == left ? Point(p.x - m, p.y) :
        #= right =# Point(p.x + m, p.y)
    end
Base.:-(p::Point, s::Step) = p + -s
Base.:-(p::Point) = Point(-p.x, -p.y)

struct Segment
    source::Point
    target::Point
end
intersection(s::Segment, t::Segment) =
    let x₁ = s.source.x, y₁ = s.source.y,
        x₂ = s.target.x, y₂ = s.target.y,
        x₃ = t.source.x, y₃ = t.source.y,
        x₄ = t.target.x, y₄ = t.target.y,
        Δx₂₁ = x₁ - x₂,  Δx₄₃ = x₃ - x₄,
        Δy₂₁ = y₁ - y₂,  Δy₄₃ = y₃ - y₄,
        denom = Δx₂₁*Δy₄₃ - Δy₂₁*Δx₄₃

        denom == 0 && return nothing
        let Δx₃₁ = x₁ - x₃, Δy₃₁ = y₁ - y₃,
            t = (Δx₃₁*Δy₄₃ - Δy₃₁*Δx₄₃)/denom,
            u = (Δy₂₁*Δx₃₁ - Δx₂₁*Δy₃₁)/denom

            0 ≤ t ≤ 1 && 0 ≤ u ≤ 1 ?
            Point(floor(x₁ - t*Δx₂₁), floor(y₁ - t*Δy₂₁)) : nothing
        end
    end

convert_path(path, prev = ORIGIN) =
    if isempty(path)
        Point[]
    else
        next = prev + convert(Step, first(path))
        vcat(prev, convert_path(path[2:end], next))
    end

const paths = convert_path.(split.(split(read("input.txt", String)), ','))

manhattan(x₁::Int, y₁::Int, x₂::Int, y₂::Int) = abs(x₂ - x₁) + abs(y₂ - y₁)
manhattan(p::Point, q::Point) = manhattan(p.x, p.y, q.x, q.y)

closest() =
    let p = ORIGIN
        for i ∈ 1:length(paths[1]) - 1, j ∈ 1:length(paths[2]) - 1
            let (p₁, q₁) = paths[1][i:i + 1],
                (p₂, q₂) = paths[2][j:j + 1],
                (s₁, s₂) = Segment.((p₁, p₂), (q₁, q₂)),
                t = intersection(s₁, s₂)

                !isnothing(t) && t ≠ ORIGIN || continue
                if p == ORIGIN || manhattan(ORIGIN, t) ≤ manhattan(ORIGIN, p)
                    p = t
                end
            end
        end
        p
    end

println("""--- Part One ---
           Closest distance: $(manhattan(ORIGIN, closest()))""")
