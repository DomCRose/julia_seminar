##################################
### Automatic differentiation
##################################

# Reverse mode differentiation, good for function with few outputs and many inputs
using Zygote

f(x) = 3x^2 + 2x
df(x) = gradient(f, x)[1]

x = 2.0
f(x)
df(x)

# We can look at precisely what code was produced by the compiler
@code_warntype f(x) # original function
@code_warntype df(x) # differentiated function

# Second order. May take a while as Zygote struggles with this and produces poor code.
# However, it is correct, if slow.
ddf(x) = gradient(df, x)[1]
ddf(x)
@code_warntype ddf(x) # Not very optimal, lots of Anys

# Forward mode differentiation, good for function with many outputs and few inputs
using ForwardDiff

fdf(x) = ForwardDiff.derivative(f, x)
fdf(x)
@code_warntype fdf(x)

# Second order. For technical reasons ForwardDiff is better at differentiating itself.
fdfdf(x) = ForwardDiff.derivative(fdf, x)
fdfdf(x)
@code_warntype fdfdf(x)

# Can even use ForwardDiff to differentiate the df derivative function produced by Zygote,
# despite ForwardDiff having no knowledge of Zygotes existence
fddf(x) = ForwardDiff.derivative(df, x)
fddf(x)
@code_warntype fddf(x)









##################################
### Neural networks
##################################
using Lux, NNlib, Random
# Lux: package for outlining and running the forward pass of neural network models
# NNlib: package containing primitive neural network operations, e.g. activations

model = Chain(
    Dense(2 => 16, relu),
    Dense(16 => 32, relu),
    Dense(32 => 4),
    softmax
)

p, st = Lux.setup(Random.default_rng(), model)
x = rand(2)
out = model(x, p, st)

using Zygote

f(x) = 3x^2 + 2x
∇f(x) = gradient(f, x)[1]

loss(x, p) = sum(model(x, p, st)[1])
∇loss(x, p) = gradient(loss, x, p)
