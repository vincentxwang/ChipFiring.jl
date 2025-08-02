"""
    next_composition!(v::Vector{Int}) -> Bool

Mutates the vector `v` into the next composition in-place.
Assumes the sum of elements should remain constant.

# Returns
- `true` if a next configuration was generated.
- `false` if `v` was already the last configuration (e.g., [0, 0, ..., d]).
"""
function next_composition!(v::Vector{Int})
    n = length(v)

    # Find the first non-zero element from the left (the pivot).
    t = findfirst(!iszero, v)

    # If no non-zero element is found, or if all the value is in the last
    # element, we are at the final composition.
    if t === nothing || t == n
        return false
    end

    # Take the value from the pivot position.
    val = v[t]
    # Reset the pivot position to zero.
    v[t] = 0
    # Increment the position to the right of the pivot.
    v[t+1] += 1
    # Add the remainder of the pivot's value (minus the one we moved)
    # to the very first element.
    v[1] += val - 1
    
    return true
end

"""
    has_rank_at_least_r(g::ChipFiringGraph, r::Int, cgon::Bool, ws::Workspace) -> Bool

Internal helper for `compute_gonality`. Checks if a divisor `ws.d1` has rank at least 1.
"""
function has_rank_at_least_r(g::ChipFiringGraph, r::Int, cgon::Bool, ws::Workspace)
    divisor = ws.d1
    if r == 1 || cgon
        for v in 1:g.num_vertices
            divisor.chips[v] -= r
            winnable = is_winnable(g, divisor, ws)
            divisor.chips[v] += r # Always restore state
            if !winnable
                return false
            end
        end
    else
        n = g.num_vertices
        
        # 1. Pre-allocate the vector just ONCE.
        div_chips = zeros(Int, n)
        div_chips[1] = r # 2. Initialize to the first composition.

        # 3. Loop by mutating `div_chips` in-place.

        keep_going = true
        while keep_going
            divisor.chips .-= div_chips
            winnable = is_winnable(g, divisor, ws)
            divisor.chips .+= div_chips # Always restore state
            if !winnable
                return false
            end
            
            # Get the next composition, and stop if we're at the end.
            keep_going = next_composition!(div_chips)
        end
    end
    return true
end

"""
    has_rank_at_least_r(g::ChipFiringGraph, d::Divisor, r::Int, cgon::Bool) -> Bool
Given a ChipFiringGraph `g` and Divisor `d`, returns a boolean determining whether or not `d` has rank at least
`r`. Set `cgon` to be true if we are interested in concentrated rank.
"""
function has_rank_at_least_r(g::ChipFiringGraph, d::Divisor, r::Int, cgon::Bool)
    ws = Workspace(g.num_vertices)
    ws.d1.chips .= d.chips
    return has_rank_at_least_r(g, r, cgon, ws)
end

"""
    rank(g::ChipFiringGraph, d::Divisor)

Given a ChipFiringGraph `g` and Divisor `d`, returns the rank (in the sense of Baker and Norine) of `d` on `g`.
See Divisors and Sandpiles by Corry and Perkinson.
"""
function rank(g::ChipFiringGraph, d::Divisor)
    if !is_winnable(g, d)
        return -1
    else
        rank = 1
        while true
            if !has_rank_at_least_r(g, d, rank, false)
                return rank - 1
            end
            rank += 1
        end
    end
end

"""
    subdivide(g::ChipFiringGraph, subdivisions::Int)

Given a ChipFiring object G, produces another ChipFiring object which is an n-uniform subdivision of G.

# Arguments
- `g::ChipFiringGraph` the original Graph
- `subdivisions::Int` number of subdivisions (1 returns original graph, 2 produces 2-uniform subdivision, etc)

# Returns subdivided graph
"""
function subdivide(g::ChipFiringGraph, subdivisions::Int)
    # if no subdivisions 
    if subdivisions <= 1
        return g
    end

    n = g.num_vertices
    m = g.num_edges

    N = n + (subdivisions-1)*m # new number of edges

    edge_list = g.edge_list
    new_edge_list = Vector{Tuple{Int, Int}}()

    new_vertex = n+1 # label for new vertex
    for (u,v) in edge_list
       # if more than 2, need to add more nodes and edges
        push!(new_edge_list, (u, new_vertex)) # add vertex from source
        # basically make a chain 
        for i in 1:(subdivisions-2) # loop won't run if subdivisions = 2, so just add 1 edge
            push!(new_edge_list, (new_vertex, new_vertex+1))
            new_vertex +=1
        end
        push!(new_edge_list, (new_vertex, v))
        new_vertex += 1
end
    # total vertices is now n + (subdivisions-1)*m
    new_G = ChipFiringGraph(N, new_edge_list)
    return new_G
end