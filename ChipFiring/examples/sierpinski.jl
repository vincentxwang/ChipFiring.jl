"""
    sierpinski_gasket(k::Int)

Generates the k-th iteration of the Sierpinski gasket graph.

The construction is recursive:
- `SG(0)` is a single triangle (K3).
- `SG(k)` is formed from `SG(k-1)` by adding a new vertex on each edge of
  `SG(k-1)` and connecting this new vertex to the two endpoints of the original edge,
  effectively subdividing each edge.

# Arguments
- `k::Int`: The iteration number. Must be non-negative.

# Returns
- `ChipFiringGraph`: The graph object representing the k-th Sierpinski gasket graph.
"""
function sierpinski_gasket(k::Int)
    if k < 0
        error("Iteration number k must be non-negative.")
    end

    # Helper function that performs the recursion and tracks the "solid" triangles
    # that are used to generate the next iteration.
    function _sierpinski_recursive(level::Int)
        if level == 1
            # Base case: SG(0) is a K3. It has one solid triangle.
            g = ChipFiringGraph(3, [(1, 2), (2, 3), (3, 1)])
            return g
        end

        if level == 2
            return ChipFiringGraph(6, [(1, 2), (2, 3), (3, 1), (4, 1), (4, 2), (5, 1), (5, 3), (6,2), (6,3)])
        end

        # Recursive step
        prev_g  = _sierpinski_recursive(level - 1)


        new_1 = level * 3 - 2
        new_2 = level * 3 - 1
        new_3 = level * 3

        new_edge_list = Tuple{Int, Int}[]

        for (i, j) in prev_g.edge_list
            push!(new_edge_list, (i,j))
        end

        push!(new_edge_list, (new_1, new_1 - 2))
        push!(new_edge_list, (new_1, new_1 - 3))
        push!(new_edge_list, (new_1, new_1 - 6))


        push!(new_edge_list, (new_2, new_2 - 2))
        push!(new_edge_list, (new_2, new_2 - 4))
        push!(new_edge_list, (new_2, new_2 - 6))


        push!(new_edge_list, (new_3, new_3 - 3))
        push!(new_edge_list, (new_3, new_3 - 4))
        push!(new_edge_list, (new_3, new_3 - 6))

        
        new_g = ChipFiringGraph(level * 3, new_edge_list)
        return new_g
    end
    
    # The public-facing function just returns the graph, not the triangle list.
    g = _sierpinski_recursive(k)
    return g
end
