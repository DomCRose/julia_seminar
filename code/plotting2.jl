# This file contains an overload for plot_trajectory specific to PeriodicParticle.
# It must be defined after the type PeriodicParticle exists in the Julia runtime,
# so it is included in the demo from this separate file after that is the case.

# The function extracts the positions of the particles and then inserts NaNs into the 
# array whenever a transition between 0 <-> 2π occurs, which the plotting library uses 
# to insert a gap in the plotted line. After this padding, it simply calls the original
# plot_trajectory function.

function plot_trajectory(states::Array{PeriodicParticle})
    positions = getfield.(states, :position)
    i = 1
    while i < length(positions)
        if abs(positions[i] - positions[i+1]) > π
            insert!(positions, i+1, NaN)
            i += 1
        end
        i += 1
    end
    return plot_trajectory(positions)
end