"""

generate_effective_divisors(num_vertices, degree) -> Vector{Divisor}


Generates all effective divisors (chip configurations with non-negative chips)
of a given total degree.

"""
function generate_effective_divisors(num_vertices, degree)
    return Divisor.(collect(multiexponents(num_vertices, convert(Int, degree))))
end 

"""
    has_rank_at_least_r(g::ChipFiringGraph, d::Divisor, r::Int, cgon::Bool) -> Bool

Internal helper for `compute_gonality`. Checks if a divisor `D` has rank at least 1.
"""
function has_rank_at_least_r(g::ChipFiringGraph, divisor::Divisor, r::Int, cgon::Bool, d::Divisor)
    # more optimized code for 1 vertex 

    if r == 1 || cgon
        for v in 1:g.num_vertices
            divisor.chips[v] -= r
            if !is_winnable(g, divisor, d)
                return false
            end
            divisor.chips[v] += r
        end
    else
        for div in generate_effective_divisors(g.num_vertices, r)
            divisor.chips .-= div.chips
            if !is_winnable(g, divisor, d)
                return false
            end
            divisor.chips .+= div.chips
        end
    end
    return true
end

"""
 subdivide(G::ChipFiringGraph, subdivisions::Int)

 Given a ChipFiring object G, produces another ChipFiring object which is an n-uniform subdivision of G.

 # Arguments
 - `G::ChipFiringGraph` the original Graph
 - `subdivisions::Int` number of subdivisions (1 returns original graph, 2 produces 2-uniform subdivision, etc)

 # Returns subdivided graph
"""
function subdivide(G::ChipFiringGraph, subdivisions::Int)
    # if no subdivisions 
    if subdivisions <= 1
        return G
    end

    n = G.num_vertices
    m = G.num_edges

    N = n + (subdivisions-1)*m # new number of edges

    edge_list = G.edge_list
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

"""
    toGraphJL(g::ChipFiringGraph)

Converts a `ChipFiringGraph` into a `Graphs.Graph` object for use with the
Graphs.jl library.

The `Graphs.Graph` type represents a simple graph, so any edge multiplicities
in the `ChipFiringGraph` are ignored.

# Arguments
- `g::ChipFiringGraph`: The `ChipFiringGraph` to convert.

# Returns
- `Graphs.Graph`: A simple graph representation of `g`.
"""
function toGraphJL(g::ChipFiringGraph)
    # Create a new simple graph with the same number of vertices
    jl_graph = SimpleGraph(g.num_vertices)
    
    # Add each edge from the ChipFiringGraph's edge list.
    # The edge_list may contain duplicates if the original graph had multiplicities,
    # but add_edge! handles this by simply not adding an edge that already exists.
    for (u, v) in g.edge_list
        add_edge!(jl_graph, u, v)
    end
    
    return jl_graph
end
