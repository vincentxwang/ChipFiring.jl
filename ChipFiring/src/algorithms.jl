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
    genus = g.num_edges - g.num_vertices + 1

    ws = Workspace(n)

    if r >= genus && !cgon && (r + genus <= max_degree_to_check)
        return r + genus
    end

    for d in min_d:max_degree_to_check
        if verbose
            num_divisors = binomial(BigInt(n + d - 1), d)
            println("Testing degree d = $d... (checking $num_divisors divisors)")
        end
        
        # d=0 case
        if d == 0
            ws.d1.chips .= 0
            if has_rank_at_least_r(g, r, cgon, ws)
                if verbose; println("  SUCCESS: Found divisor of degree 0 with rank >= $r."); end
                return 0
            end
            continue # Go to next degree
        end

        # 1. Pre-allocate the vector for chip combinations ONCE per degree `d`.
        chips_vec = zeros(Int, n)
        chips_vec[1] = d # 2. Initialize it to the first configuration (e.g., [d, 0, ..., 0]).

        # 3. Use a `while` loop that mutates `chips_vec` in-place.
        keep_going = true
        while keep_going
            # The body of the original loop, using `chips_vec`
            ws.d1.chips .= chips_vec
            if has_rank_at_least_r(g, r, cgon, ws)
                if verbose; println("  SUCCESS: Found divisor of degree $d with rank >= $r."); end
                return d
            end
            
            # Mutate to the next configuration and check if the loop should continue.
            keep_going = next_composition!(chips_vec)
        end
    end

    if max_degree_to_check == (r * n) - 1
        return r * n
    end
    
    return -1 # Gonality not found within the checked range
end



"""
    dhar_recursive!(g, divisor, source, burned, threats)

Internal recursive helper for the `dhar` algorithm. It explores the graph from
the `source` vertex, modifying the `burned` vector in-place.
"""
function dhar_recursive!(g::ChipFiringGraph, d::Divisor, source::Int, burned::Vector{Bool}, threats::Vector{Int})
    
    for v in g.adj_list[source]
        if burned[v]
            continue 
        end

        if d.chips[v] < threats[v]
            burned[v] = true
            for b in neighbors(g,v)
                threats[b] += get_num_edges(g, v, b)
            end
            dhar_recursive!(g, d, v, burned, threats)
        end
    end
end

"""
    dhar(g::ChipFiringGraph, divisor::Divisor, source::Int, ws::Workspace)

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
    q_reduced(g::ChipFiringGraph, divisor::Divisor; q::Int, ws::Workspace)

Finds an equivalent, q-reduced effective divisor to the one given, based on the algorithm
from the user-provided Python code.

# Arguments
- `g`: The graph structure.
- `divisor`: The initial chip configuration.
- `q`: The sink vertex.
- `d`: Any dummy divisor (to reduce allocations).

# Returns
- `d::Vector{Int}`: The resulting divisor
"""
function q_reduced(g::ChipFiringGraph, divisor::Divisor, q::Int, ws::Workspace)

    d = ws.d2
    d.chips .= divisor.chips

    # Stage 1: Benevolence : can have some performance improvements in two ways 1) debt-reduction trick. 2) keep track of negative nodes

    find_negative_vertices!(ws.firing_set, g, d, q)

    while !isempty(ws.firing_set)
        # Fire all non-sink stable vertices
        borrow!(g, d, ws.firing_set)
        
        # Subsequent checks also populate in-place, without new allocations.
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
    find_negative_vertices!(out_vec::Vector{Int}, g::ChipFiringGraph, d::Divisor, q::Int)

Finds all vertices with negative chips (excluding the sink `q`) and pushes them
into the pre-allocated `out_vec`. This is a non-allocating operation.
"""
function find_negative_vertices!(out_vec::Vector{Int}, g::ChipFiringGraph, d::Divisor, q::Int)
    # Clear the vector of any old data before reusing it.
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
    q = 1 # can really set to anything
    q_red = q_reduced(g, divisor, q, ws)
    if q_red.chips[q] >= 0
        return true
    else
        return false
    end
end

"""
    is_winnable(g::ChipFiringGraph, divisor::Divisor) -> Bool

Wrapper.
"""
function is_winnable(g::ChipFiringGraph, divisor::Divisor)
    is_winnable(g, divisor, Workspace(g.num_vertices))
end
