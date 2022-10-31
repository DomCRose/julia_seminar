# This code is used to generate the multiple dispatch example in the fourth slide of the
# presentation.

function f(x, y)
    return x + 2y
end

f(1, 2) # first call of f on two integers, causes compilation of a specialization
# check for compiled specializations with two arguments
specs = which(f, (Any, Any)).specializations # get specializations for 2 argument calls
filter(!isnothing, [spec for spec in specs]) # clean up output: currently only 1

f(1.0, 2.0) # first call of f on two floats, causes compliation of another specialization
specs = which(f, (Any, Any)).specializations 
filter(!isnothing, [spec for spec in specs]) # now we find 2 compiled specializations

f(1, 2.0)
specs = which(f, (Any, Any)).specializations 
filter(!isnothing, [spec for spec in specs]) # 3 specializations

f(
    [1 2
     3 4],
    [5.0 6.0
     7.0 8.0]
)
specs = which(f, (Any, Any)).specializations 
filter(!isnothing, [spec for spec in specs]) # 4 specializations

# Can also use multiple dispatch to define specific methods for specific argument types
function f(x::Array, y::Array)
    return x .+ 2 .* y
end

# rerun matrix call from above: since there now exists a new, more specific method which
# applies to this set of types, the specialization is recompiled and replaced
f(
    [1 2
        3 4],
    [5.0 6.0
        7.0 8.0]
)
# still 4 specializations, but the compiled code of one has changed
specs = which(f, (Any, Any)).specializations 
filter(!isnothing, [spec for spec in specs])
