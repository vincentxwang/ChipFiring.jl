import Base: show

"""
    lend!(g::ChipFiringGraph, d::Divisor, v::Int)

Lends (fires) a single vertex `v`.
"""
function lend!(g::ChipFiringGraph, d::Divisor, v::Int)
    deg_v = g.valency_list[v]

    # subtract chips on v
    d[v] -= deg_v

    # distribute chips to neighbors
    for j in g.adj_list[v]
        d[j] += g.adj_matrix[v, j]
    end
end

"""
    lend!(g::ChipFiringGraph, d::Divisor, vertices::Vector{Int})

Lends (fires) from each vertex in the provided vector.
"""
function lend!(g::ChipFiringGraph, d::Divisor, vertices::Vector{Int})
    for v in vertices
        lend!(g, d, v)
    end
end

"""
    borrow!(g::ChipFiringGraph, d::Divisor, v::Int)

Borrows from a single vertex `v`.
"""
function borrow!(g::ChipFiringGraph, d::Divisor, v::Int)
    deg_v = g.valency_list[v]

    # add chips on v
    d[v] += deg_v

    # neighbors lose chips
    for j in g.adj_list[v]
        d[j] -= g.adj_matrix[v, j]
    end
end

"""
    borrow!(g::ChipFiringGraph, d::Divisor, vertices::Vector{Int})

Borrows from each vertex in the provided vector.
"""
function borrow!(g::ChipFiringGraph, d::Divisor, vertices::Vector{Int})
    for v in vertices
        borrow!(g, d, v)
    end
end

"""
    neighbors(g::ChipFiringGraph, v::Int) -> Vector{Int}

Returns a vector containing the indices of the neighbors of vertex `v`.
"""
function neighbors(g::ChipFiringGraph, v::Int)
    return g.adj_list[v]
end

"""
    get_num_edges(g::ChipFiringGraph, u::Int, v::Int) -> Int

Returns the number of edges (multiplicity) between two vertices `u` and `v`.
"""
function get_num_edges(g::ChipFiringGraph, u::Int, v::Int)
    return g.adj_matrix[u, v]
end

"""
    laplacian(g::ChipFiringGraph) -> Matrix{Int}

Returns the discrete Laplacian matrix of `g`.
"""
function laplacian(g::ChipFiringGraph)
    return diagm(g.valency_list) - g.adj_matrix
end

"""
    show(io::IO, g::ChipFiringGraph)

Provides a concise, single-line string representation of a ChipFiringGraph. To obtain a string output,
the `string()` function can do so.
"""
function show(io::IO, g::ChipFiringGraph)
    edge_strs = [string(e) for e in g.edge_list]
    print(io, "Graph(V=$(g.num_vertices), E=$(g.num_edges), Edges=[$(join(edge_strs, ", "))])")
end

"""
    compute_genus(g::ChipFiringGraph) -> Int

Returns the genus (in the topological sense) of the graph represented by `g`. Note that this is 
*not* the typical definition of graph genus.
"""
function compute_genus(g::ChipFiringGraph)
    return g.num_edges - g.num_vertices + 1
end
