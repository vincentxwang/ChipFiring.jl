"""
    compute_gonality(G::ChipFiringGraph; min_d=1, max_d=nothing, verbose=false, r=1) -> Int

Computes the `r`-th (default: `1`) gonality of a graph ``G``.

# Arguments
- `G::ChipFiringGraph`: The graph to analyze.

# Optional Arguments
- `min_d=1`: The minimum degree to check.
- `max_d=nothing`: The maximum degree to check. Defaults to `nothing`.
- `verbose=false`:  If `true`, prints progress updates.
- `r=1`: Calculates ``r``-th gonality. Defaults to ``1``.

# Returns
- `Int`: The computed gonality of the graph. Returns ``-1`` if not found within `max_d`.

Note: The result may be inaccurate if `min_d` is set above the gonality of a graph.
"""
function compute_gonality(G::ChipFiringGraph; min_d=1, max_d=nothing, verbose=false, r=1)
    n = G.num_vertices
    max_degree_to_check = isnothing(max_d) ? (r * n) - 1 : max_d
    genus = compute_genus(G)

    ws = Workspace(n)

    if r >= genus && (r + genus <= max_degree_to_check)
        return r + genus
    end

    for d in min_d:max_degree_to_check
        if verbose
            num_divisors = binomial(BigInt(n + d - 1), d)
            println("Testing degree d = $d... (checking $num_divisors divisors)")
        end
        
        # d = 0 case
        if d == 0
            ws.d1 .= 0
            if has_rank_at_least_r!(G, r, ws)
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
            ws.d1 .= chips_vec
            if has_rank_at_least_r!(G, r, ws)
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
    dhar!(G::ChipFiringGraph, D::Divisor, q::Int, ws::Workspace) -> Bool

Performs a burn starting from a source vertex ``q`` to determine if the divisor ``D``
is super-stable with respect to ``q``.

# Arguments
- `G::ChipFiringGraph`: The graph structure.
- `D::Divisor`: Input divisor.
- `q::Int`: The vertex (1-indexed) from which to start the burn.
- `ws::Workspace`: Any workspace.

# Returns
- `is_superstable::Bool`: `true` if the entire graph was burned.

# Modifies
- `ws.burned`: Tracks burned vertices.
- `ws.legals`: The indices of unburned vertices that form a legal firing.
- `ws.threats`: Tracks threats to unburned vertices.
"""
function dhar!(G::ChipFiringGraph, D::Divisor, q::Int, ws::Workspace)
    n = G.num_vertices
    
    # Reuse the workspace arrays instead of allocating new ones.
    burned = ws.burned
    threats = ws.threats
    worklist = ws.legals # Temporarily reuse `legals` as a work queue to save memory
    
    # Reset workspace arrays for this run
    fill!(burned, false)
    fill!(threats, 0)
    empty!(worklist)

    burned[q] = true
    num_burned = 1
    
    push!(worklist, q)
    head = 1

    while head <= length(worklist)
        u = worklist[head]
        head += 1
        for v in G.adj_list[u]
            if !burned[v]
                threats[v] += G.adj_matrix[u, v]
                if D[v] < threats[v]
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
    dhar(G::ChipFiringGraph, D::Divisor, q::Int) -> Tuple{Bool, Vector{Int}}

Performs a burn starting from a source vertex ``q`` to determine if the divisor ``D``
is super-stable with respect to ``q``.

# Arguments
- `G::ChipFiringGraph`: The graph structure.
- `D::Divisor`: The chip configuration to test.
- `q::Int`: The vertex (1-indexed) from which to start the burn.

# Returns
- The first element is `true` if the divisor is super-stable, `false` otherwise.
- The second element is a vector of unburned vertices. This vector is empty if the divisor is super-stable.
"""
function dhar(G::ChipFiringGraph, D::Divisor, q::Int)
    ws = Workspace(G.num_vertices)

    is_superstable = dhar!(G, D, q, ws)

    return is_superstable, copy(ws.legals)
end

