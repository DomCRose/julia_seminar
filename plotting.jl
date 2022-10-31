# Contains code for plotting individual and multiple trajectories generated during
# the code demo.

using GLMakie
using Colors

function plot_trajectory(states)
    fig = Figure(resolution=(1600, 800), fontsize=52)
    ax = fig[1, 1] = Axis(fig[1, 1]; xlabel="Time", ylabel="Position")
    line = lines!(ax, states, linewidth=10)
    return fig
end

function plot_trajectories(states)
    fig = Figure(resolution=(1600, 800), fontsize=52)
    ax = fig[1, 1] = Axis(fig[1, 1]; xlabel="Time", ylabel="Position")
    for s in eachslice(states, dims = 2)
        lines!(ax, s, linewidth=1, color = RGBA(0.0, 0.0, 0.0, 0.1))
    end
    return fig
end

plot_trajectory(rand(10))
plot_trajectories(rand(10, 10))