"""
    ChipFiringGraph

A mutable struct representing a chip-firing multigraph.

# Fields
- `graph::Matrix{Int}`: An `n x n` multiplicity matrix where `graph[i, j]` is the 
  number of edges between vertex `i` and `j`. The graph is assumed to be undirected,
  so this matrix should be symmetric.
- `num_vertices::Int`: The number of vertices in the graph, `n`.
"""
struct ChipFiringGraph
    graph::Matrix{Int}
    num_vertices::Int
    adj_list::Vector{Vector{Int}}


    """
        ChipFiringGraph(multiplicity_matrix::Matrix{Int})

    Constructor for a `ChipFiringGraph`. The input graph should be symmetric.
    """
    function ChipFiringGraph(multiplicity_matrix::Matrix{Int})
        n = size(multiplicity_matrix, 1)
        if size(multiplicity_matrix, 2) != n
            error("Multiplicity matrix must be square.")
        end
        if any(multiplicity_matrix .!= multiplicity_matrix')
            error("Multiplicity matrix is not symmetric. The graph will be treated as directed.")
        end

        adj_list = [Int[] for _ in 1:n]

        for i in 1:n
            for j in 1:n
                if multiplicity_matrix[i,j] != 0
                    push!(adj_list[i], j)
                end
            end
        end
        
        new(multiplicity_matrix, n, adj_list)
    end
end

"""
    Divisor

A mutable struct representing a chip configuration (or "divisor") on a graph.
This object is intentionally separate from `ChipFiringGraph` to allow for efficient
analysis, as the same graph structure can be tested with many different divisors
without copying the graph itself.

# Fields
- `chips::Vector{Int}`: An `n`-element vector where `chips[i]` is the number of
  chips on vertex `i`.
"""
mutable struct Divisor
    chips::Vector{Int}

    """
        Divisor(chips::Vector{Int})

    Constructor for a `Divisor`. Creates a new divisor from a vector of chip counts.
    """
    function Divisor(chips::Vector{Int})
        new(chips)
    end
end
