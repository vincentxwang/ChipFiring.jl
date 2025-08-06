module ChipFiring

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
        is_winnable,
        has_rank_at_least_r,
        divisor_rank,
        is_equivalent,
        
        # LOW-LEVEL OPERATIONS / UTILITIES
        lend!,
        borrow!,
        laplacian,
        compute_genus,
        neighbors,
        get_num_edges,
        sprint_graph
        
end # module ChipFiring
