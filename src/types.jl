import Base: getindex, setindex!, length, iterate, eltype, ==, ≤, <, ≥, >, Broadcast
using Graphs

"""
    ChipFiringGraph

A structure to represent the underlying (multi)graph of a chip-firing graph. A graph is assumed to 
be undirected, connected, and with no self-loops.

# Fields
- `adj_matrix::Matrix{Int}`: The `n x n` multiplicity matrix, where `adj_matrix[i, j]` is
  the number of edges between vertex `i` and vertex `j`.
- `num_vertices::Int`: The number of vertices in the graph.
- `num_edges::Int`: The total number of edges in the graph.
- `adj_list::Vector{Vector{Int}}`: An adjacency list where `adj_list[i]` contains the
  neighbors of vertex `i`. This represents the underlying *simple* graph, meaning
  each neighbor appears only once, regardless of edge multiplicity.
- `edge_list::Vector{Tuple{Int, Int}}`: A vector of tuples, where each tuple `(i, j)`
  represents an edge. Edges are included with their full multiplicity.
- `valency_list::Vector{Int}`: A vector where `valency_list[i]` stores the degree of
  vertex `i`, accounting for edge multiplicity.

# Constructors
- `ChipFiringGraph(multiplicity_matrix::Matrix{Int})`: Constructs a `ChipFiringGraph`
  from a square, symmetric multiplicity matrix. Throws an error if the matrix is not
  square, not symmetric, or if the graph is not connected.
- `ChipFiringGraph(num_vertices::Int, edge_list::Vector{Tuple{Int, Int}})`: Constructs
  a `ChipFiringGraph` from a list of edges and the total number of vertices.
"""
struct ChipFiringGraph <: AbstractGraph{Int}
    
    adj_matrix::Matrix{Int}
    num_vertices::Int
    num_edges::Int
    adj_list::Vector{Vector{Int}}
    edge_list::Vector{Tuple{Int, Int}}
    valency_list::Vector{Int}

    # Constructor that takes in a multiplicity matrix
    function ChipFiringGraph(multiplicity_matrix::Matrix{Int})
        num_vertices = size(multiplicity_matrix, 1)

        if size(multiplicity_matrix, 2) != num_vertices
            throw(DimensionMismatch("Multiplicity matrix must be square. Received dimensions $(size(multiplicity_matrix))."))
        end
        if any(multiplicity_matrix .!= multiplicity_matrix')
            throw(ArgumentError("Multiplicity matrix must be symmetric for an undirected graph."))
        end

        num_edges = div(sum(multiplicity_matrix), 2)

        adj_list = [Int[] for _ in 1:num_vertices]
        edge_list = Tuple{Int, Int}[]

        # Logic for creating the adjacency and edge lists from the multiplicity matrix
        for i in 1:num_vertices
            for j in i:num_vertices
                if multiplicity_matrix[i,j] > 0
                    push!(adj_list[i], j)
                    if i != j
                        push!(adj_list[j], i)
                    end
                    for _ in 1:multiplicity_matrix[i,j]
                        push!(edge_list, (i,j))
                    end
                end
            end
        end
        
        # Check for graph connectivity using bfs
        if num_vertices > 1
            q = [1] 
            visited = falses(num_vertices)
            visited[1] = true
            count = 1
            
            while !isempty(q)
                u = popfirst!(q)
                for v in adj_list[u]
                    if !visited[v]
                        visited[v] = true
                        count += 1
                        push!(q, v)
                    end
                end
            end
            
            if count < num_vertices
                throw(ArgumentError("The graph is not connected."))
            end
        end


        deg_list = [sum(multiplicity_matrix[i, :]) for i in 1:num_vertices]
        
        new(multiplicity_matrix, num_vertices, num_edges, adj_list, edge_list, deg_list)
    end

    # Constructor from edge list
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
    Base.show(io::IO, g::ChipFiringGraph)

Defines the text representation of a `ChipFiringGraph`.
"""
function Base.show(io::IO, g::ChipFiringGraph)
    edge_strs = [string(e) for e in g.edge_list]
    print(io, "Graph(V=$(g.num_vertices), E=$(g.num_edges), Edges=[$(join(edge_strs, ", "))])")
end

# Implementating AbstractGraph{Int}
Graphs.vertices(g::ChipFiringGraph) = 1:g.num_vertices
# IMPORTANT: Graphs.edges implementation ignores multiplicity
Graphs.edges(g::ChipFiringGraph) = [Graphs.Edge(u, v) for (u, v) in g.edge_list]
Graphs.edgetype(g::ChipFiringGraph) = Graphs.SimpleEdge{Int}
Graphs.ne(g::ChipFiringGraph) = g.num_edges # Total edges with multiplicity
Graphs.nv(g::ChipFiringGraph) = g.num_vertices
Graphs.is_directed(::ChipFiringGraph) = false
Graphs.is_directed(::Type{ChipFiringGraph}) = false
Graphs.has_edge(g::ChipFiringGraph, s, d) = g.adj_matrix[s, d] > 0
Graphs.neighbors(g::ChipFiringGraph, v::Int) = g.adj_list[v]
Graphs.outneighbors(g::ChipFiringGraph, v::Int) = g.adj_list[v]
Graphs.inneighbors(g::ChipFiringGraph, v::Int) = g.adj_list[v]
Graphs.weights(g::ChipFiringGraph) = g.adj_matrix


"""
    Divisor <: AbstractVector{Int}

A struct representing a divisor (i.e., chip configuration) on a graph.

# Fields
- `chips::Vector{Int}`: An `n`-element vector where `chips[i]` is the number of
  chips on vertex `i`.
"""
struct Divisor <: AbstractVector{Int}
    chips::Vector{Int}
end

# abstract vector implementations

Base.size(d::Divisor) = size(d.chips)
Base.getindex(d::Divisor, i::Int) = d.chips[i]
Base.setindex!(d::Divisor, val, i::Int) = (d.chips[i] = val)

# partial ordering + equality operators

Base.:(==)(d1::Divisor, d2::Divisor) = (d1.chips == d2.chips)

function Base.:(≤)(d1::Divisor, d2::Divisor)
    if length(d1) != length(d2)
        throw(DimensionMismatch("Divisors must be on the same number of vertices to be compared."))
    end
    return all(d1 .<= d2)
end

Base.:(<)(d1::Divisor, d2::Divisor) = (d1 ≤ d2) && (d1 != d2)
Base.:(≥)(d1::Divisor, d2::Divisor) = (d2 ≤ d1)
Base.:(>)(d1::Divisor, d2::Divisor) = (d2 < d1)

"""
    Workspace

A mutable container for pre-allocated arrays and temporary data structures used in
performance-critical algorithms.

This struct is exposed for users who need to run many computations in a tight loop and
want to avoid repeated memory allocations. For one-off calculations, it is often
more convenient to use the wrapper functions (e.g., `q_reduced(g, d, q)`) which handle
workspace creation automatically.
"""
struct Workspace
    d1::Divisor          # The main temporary divisor
    d2::Divisor
    firing_set::Vector{Int} # For the benevolence loop
    burned::Vector{Bool}    # For dhar!
    threats::Vector{Int}    # For dhar!
    legals::Vector{Int}     # For dhar!

    """
        Workspace(N::Int)

    Constructor for a `Workspace` object. Takes the number of vertices `N` and
    initializes all necessary temporary arrays.
    """
    function Workspace(N::Int)
        # Temporary divisors
        d1 = Divisor(zeros(Int, N))
        d2 = Divisor(zeros(Int, N))
        
        # For the benevolence loop in q_reduce!
        firing_set = Int[]
        
        # Stores burned in dhar!
        burned = fill(false, N)
        
        # Stores threats in dhar!
        threats = zeros(Int, N)
        
        # Stores legal firings in dhar!
        legals = Int[]
        
        new(d1, d2, firing_set, burned, threats, legals)
    end
end

"""
    clear!(ws::Workspace)

Resets all fields in the `Workspace` to their empty and default states.
"""
function clear!(ws::Workspace)
    fill!(ws.d1.chips, 0)
    fill!(ws.d2.chips, 0)
    
    empty!(ws.firing_set)
    empty!(ws.legals)
    
    fill!(ws.burned, false)
    fill!(ws.threats, 0)
    
    return
end