"""
    q_reduced!(G::ChipFiringGraph, D::Divisor, q::Int, ws::Workspace) -> Divisor

Finds the equivalent ``q``-reduced effective divisor to ``D``.

# Arguments
- `G::ChipFiringGraph`: The graph structure.
- `D::Divisor`: The initial chip configuration.
- `q::Int`: The sink vertex.
- `ws::Workspace`: Any workspace.

# Returns
- `d::Divisor`: The resulting divisor

# Modifies
- `ws.d2`: Uses this space to construct the resulting divisor
- `ws.burned`: Modified by `dhar!`.
- `ws.legals`: Modified by `dhar!`.
- `ws.threats`: Modified by `dhar!`.
"""
function q_reduced!(G::ChipFiringGraph, D::Divisor, q::Int, ws::Workspace)

    # work in ws.d2 instead
    d = ws.d2
    d .= D

    # Stage 1: Benevolence : 
    # can have some performance improvements in two ways 1) debt-reduction trick. 2) keep track of negative nodes

    find_negative_vertices!(ws.firing_set, G, d, q)

    while !isempty(ws.firing_set)
        # fires all non-sink stable vertices
        borrow!(G, d, ws.firing_set)
        
        # modifies ws.firing_set in-place
        find_negative_vertices!(ws.firing_set, G, d, q)
    end

    # Stage 2: Relief
    isSuperstable = dhar!(G, d, q, ws)
    while !isSuperstable
        lend!(G, d, ws.legals)
        isSuperstable = dhar!(G, d, q, ws)
    end

    return d
end

"""
    q_reduced(G::ChipFiringGraph, D::Divisor, q::Int) -> Divisor

Finds the equivalent ``q``-reduced effective divisor to ``D``.

This is a convenience wrapper that allocates a temporary workspace. For performance-critical
code where this function is called repeatedly, use the version that accepts a 
`Workspace` argument.

# Arguments
- `G::ChipFiringGraph`: The graph structure.
- `D::Divisor`: The initial chip configuration.
- `q::Int`: The sink vertex.

# Returns
- `d::Divisor`: The resulting divisor
"""
function q_reduced(G::ChipFiringGraph, D::Divisor, q::Int)
    return q_reduced!(G, D, q, Workspace(G.num_vertices))
end


"""
    find_negative_vertices!(out_vec::Vector{Int}, G::ChipFiringGraph, D::Divisor, q::Int)

Finds all vertices with negative chips (excluding the sink ``q``) and pushes them
into the pre-allocated `out_vec`. This is a non-allocating operation.
"""
function find_negative_vertices!(out_vec::Vector{Int}, G::ChipFiringGraph, D::Divisor, q::Int)

    empty!(out_vec)
    
    for i in 1:G.num_vertices
        if i != q && D[i] < 0
            push!(out_vec, i)
        end
    end
end

"""
    is_winnable!(G::ChipFiringGraph, D::Divisor, ws::Workspace) -> Bool

Checks if a divisor ``D`` is linearly equivalent to an
effective divisor using a version of Dhar's burning algorithm.

# Arguments
- `G::ChipFiringGraph`: The graph structure.
- `D::Divisor`: The initial chip configuration.
- `ws::Workspace`: Any workspace.

# Modifies
- `ws.d2`: Modified by `q_reduced!`.
- `ws.burned`: Modified by `dhar!`.
- `ws.legals`: Modified by `dhar!`.
- `ws.threats`: Modified by `dhar!`.
"""
function is_winnable!(G::ChipFiringGraph, D::Divisor, ws::Workspace)
    q = 1 # can really set to anything. 1 arbitrary
    q_red = q_reduced!(G, D, q, ws)
    if q_red[q] >= 0
        return true
    else
        return false
    end
end

"""
    is_winnable(G::ChipFiringGraph, D::Divisor) -> Bool

Checks if a divisor ``D`` is linearly equivalent to an
effective divisor using a version of Dhar's burning algorithm.

This is a convenience wrapper that allocates a temporary workspace. For performance-critical
code where this function is called repeatedly, use the version that accepts a 
`Workspace` argument.
"""
function is_winnable(G::ChipFiringGraph, D::Divisor)
    is_winnable!(G, D, Workspace(G.num_vertices))
end

