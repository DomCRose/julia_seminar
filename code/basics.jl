# This line may take a minute to run as GLMakie loads and compiles
# A figure will be produced using random data when this file is loaded, to force
# compilation of some plotting functions. This can be closed / ignored.
include("plotting.jl")































##################################
### Comparison with python: basic loop
##################################

function random_walk(initial_state, steps)
    states = zeros(typeof(initial_state), steps + 1)
    states[1] = initial_state
    for i in 1:steps
        step = rand((-1, 1))
        states[i+1] = states[i] + step
    end
    return states
end

initial_state = 0
steps = 100
@time states = random_walk(initial_state, steps)

using BenchmarkTools

@btime random_walk($initial_state, $steps)

plot_trajectory(states)

pause # This is here for the code demo to prevent the cursor jumping to the next section




















##################################
### Comparison with Python: vectorized
##################################

function random_walk_vectorize(initial_state, steps)
    randomness = rand((-1, 1), steps + 1)
    randomness[1] += initial_state
    return cumsum(randomness)
end

initial_state = 0
steps = 100
@btime random_walk($initial_state, $steps)
@btime random_walk_vectorize($initial_state, $steps)
steps = 10000
@btime random_walk($initial_state, $steps)
@btime random_walk_vectorize($initial_state, $steps)

pause # This is here for the code demo to prevent the cursor jumping to the next section















##################################
### Abstraction: Types and dispatch
##################################

struct RandomWalkDynamics end

function generate_update(state, dynamics::RandomWalkDynamics)
    return rand((-1, 1))
end

### Single line function definitions ###
f(x) = 2x^2 + 3
f(2)

generate_update(state, dynamics::RandomWalkDynamics) = rand((-1, 1))

function trajectory(initial_state, dynamics, steps)
    states = zeros(typeof(initial_state), steps + 1)
    states[1] = initial_state
    for i in 2:(steps+1)
        step = generate_update(states[i-1], dynamics)
        states[i] = states[i-1] + step
    end
    return states
end

dynamics = RandomWalkDynamics()
initial_state = 0
steps = 100
@time trajectory(initial_state, dynamics, steps)
@btime trajectory($initial_state, $dynamics, $steps)

states = trajectory(initial_state, dynamics, steps)
plot_trajectory(states)

pause # This is here for the code demo to prevent the cursor jumping to the next section









##################################
### Utilizing abstraction: more dynamics types
##################################

struct BrownianDynamics
    time_step::Float64
    noise::Float64
end

methods(generate_update)

function generate_update(state, dynamics::BrownianDynamics)
    return sqrt(dynamics.time_step * dynamics.noise) * randn()
end

methods(generate_update)

brownian = BrownianDynamics(0.1, 2.0)
initial_state = 0.0
steps = 100
@time trajectory(initial_state, brownian, steps)
@btime trajectory($initial_state, $brownian, $steps)

states = trajectory(initial_state, brownian, steps)
plot_trajectory(states)

pause # This is here for the code demo to prevent the cursor jumping to the next section











##################################
### Constructors and optimization
##################################

struct BrownianDynamics2
    time_step::Float64
    noise::Float64
    A::Float64
end

methods(BrownianDynamics2)

function BrownianDynamics2(time_step, noise)
    return BrownianDynamics2(time_step, noise, sqrt(time_step * noise))
end

methods(BrownianDynamics2)

function generate_update(state, dynamics::BrownianDynamics2)
    return dynamics.A * randn()
end

brownian2 = BrownianDynamics2(0.01, 2.0)
initial_state = 0.0
@btime trajectory(initial_state, brownian2, steps)

plot_trajectory(states)

pause # This is here for the code demo to prevent the cursor jumping to the next section









##################################
### Type stability and code introspection
##################################

struct BrownianDynamics3
    time_step
    noise
end

function generate_update(state, dynamics::BrownianDynamics3)
    return sqrt(dynamics.time_step * dynamics.noise) * randn()
end

