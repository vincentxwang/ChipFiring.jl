"""
    compute_gonality(g::ChipFiringGraph; min_d=1, max_d=nothing, verbose=false, r=1, cgon=false) -> Int

Computes the `r`-th (default: 1) gonality of a graph `g`.

# Arguments
- `g::ChipFiringGraph`: The graph to analyze.

# Optional Arguments
- `min_d=1`: The minimum degree `d` to check.
- `max_d=nothing`: The maximum degree `d` to check. Defaults to `nothing`.
- `verbose=false`:  If `true`, prints progress updates.
- `r=1`: Calculates `r`-th gonality. Defaults to `1`.
- `cgon=false`: Calculate the concentrated r-th gonality if `true`. 

# Returns
- `Int`: The computed gonality of the graph. Returns -1 if not found within `max_d`.

The result of compute_gonality may return r * n in the case when max_d is set to r * n - 1.
"""
function compute_gonality(g::ChipFiringGraph; min_d=1, max_d=nothing, verbose=false, r=1, cgon=false)
    n = g.num_vertices
    max_degree_to_check = isnothing(max_d) ? (r * n) - 1 : max_d
    genus = compute_genus(g)

    ws = Workspace(n)

    if r >= genus && !cgon && (r + genus <= max_degree_to_check)
        return r + genus
    end

    for d in min_d:max_degree_to_check
        if verbose
            num_divisors = binomial(BigInt(n + d - 1), d)
            println("Testing degree d = $d... (checking $num_divisors divisors)")
        end
        
        # d = 0 case
        if d == 0
            ws.d1.chips .= 0
            if has_rank_at_least_r(g, r, ws, cgon=cgon)
                if verbose; println("SUCCESS: Found divisor of degree 0 with rank >= $r."); end
                return 0
            end
            continue # Go to next degree
        end

        # 1. Pre-allocate the vector for chip combinations ONCE per degree `d`.
        chips_vec = zeros(Int, n)
        chips_vec[1] = d # initialize chips_vec to [d, 0, 0, ..., 0].

        # 3. Use a `while` loop that mutates `chips_vec` in-place.
        keep_going = true
        while keep_going
            # The body of the original loop, using `chips_vec`
            ws.d1.chips .= chips_vec
            if has_rank_at_least_r(g, r, ws, cgon=cgon)
                if verbose; println("SUCCESS: Found divisor of degree $d with rank >= $r. Divisor: $chips_vec"); end
                return d
            end

            # mutates chip_vec to be the next configuration to check
            keep_going = next_composition!(chips_vec)
        end
    end

    if max_degree_to_check == (r * n) - 1
        return r * n
    end
    
    # failed to find divisor
    return -1
end

"""
    dhar!(g::ChipFiringGraph, divisor::Divisor, source::Int, ws::Workspace) -> Bool

Performs a recursive burn starting from a `source` vertex to determine if a `divisor`
is super-stable with respect to that source.

Following the user's definition, a divisor is super-stable if the entire graph burns.
A vertex `v` "burns" if its number of chips is less than the number of edges connecting
it to already-burnt vertices.

# Arguments
- `g::ChipFiringGraph`: The graph structure.
- `divisor::Divisor`: Input divisor.
- `source::Int`: The vertex (1-indexed) from which to start the burn.

# Returns
- `is_superstable::Bool`: `true` if the entire graph was burned.


# Modifies
- `ws.burned::Vector{Bool}`: Tracks burned vertices. 
- `ws.legals::Vector{Int}`: The indices of unburned vertices that form a legal firing.
"""
function dhar!(g::ChipFiringGraph, divisor::Divisor, source::Int, ws::Workspace)
    n = g.num_vertices
    
    # Reuse the workspace arrays instead of allocating new ones.
    burned = ws.burned
    threats = ws.threats
    worklist = ws.legals # Temporarily reuse `legals` as a work queue to save memory
    
    # Reset workspace arrays for this run
    fill!(burned, false)
    fill!(threats, 0)
    empty!(worklist)

    burned[source] = true
    num_burned = 1
    
    push!(worklist, source)
    head = 1

    while head <= length(worklist)
        u = worklist[head]
        head += 1
        for v in g.adj_list[u]
            if !burned[v]
                threats[v] += g.adj_matrix[u, v]
                if divisor.chips[v] < threats[v]
                    burned[v] = true
                    push!(worklist, v)
                    num_burned += 1
                end
            end
        end
    end

    is_superstable = (num_burned == n)
    
    # Now, correctly populate the `legals` vector (which is `worklist`) in-place.
    empty!(worklist) # Clear the temporary queue items
    if !is_superstable
        for i in 1:n
            if !burned[i]
                push!(worklist, i)
            end
        end
    end # If superstable, the vector is correctly left empty.
    
    # `ws.legals` is now correctly populated without any new allocations.
    return is_superstable
end

"""
    dhar(g::ChipFiringGraph, divisor::Divisor, source::Int) -> Tuple{Bool, Vector{Int}}

Performs a burn starting from a `source` vertex to determine if a `divisor`
is super-stable.

This is a convenience wrapper that allocates a temporary workspace. For performance-critical
code where this function is called repeatedly, use the version that accepts a 
`Workspace` argument.

# Arguments
- `g::ChipFiringGraph`: The graph structure.
- `divisor::Divisor`: The chip configuration to test.
- `source::Int`: The vertex (1-indexed) from which to start the burn.

# Returns
- The first element is `true` if the divisor is super-stable, `false` otherwise.
- The second element is a vector of unburned vertices. This vector is empty if the divisor is super-stable.
"""
function dhar(g::ChipFiringGraph, divisor::Divisor, source::Int)
    ws = Workspace(g.num_vertices)

    is_superstable = dhar!(g, divisor, source, ws)

    return is_superstable, copy(ws.legals)
