import Base: show

"""
    lend!(G::ChipFiringGraph, D::Divisor, v::Int)

Lends (fires) a single vertex ``v``.
"""
function lend!(G::ChipFiringGraph, D::Divisor, v::Int)
    deg_v = G.valency_list[v]

    # subtract chips on v
    D[v] -= deg_v

    # distribute chips to neighbors
    for j in G.adj_list[v]
        D[j] += G.adj_matrix[v, j]
    end
end

"""
    lend!(G::ChipFiringGraph, D::Divisor, vertices::Vector{Int})

Lends (fires) from each vertex in the provided vector.
"""
function lend!(G::ChipFiringGraph, D::Divisor, vertices::Vector{Int})
    for v in vertices
        lend!(G, D, v)
    end
end

"""
    borrow!(G::ChipFiringGraph, D::Divisor, v::Int)

Borrows from a single vertex ``v``.
"""
function borrow!(G::ChipFiringGraph, D::Divisor, v::Int)
    deg_v = G.valency_list[v]

    # add chips on v
    D[v] += deg_v

    # neighbors lose chips
    for j in G.adj_list[v]
        D[j] -= G.adj_matrix[v, j]
    end
end

"""
    borrow!(G::ChipFiringGraph, D::Divisor, vertices::Vector{Int})

Borrows from each vertex in the provided vector.
"""
function borrow!(G::ChipFiringGraph, D::Divisor, vertices::Vector{Int})
    for v in vertices
        borrow!(G, D, v)
    end
end

"""
    neighbors(G::ChipFiringGraph, v::Int) -> Vector{Int}

Returns a vector containing the indices of the neighbors of vertex ``v``.
"""
function neighbors(G::ChipFiringGraph, v::Int)
    return G.adj_list[v]
end

"""
    get_num_edges(G::ChipFiringGraph, u::Int, v::Int) -> Int

Returns the number of edges (multiplicity) between two vertices ``u`` and ``v``.
"""
function get_num_edges(G::ChipFiringGraph, u::Int, v::Int)
    return G.adj_matrix[u, v]
end

"""
    laplacian(G::ChipFiringGraph) -> Matrix{Int}

Returns the discrete Laplacian matrix of ``G``.
"""
function laplacian(G::ChipFiringGraph)
    n = size(G.adj_matrix, 1)
    L = -copy(G.adj_matrix)
    for i in 1:n
        L[i, i] += G.valency_list[i]
    end
    return L
end

"""
    is_effective(D::Divisor) -> Bool

Checks if a divisor ``D`` is effective, meaning all its chip counts are non-negative.

# Arguments
- `D::Divisor`: The divisor to check.

# Returns
- `Bool`: `true` if ``D(v) \\geq 0`` for all vertices ``v``, and `false` otherwise.
"""
function is_effective(D::Divisor)
    return all(x -> x >= 0, D)
end



"""
    compute_genus(G::ChipFiringGraph) -> Int

Computes the genus ``g`` (in the topological sense) of the graph represented by ``G``, which is given by
```math
g = |E| - |V| + 1
```
Note this definition is from divisor theory and differs from typical definitions of genus on a graph.
"""
function compute_genus(G::ChipFiringGraph)
    return G.num_edges - G.num_vertices + 1
end