brownian3 = BrownianDynamics3(0.1, 2.0)
initial_state = 0.0
@btime trajectory(initial_state, brownian3, steps)

@code_warntype generate_update(initial_state, brownian)
@code_warntype generate_update(initial_state, brownian3)

@code_warntype trajectory(initial_state, brownian, steps)
@code_warntype trajectory(initial_state, brownian3, steps)

pause # This is here for the code demo to prevent the cursor jumping to the next section











##################################
### More complex abstraction example: customizing state updates
##################################

function update(state, change)
    return state + change
end

function trajectory(initial_state, dynamics, steps)
    states = zeros(typeof(initial_state), steps + 1)
    states[1] = initial_state
    for step = 2:(steps+1)
        change = generate_update(states[step-1], dynamics)
        states[step] = update(states[step-1], change)
    end
    return states
end

struct PeriodicParticle
    position::Float64
end

function update(state::PeriodicParticle, change)
    return PeriodicParticle(mod(state.position + change, 2π))
end

steps = 100
initial_state = 1.0
trajectory(initial_state, brownian2, steps)
initial_state = PeriodicParticle(1.0)
trajectory(initial_state, brownian2, steps)
zero(PeriodicParticle)

pause # This is here for the code demo to prevent the cursor jumping to the next section










##################################
### Overriding base language functions
##################################

import Base: zero
Base.zero(::Type{PeriodicParticle}) = PeriodicParticle(0.0)

zero(PeriodicParticle)
steps = 2000
states = trajectory(initial_state, brownian2, steps)

include("plotting2.jl")
plot_trajectory(states)

pause # This is here for the code demo to prevent the cursor jumping to the next section














##################################
### Parametric types
##################################

struct PeriodicParticle2{T}
    position::T
end


function update(state::PeriodicParticle2{Float64}, change)
    return PeriodicParticle2(mod(state.position + change, 2π))
end

function update(state::PeriodicParticle2{Int64}, change)
    return PeriodicParticle2(mod(state.position + change, 10))
end

state1 = PeriodicParticle2(1.0)
state2 = PeriodicParticle2(1)
update(state1, 5.6)
update(state2, 12)

function Base.zero(::Type{PeriodicParticle2{E}}) where {E}
    return PeriodicParticle2(zero(E))
end
zero(PeriodicParticle2{Float64})
zero(PeriodicParticle2{Int64})

pause # This is here for the code demo to prevent the cursor jumping to the next section













##################################
### Other abstractions: abstract types, value types
##################################


### Abstract types
abstract type AbstractFoo end
struct Foo <: AbstractFoo end # Foo is a subtype of AbstractFoo
bar(::AbstractFoo) = "hi"

bar(1) # Produces an error, as no method of bar is defined for integers
bar(Foo()) # Returns "hi", as Foo is a subtype of AbstractFoo


### Value types: simple example
function fizz(::Val{x}) where {x}
    return x * x
end

fizz(Val(4))
fizz(Val(4.0))

# calculations are done at compile time: the compiled code simply returns 16
@code_typed fizz(Val(4))

# for comparison, a standard multiplication function. buzz(4) doesn't simply return 16,
# as it doesn't know the input value is 4 until run time
buzz(x) = x * x
@code_typed buzz(4)


### Value types: more complex example
# Suppose we wan't to set the period over which a PeriodicParticle wraps. A simple way
# to do this would be to expand the type to include a "period" field that is stored in it.
# Alternatively, we could include the period within the type itself as follows.
struct PeriodicParticle3{T,P}
    position::T
end

function PeriodicParticle3(position, period)
    return PeriodicParticle3{typeof(position),Val{period}}(position)
end

state = PeriodicParticle3(1.0, 2.0) # produces PeriodicParticle3{Float64, Val{2.0}}(1.0)

# using the period within the update function can be done as follows
function update(state::PeriodicParticle3{T,Val{P}}, change) where {T,P}
    return PeriodicParticle3{T,Val{P}}(mod(state.position + change, P))