"""
    next_composition!(v::Vector{Int}) -> Bool

Mutates a vector `v` into the next composition of the integer `sum(v)`,
generating them in colexicographical order.

# Algorithm
1. Find the first non-zero element from the left, `v[t]`. This is the "pivot".
2. If no such element exists (or it's the last one), we are at the end of the sequence.
3. Move one unit from the pivot to its right neighbor: `v[t+1] += 1`.
4. Move the remaining value of the pivot (`v[t] - 1`) to the very first position `v[1]`.
5. Set the pivot's original position `v[t]` to zero.
Example: `[3, 0, 0]` -> `[2, 1, 0]` -> `[1, 2, 0]` -> `[0, 3, 0]` -> `[2, 0, 1]` ...

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
    has_rank_at_least_r!(G::ChipFiringGraph, r::Int, ws::Workspace) -> Bool

Checks if a divisor `ws.d1` has rank at least ``r``.

# Arguments
- `G::ChipFiringGraph`: The graph structure.
- `r::Int`: The minimum rank to check for.
- `ws::Workspace`: Workspace containing the divisor in `ws.d1`.

# Modifies
- `ws.d2`: Modified by `q_reduced!`
- `ws.burned`: Modified by `dhar!`
- `ws.legals`: Modified by `dhar!`
- `ws.threats`: Modified by `dhar!`
"""
function has_rank_at_least_r!(G::ChipFiringGraph, r::Int, ws::Workspace)
    divisor = ws.d1
    if r == 1
        for v in 1:G.num_vertices
            divisor[v] -= r
            winnable = is_winnable!(G, divisor, ws)
            divisor[v] += r # Always restore state
            if !winnable
                return false
            end
        end
    else
        n = G.num_vertices
        
        # 1. Pre-allocate the vector just ONCE.
        div_chips = zeros(Int, n)
        div_chips[1] = r # 2. Initialize to the first composition.

        # 3. Loop by mutating `div_chips` in-place.

        keep_going = true
        while keep_going
            divisor .-= div_chips
            winnable = is_winnable!(G, divisor, ws)
            divisor .+= div_chips # Always restore state
            if !winnable
                return false
            end
            
            keep_going = next_composition!(div_chips)
        end
    end
    return true
end

"""
    has_rank_at_least_r(G::ChipFiringGraph, D::Divisor, r::Int) -> Bool

Checks if a divisor ``D`` has rank at least ``r``.

# Arguments
- `G::ChipFiringGraph`: The graph to analyze.
- `D::Divisor`: The divisor to check.
- `r::Int`: The minimum rank to check for.
"""
function has_rank_at_least_r(G::ChipFiringGraph, D::Divisor, r::Int)
    ws = Workspace(G.num_vertices)
    ws.d1 .= D
    return has_rank_at_least_r!(G, r, ws)
end

"""
    divisor_rank(G::ChipFiringGraph, D::Divisor) -> Int

Returns the rank (in the sense of Baker and Norine) of a divisor ``D``.
See Divisors and Sandpiles by Corry and Perkinson. This is a convenience wrapper.

# Arguments
- `G::ChipFiringGraph`: The graph to analyze.
- `D::Divisor`: The divisor whose rank is to be computed.
"""
function divisor_rank(G::ChipFiringGraph, D::Divisor)
    ws = Workspace(G.num_vertices)
    if !is_winnable!(G, D, ws)
        return -1
    else
        ws.d1 .= D
        rank = 1
        while true
            if !has_rank_at_least_r!(G, rank, ws)
                return rank - 1
            end
            rank += 1
        end
    end
end

"""
    is_equivalent(G::ChipFiringGraph, D1::Divisor, D2::Divisor) -> Bool

Tests if two divisors are equivalent under chip-firing.

# Arguments
- `G::ChipFiringGraph`: The graph to analyze.
- `D1::Divisor`: The first divisor.
- `D2::Divisor`: The second divisor.
"""
function is_equivalent(G::ChipFiringGraph, D1::Divisor, D2::Divisor)
    q1_red = q_reduced(G, D1, 1)
    q2_red = q_reduced(G, D2, 1)

    return q1_red == q2_red
end
