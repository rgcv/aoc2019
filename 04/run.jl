const range = UnitRange(parse.(Int, split("357253-892942", '-'))...)

diffs(c) = [c[i + 1] - c[i] for i in 1:length(c) - 1]

criteria(password::Int) = criteria(string(password))
criteria(password::AbstractString) =
    all([length(password) == 6,
         issorted(password),
         any(isequal(0), diffs(password))])

println("""--- Part One ---
           # of Different Passwords: $(count(criteria, range))""")
