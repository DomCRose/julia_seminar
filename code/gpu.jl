# Running code in this file requires the RandomWalkDynamics, BrownianDynamics and 
# PeriodicParticle types, and the associated methods, from the basics.jl file

##################################
### Coding for both CPU and GPU
##################################
# The key to making sure a function works on both cpu and gpu is to make sure it is
# written in terms of array operations, e.g. similar, fill!, broadcasting, etc.
# Scalar indexing is expensive on GPU: since they are not designed for that kind of
# fine grained control, any operations involving scalar indexing move data back to the 
# CPU, do the calculation, then move it back.
# Simple closures (the updater function defined inside trajectories here, which "closes"
# over the dynamics variable) are supported.

function trajectories(initial_states, dynamics, T)
    # setup storage array
    states = similar(initial_states, length(initial_states), T + 1)
    states = fill!(states, 0.0)
    states[:, 1] .= initial_states

    # setup update closure
    updater(state) = generate_update(state, dynamics)

    # run trajectories
    for i = 1:T
        current_states = view(states, :, i)
        states[:, i+1] .= current_states .+ updater.(current_states)
    end
    return states
end

N = 10000
T = 100

# Run on the CPU
randomwalk = RandomWalkDynamics()
initial_states_rw = zeros(Int64, N)
trajectories(initial_states_rw, randomwalk, T)
@btime trajectories($initial_states_rw, $randomwalk, $T)


brownian = BrownianDynamics(0.1, 2.0)
initial_states_b = zeros(N)
trajectories(initial_states_b, brownian, T)
@btime trajectories($initial_states_b, $brownian, $T)

# Make sure you add the relevant GPU package to your environment first
using CUDA # or AMDGPU, oneAPI, Metal

# Run on the GPU
initial_states_rw_gpu = CuArray(initial_states_rw)
trajectories(initial_states_rw_gpu, randomwalk, T)
@btime trajectories($initial_states_rw_gpu, $randomwalk, $T)

initial_states_b_gpu = CuArray(initial_states_b)
trajectories(initial_states_b_gpu, brownian, T)
@btime trajectories($initial_states_b_gpu, $brownian, $T)


##################################
### GPU arrays support "simple enough" custom types
##################################

# Lets generalize the trajectories function to support custom state types as before
function trajectories(initial_states, dynamics, T)
    # setup storage array
    states = similar(initial_states, length(initial_states), T + 1)
    states = fill!(states, zero(eltype(states)))
    states[:, 1] .= initial_states

    # setup update closure
    updater(state) = generate_update(state, dynamics)

    # run trajectories
    for i = 1:T
        current_states = view(states, :, i)
        states[:, i+1] .= update.(current_states, updater.(current_states))
    end
    return states
end

N = 10000
T = 100

brownian = BrownianDynamics(0.1, 2.0)
initial_states_bp = zeros(PeriodicParticle, N)
trajectories(initial_states_bp, brownian, T)
@btime trajectories($initial_states_bp, $brownian, $T)

initial_states_bp_gpu = CuArray(initial_states_bp) # GPU array of PeriodicParticles
trajectories(initial_states_bp_gpu, brownian, T)
@btime trajectories($initial_states_bp_gpu, $brownian, $T)