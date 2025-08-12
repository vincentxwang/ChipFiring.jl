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
        q_reduced,
        q_reduced!,
        dhar,
        dhar!,
        is_winnable,
        is_winnable!,
        has_rank_at_least_r,
        has_rank_at_least_r!,
        divisor_rank,
        is_equivalent,
        clear!,
        
        # LOW-LEVEL OPERATIONS / UTILITIES
        lend!,
        borrow!,
        laplacian,
        compute_genus,
        neighbors,
        get_num_edges,
        subdivide,
        parse_graph6
        
end # module ChipFiring