end

"""
    q_reduced(g::ChipFiringGraph, divisor::Divisor; q::Int, ws::Workspace) -> Divisor

Finds the equivalent, q-reduced effective divisor to the one given.

# Arguments
- `g`: The graph structure.
- `divisor`: The initial chip configuration.
- `q`: The sink vertex.
- `ws`: The workspace containing pre-allocated arrays.

# Returns
- `d::Divisor`: The resulting divisor
"""
function q_reduced(g::ChipFiringGraph, divisor::Divisor, q::Int, ws::Workspace)

    d = ws.d2
    d.chips .= divisor.chips

    # Stage 1: Benevolence : 
    # can have some performance improvements in two ways 1) debt-reduction trick. 2) keep track of negative nodes

    find_negative_vertices!(ws.firing_set, g, d, q)

    while !isempty(ws.firing_set)
        # fires all non-sink stable vertices
        borrow!(g, d, ws.firing_set)
        
        # modifies ws.firing_set in-place
        find_negative_vertices!(ws.firing_set, g, d, q)
    end

    # Stage 2: Relief
    isSuperstable = dhar!(g, d, q, ws)
    while d.chips[q] < 0 && !isSuperstable
        lend!(g, d, ws.legals)
        isSuperstable = dhar!(g, d, q, ws)
    end

    return d
end

"""
    q_reduced(g::ChipFiringGraph, divisor::Divisor; q::Int, ws::Workspace) -> Divisor

Finds the equivalent, q-reduced effective divisor to the one given, based on the algorithm
from the user-provided Python code.

This is a convenience wrapper that allocates a temporary workspace. For performance-critical
code where this function is called repeatedly, use the version that accepts a 
`Workspace` argument.

# Arguments
- `g`: The graph structure.
- `divisor`: The initial chip configuration.
- `q`: The sink vertex.
- `ws`: The workspace containing pre-allocated arrays.

# Returns
- `d::Divisor`: The resulting divisor
"""
function q_reduced(g::ChipFiringGraph, divisor::Divisor, q::Int)
    return q_reduced(g, divisor, q, Workspace(g.num_vertices))
end


"""
    find_negative_vertices!(out_vec::Vector{Int}, g::ChipFiringGraph, d::Divisor, q::Int)

Finds all vertices with negative chips (excluding the sink `q`) and pushes them
into the pre-allocated `out_vec`. This is a non-allocating operation.
"""
function find_negative_vertices!(out_vec::Vector{Int}, g::ChipFiringGraph, d::Divisor, q::Int)

    empty!(out_vec)
    
    for i in 1:g.num_vertices
        if i != q && d.chips[i] < 0
            push!(out_vec, i)
        end
    end
end

"""
    is_winnable(g::ChipFiringGraph, divisor::Divisor, ws::Workspace) -> Bool

Checks if a chip configuration is linearly equivalent to an
effective divisor using a version of Dhar's burning algorithm.
"""
function is_winnable(g::ChipFiringGraph, divisor::Divisor, ws::Workspace)
    q = 1 # can really set to anything. 1 arbitrary
    q_red = q_reduced(g, divisor, q, ws)
    if q_red.chips[q] >= 0
        return true
    else
        return false
    end
end

"""
    is_winnable(g::ChipFiringGraph, divisor::Divisor) -> Bool

Checks if a chip configuration is linearly equivalent to an
effective divisor using a version of Dhar's burning algorithm.

This is a convenience wrapper that allocates a temporary workspace. For performance-critical
code where this function is called repeatedly, use the version that accepts a 
`Workspace` argument.
"""
function is_winnable(g::ChipFiringGraph, divisor::Divisor)
    is_winnable(g, divisor, Workspace(g.num_vertices))
end

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
    has_rank_at_least_r(g::ChipFiringGraph, r::Int, ws::Workspace; cgon::Bool) -> Bool

Checks if a divisor `ws.d1` has rank at least `r`.
"""
function has_rank_at_least_r(g::ChipFiringGraph, r::Int, ws::Workspace; cgon=false)
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
            
            keep_going = next_composition!(div_chips)
        end
    end
    return true
end

"""
    has_rank_at_least_r(g::ChipFiringGraph, d::Divisor, r::Int; cgon::Bool) -> Bool
Given a ChipFiringGraph `g` and Divisor `d`, returns a boolean determining whether or not `d` has rank at least
`r`. 

Set `cgon` to be true if we are interested in concentrated rank. 
"""
function has_rank_at_least_r(g::ChipFiringGraph, d::Divisor, r::Int; cgon=false)
    ws = Workspace(g.num_vertices)
    ws.d1.chips .= d.chips
    return has_rank_at_least_r(g, r, ws; cgon=cgon)
end

"""
    divisor_rank(g::ChipFiringGraph, d::Divisor) -> Int

Given a ChipFiringGraph `g` and Divisor `d`, returns the rank (in the sense of Baker and Norine) of `d` on `g`.
See Divisors and Sandpiles by Corry and Perkinson.

Set `cgon` to be true if we are interested in concentrated rank.
"""
function divisor_rank(g::ChipFiringGraph, d::Divisor; cgon=false)
    if !is_winnable(g, d)
        return -1
    else
        rank = 1
        while true
            if !has_rank_at_least_r(g, d, rank, cgon=cgon)
                return rank - 1
            end
            rank += 1
        end
    end
end
