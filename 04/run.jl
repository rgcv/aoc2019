const range = UnitRange(parse.(Int, split("357253-892942", '-'))...)

diffs(a) = [a[i + 1] - a[i] for i in 1:length(a) - 1]

criteria(password::Int) = criteria(string(password))
criteria(password::AbstractString) =
    all([length(password) == 6,
         issorted(password),
         any(isequal(0), diffs(password))])

println("""--- Part One ---
           # of Different Passwords: $(count(criteria, range))""")
