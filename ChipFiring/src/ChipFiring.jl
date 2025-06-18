module ChipFiring

using Combinatorics

# Include the source files
include("types.jl")
include("core.jl")
include("utils.jl")
include("algorithms.jl")

# Export the public API
export ChipFiringGraph,
       degree,
       is_stable,
       fire_vertex!,
       stabilize!,
       has_rank_at_least_one,
       compute_gonality

end # module ChipFiring
