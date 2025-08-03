module ChipFiring

using LinearAlgebra

include("types.jl")
include("core.jl")
include("utils.jl")
include("algorithms.jl")

export  # TYPES
        ChipFiringGraph,
        Divisor,
        Workspace,

        # MAIN ALGORITHMS & ANALYSIS
        compute_gonality,
        rank,
        q_reduced,
        dhar,
        subdivide,

        # PREDICATES (is/has functions)
        is_winnable,
        has_rank_at_least_r,
        
        # LOW-LEVEL OPERATIONS
        lend!,
        borrow!,

        # GRAPH PROPERTIES & UTILITIES
        laplacian,
        compute_genus,
        neighbors,
        get_num_edges,
        sprint_graph

end # module ChipFiring
