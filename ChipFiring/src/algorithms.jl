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
"""
function compute_gonality(g::ChipFiringGraph; min_d=1, max_d=nothing, verbose=false, r=1, cgon=false)
    n = g.num_vertices
    max_degree_to_check = isnothing(max_d) ? (r * n) : max_d

    for d in min_d:max_degree_to_check
        if verbose; println("Testing degree d = $d..."); end
        
        divisors_to_check = generate_effective_divisors(n, d)
        if verbose; println("  Found $(length(divisors_to_check)) divisors to check for rank >= 1."); end

        for D in divisors_to_check
            if has_rank_at_least_r(g, D, r, cgon)
                if verbose; println("  SUCCESS: Found divisor D = $D of degree $d with r(D) >= 1."); end
                return d
            end
        end
    end
    
    return -1 # Gonality not found within the checked range
end


"""
    dhar_recursive!(g, divisor, source, burned)

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
            for b in 1:g.num_vertices
                threats[b] += get_num_edges(g, v, b)
            end
            dhar_recursive!(g, d, v, burned, threats)
        end
    end
end

"""
    dhar(g::ChipFiringGraph, divisor::Divisor, source::Int)

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
- A tuple `is_superstable, legals` where:
    - `is_superstable::Bool`: `true` if the entire graph was burned.
    - `legals::Vector{Int}`: The indices of unburned vertices that form a legal firing.
"""
function dhar(g::ChipFiringGraph, divisor::Divisor, source::Int)
    n = g.num_vertices
    burned = fill(false, n)
    burned[source] = true

    threats = fill(0, n)

    for b in g.adj_list[source]
        threats[b] += get_num_edges(g, source, b)
    end
    
    dhar_recursive!(g, divisor, source, burned, threats)

    is_superstable = all(burned)
    legals = findall(.!burned)

    return is_superstable, legals
end

"""
    q_reduced(g::ChipFiringGraph, divisor::Divisor; q::Int)

Finds an equivalent, q-reduced effective divisor to the one given, based on the algorithm
from the user-provided Python code.

# Arguments
- `g`: The graph structure.
- `divisor`: The initial chip configuration.
- `q`: The sink vertex.

# Returns
- `d::Vector{Int}`: The resulting divisor
"""
function q_reduced(g::ChipFiringGraph, divisor::Divisor, q::Int)

    d = deepcopy(divisor)

    # Stage 1: Benevolence : can have some performance improvements in two ways 1) debt-reduction trick. 2) keep track of negative nodes

    firing_set = find_negative_vertices(g, d, q)

    while !isempty(firing_set)
        # Fire all non-sink stable vertices
        borrow!(g, d, firing_set)
        firing_set = find_negative_vertices(g, d, q)
    end


    # Stage 2: Relief
    isSuperstable, legals = dhar(g, d, q)
    while d.chips[q] < 0 && !isSuperstable
        lend!(g, d, legals)
        isSuperstable, legals = dhar(g, d, q)
    end

    return d
end

function find_negative_vertices(g::ChipFiringGraph, d::Divisor, q::Int)
    return [i for i in 1:g.num_vertices if (i != q && d.chips[i] < 0)]
end

"""
    is_winnable(g::ChipFiringGraph, d::Divisor) -> Bool

Checks if a chip configuration is linearly equivalent to an
effective divisor using a version of Dhar's burning algorithm.
"""
function is_winnable(g::ChipFiringGraph, d::Divisor)
    q = 1
    q_red = q_reduced(g, d, q)
    if q_red.chips[q] >= 0
        return true
    else
        return false
    end
end
