"""
    subdivide(g::ChipFiringGraph, subdivisions::Int) -> ChipFiringGraph

Given a ChipFiringGraph `g`, produces another ChipFiringGraph which is an k-uniform subdivision of `g`.

# Arguments
- `g::ChipFiringGraph` the original graph
- `subdivisions::Int` number of uniform subdivisions (1 returns original graph, 2 produces 2-uniform subdivision, etc.)

# Returns 
- A k-uniform subdivided ChipFiringGraph
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