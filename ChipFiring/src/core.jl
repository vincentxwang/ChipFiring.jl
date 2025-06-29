"""
    lend!(g::ChipFiringGraph, d::Divisor, v::Int)

Lends (fires) a single vertex `v`.
"""
function lend!(g::ChipFiringGraph, d::Divisor, v::Int)
    deg_v = g.degree_list[v]

    # Vertex v loses `deg_v` chips
    d.chips[v] -= deg_v

    # Distribute chips to neighbors
    for j in g.adj_list[v]
        d.chips[j] += g.adj_matrix[v, j]
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
    deg_v = g.degree_list[v]

    # Vertex v loses `deg_v` chips
    d.chips[v] += deg_v

    # Distribute chips to neighbors
    for j in g.adj_list[v]
        d.chips[j] -= g.adj_matrix[v, j]
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
    if u < 1 || u > g.num_vertices || v < 1 || v > g.num_vertices
        error("Vertex index out of bounds (1 to $(g.num_vertices)).")
    end
    return g.adj_matrix[u, v]
end

"""
    laplacian(g::ChipFiringGraph) -> 

Returns the number of edges (multiplicity) between two vertices `u` and `v`.
"""
function laplacian(g::ChipFiringGraph)
    return diagm(g.degree_list) - g.adj_matrix
end

"""
    sprint_graph(g::ChipFiringGraph) -> String

Returns a concise, single-line string representation of a ChipFiringGraph.
"""
function sprint_graph(g::ChipFiringGraph)
    edge_strs = [string(e) for e in g.edge_list]
    return "Graph(V=$(g.num_vertices), E=$(g.num_edges), Edges=[$(join(edge_strs, ", "))])"
end