end
function Base.zero(::Type{PeriodicParticle3{T,Val{P}}}) where {T,P}
    return PeriodicParticle3{T,Val{P}}(0.0)
end

# updates as expected
update(state, 2.5)

# produces zeros as expected
zero(PeriodicParticle3{Float64,Val{2.0}})

# This has two benefits here.
# 1) The type allows a choice of what period is used when the zero function is called
# 2) This allows for greater data compression vs storing the period information as a field
# To see this lets try the simpler case
struct PeriodicParticle4{T,P}
    position::T
    period::P
end
function update(state::PeriodicParticle4, change)
    return PeriodicParticle4(mod(state.position + change, state.period), state.period)
end
function Base.zero(::Type{P}) where {P<:PeriodicParticle4}
    return PeriodicParticle4(0.0, 1.0) # no "nice" way to control the period
end

# The size of the standard Float array is 8 bits per element, so here we see 808
states1 = trajectory(0.0, brownian, steps)
sizeof(states1)
# The output array here contains data for the period stored independently for each 
# timestep, so we end up with an array with twice the memory, 1616 bits
states2 = trajectory(PeriodicParticle4(1.0, 2.0), brownian, steps)
sizeof(states2)
# Here the compiler knows the period information, and knows it is the same throughout
# the trajectory, so it can be stored within the vectors type, rather than with every
# component. As a result, the output array is now back down to a size of 808 bits, i.e.
# simply the position data
states3 = trajectory(PeriodicParticle3(1.0, 2.0), brownian, steps)
sizeof(states3)

# Downsides: 
# 1) Type stability requies the period of PeriodicParticle3 to remain the same,
#    or change predictably (i.e. simple determinisitic arithmetic). Less flexible.
# 2) Similarly, the vector will become more messy if it contains multiple 
#    PeriodicParticle3's with different periods, as it then once again needs to store 
#    that period info, and may do it less efficiently than the manual approach of
#    PeriodicParticle4.

pause # This is here for the code demo to prevent the cursor jumping to the next section















##################################
### Multi-threading
##################################

function trajectory!(states, initial_state, dynamics, steps)
    states[1] = initial_state
    for i = 1:steps
        step = generate_update(states[i], dynamics)
        states[i+1] = update(states[i], step)
    end
    return nothing
end

function trajectories(initial_state, dynamics, T, N)
    states = zeros(typeof(initial_state), T + 1, N)
    for i = 1:N
        trajectory!(@view(states[:, i]), initial_state, dynamics, T)
    end
    return states
end

# Plot
trajs = 1000
initial_state = 0.0
steps = 100
plot_trajectories(trajectories(initial_state, brownian2, steps, trajs))

# Benchmark
trajs = 10000
initial_state = 0.0
steps = 100
@btime trajectories($initial_state, $brownian2, $steps, $trajs)

# Thread
function trajectories_threaded(initial_state, dynamics, T, N)
    states = zeros(typeof(initial_state), T + 1, N)
    Threads.@threads for i = 1:N
        trajectory!(@view(states[:, i]), initial_state, dynamics, T)
    end
    return states
end

@btime trajectories_threaded($initial_state, $brownian2, $steps, $trajs)

pause # This is here for the code demo to prevent the cursor jumping to the next section










##################################
### Broadcasting
##################################

x = rand(4)
y = rand(4)
x .* y

# Expands unit dimensions to match those of other arrays in the expression
x = rand(1, 4)
y = rand(4, 1)
x .* y

# Works for custom functions. Fuses indpendent broadcasts together into a single loop
f(x) = 2.4 * x^3 + 1.5 * x^2
f.(x)

# Expansion of unit dimensions also works for custom functions
g(x, y) = x^2 * y^3 * π
g.(x, y)

# Example of flexibility: extracting data from an array of custom types
initial_state = PeriodicParticle(0.0)
states = trajectory(initial_state, dynamics, steps)
states[1]
states[1].position
getfield(states[1], :position)
data = getfield.(states, :position)