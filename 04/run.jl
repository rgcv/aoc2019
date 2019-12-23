const range = UnitRange(parse.(Int, split("357253-892942", '-'))...)

diffs(a) = [a[i + 1] - a[i] for i in 1:length(a) - 1]

has_double(password::AbstractString) = any(iszero, diffs(password))
has_strict_double(password::AbstractString) =
    any(isequal(2), map(length, findall(r"(?:(\d)\1*)", password)))

criteria(password::Int) = criteria(string(password))
criteria(password::AbstractString) = criteria(has_double, password)

criteria(p::Function) = password -> criteria(p, password)
criteria(p::Function, password::Int) = criteria(p, string(password))
criteria(p::Function, password::AbstractString) =
    all([length(password) == 6, issorted(password), p(password)])

println("""--- Part One ---
           # of Different Passwords: $(count(criteria, range))""")
println("""--- Part Two ---
           # of Different Passwords: $(count(criteria(has_strict_double), range))""")
