"""

generate_effective_divisors(num_vertices, degree) -> Vector{Divisor}


Generates all effective divisors (chip configurations with non-negative chips)
of a given total degree.

"""
function generate_effective_divisors(num_vertices, degree)
    return Divisor.(collect(multiexponents(num_vertices, convert(Int, degree))))
end 

"""
    has_rank_at_least_one(g::ChipFiringGraph, d::Divisor) -> Bool

Internal helper for `compute_gonality`. Checks if a divisor `D` has rank at least 1.
"""
function has_rank_at_least_r(g::ChipFiringGraph, d::Divisor, r::Int, cgon::Bool)
    # more optimized code for 1 vertex 
    if r == 1 || cgon
        for v in 1:g.num_vertices
            d.chips[v] -= r
            if !is_winnable(g, d)
                return false
            end
            d.chips[v] += r
        end
    else
        for div in generate_effective_divisors(g.num_vertices, r)
            d.chips .-= div.chips
            if !is_winnable(g, d)
                return false
            end
            d.chips .+= div.chips
        end
    end
    return true
end

"""
 subdivide

 given a ChipFiring object G, produces another ChipFiring object which is an n-uniform subdivision of G 

 # Arguments
 - `G::ChipFiringGraph` the original Graph
 - `subdivisions::Int8` number of subdivisions (1 returns original graph, 2 produces 2-uniform subdivision, etc)

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