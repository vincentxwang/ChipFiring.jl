"""
    ChipFiringGraph

A struct to represent the static topology of a chip-firing graph.

This structure holds dual representations for convenience: a dense multiplicity matrix
for edge-count lookups and a performance-oriented adjacency list for iterating
over neighbors.

# Fields
- `graph::Matrix{Int}`: The `n x n` multiplicity matrix. `graph[i, j]` stores the
  number of edges connecting vertex `i` and vertex `j`.
- `num_vertices::Int`: The total number of vertices, `n`.
- `adj_list::Vector{Vector{Int}}`: An adjacency list derived from the `graph` matrix.
  `adj_list[i]` contains a vector of vertex `i`'s neighbors.
  **Note**: This list represents the *underlying simple graph*. It records the existence
  of a connection but does not account for edge multiplicity.
"""
struct ChipFiringGraph
    graph::Matrix{Int8}
    num_vertices::Int8
    num_edges::Int16
    adj_list::Vector{Vector{Int8}}
    edge_list::Vector{Tuple{Int8, Int8}}
    degree_list::Vector{Int8}


    """
        ChipFiringGraph(multiplicity_matrix::Matrix{Int})

    Constructor for a `ChipFiringGraph`. The input graph should be symmetric.
    
    # Arguments
    - `multiplicity_matrix::Matrix{Int}`: A square, symmetric matrix where `[i, j]`
      is the number of edges between vertices `i` and `j`.

    # Errors
    - Throws an error if the matrix is not square.
    - Throws an error if the matrix is not symmetric.
    """
    function ChipFiringGraph(multiplicity_matrix::Matrix{Int})
        num_vertices = size(multiplicity_matrix, 1)
        num_edges = sum(multiplicity_matrix)/2

        if size(multiplicity_matrix, 2) != num_vertices
            error("Multiplicity matrix must be square.")
        end
        if any(multiplicity_matrix .!= multiplicity_matrix')
            error("Multiplicity matrix is not symmetric. The graph will be treated as directed.")
        end

        adj_list = [Int[] for _ in 1:num_vertices]
        edge_list = Tuple{Int8, Int8}[]

        for i in 1:num_vertices
            for j in 1:num_vertices
                if multiplicity_matrix[i,j] != 0
                    push!(adj_list[i], j)
                    push!(edge_list, (i,j))
                end
            end
        end

        deg_list = [0 for _ in 1:num_vertices]

        for i in 1:num_vertices
            deg_list[i] = sum(multiplicity_matrix[i, :])
        end
        
        new(multiplicity_matrix, num_vertices, num_edges, adj_list, edge_list, deg_list)
    end

    function ChipFiringGraph(num_vertices::Int, edge_list::Vector{Tuple{Int, Int}})
        multiplicity_matrix = zeros(Int8, num_vertices, num_vertices)
        for (a,b) in edge_list
            multiplicity_matrix[a,b] += 1
            multiplicity_matrix[b,a] += 1
        end
        ChipFiringGraph(multiplicity_matrix)
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
