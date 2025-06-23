Julia

"""
    ChipFiringGraph

A structure to represent the underlying graph of a chip-firing graph.

This struct provides multiple representations of the graph's structure to suit different
computational needs. It is designed for undirected graphs, and the input multiplicity
matrix is expected to be symmetric.

# Fields
- `graph::Matrix{Int}`: The `n x n` multiplicity matrix, where `graph[i, j]` is the
  number of edges between vertex `i` and vertex `j`.
- `num_vertices::Int`: The number of vertices in the graph, `n`.
- `num_edges::Int`: The total number of edges in the graph.
- `adj_list::Vector{Vector{Int}}`: An adjacency list where `adj_list[i]` contains the
  neighbors of vertex `i`. This represents the underlying simple graph, meaning
  each neighbor appears only once, regardless of edge multiplicity.
- `edge_list::Vector{Tuple{Int, Int}}`: A vector of tuples, where each tuple `(i, j)`
  represents an edge. Edges are included with their full multiplicity.
- `degree_list::Vector{Int}`: A vector where `degree_list[i]` stores the degree of
  vertex `i`, accounting for edge multiplicity.

# Constructors
- `ChipFiringGraph(multiplicity_matrix::Matrix{Int})`: Constructs a `ChipFiringGraph`
  from a square, symmetric multiplicity matrix. Throws an error if the matrix is not
  square or not symmetric.
- `ChipFiringGraph(num_vertices::Int, edge_list::Vector{Tuple{Int, Int}})`: Constructs
  a `ChipFiringGraph` from a list of edges and the total number of vertices.
"""
struct ChipFiringGraph
    graph::Matrix{Int}
    num_vertices::Int
    num_edges::Int
    adj_list::Vector{Vector{Int}}
    edge_list::Vector{Tuple{Int, Int}}
    degree_list::Vector{Int}


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
        edge_list = Tuple{Int, Int}[]

        for i in 1:num_vertices
            for j in 1:num_vertices
                if multiplicity_matrix[i,j] != 0
                    # Add to adjacency list for both vertices
                    push!(adj_list[i], j)
                    if i < j
                        # Add to edges list once (but a certain number of times!)
                        for _ in 1:multiplicity_matrix[i,j]
                            push!(edge_list, (i,j))
                        end
                    end
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
        multiplicity_matrix = zeros(Int, num_vertices, num_vertices)
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
