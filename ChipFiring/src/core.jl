
"""
    degree(g::ChipFiringGraph, v::Int) -> Int

Calculates the degree of a vertex `v` in a multigraph, which is the sum of all
edges connected to it (i.e., the sum of its row in the multiplicity matrix).
"""
function degree(g::ChipFiringGraph, v::Int)
    if v < 1 || v > g.num_vertices
        error("Vertex index $v out of bounds (1 to $(g.num_vertices)).")
    end
    return sum(g.graph[v, :])
end

"""
    lend!(g::ChipFiringGraph, d::Divisor, v::Int)

Lends (fires) a single vertex `v`.
"""
function lend!(g::ChipFiringGraph, d::Divisor, v::Int)
    deg_v = degree(g, v)

    # Vertex v loses `deg_v` chips
    d.chips[v] -= deg_v

    # Distribute chips to neighbors
    for j in 1:g.num_vertices
        d.chips[j] += g.graph[v, j]
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
    deg_v = degree(g, v)

    # Vertex v loses `deg_v` chips
    d.chips[v] += deg_v

    # Distribute chips to neighbors
    for j in 1:g.num_vertices
        d.chips[j] -= g.graph[v, j]
    end
end

"""
    neighbors(g::ChipFiringGraph, v::Int) -> Vector{Int}

Returns a vector containing the indices of the neighbors of vertex `v`.
"""
function neighbors(g::ChipFiringGraph, v::Int)
    if v < 1 || v > g.num_vertices
        error("Vertex index $v out of bounds (1 to $(g.num_vertices)).")
    end
    return findall(x -> x > 0, g.graph[v, :])
end

"""
    get_num_edges(g::ChipFiringGraph, u::Int, v::Int) -> Int

Returns the number of edges (multiplicity) between two vertices `u` and `v`.
"""
function get_num_edges(g::ChipFiringGraph, u::Int, v::Int)
    if u < 1 || u > g.num_vertices || v < 1 || v > g.num_vertices
        error("Vertex index out of bounds (1 to $(g.num_vertices)).")
    end
    return g.graph[u, v]
end
