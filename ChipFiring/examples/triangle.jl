function tri(k::Int)
    # 
    edge_list = Tuple{Int, Int}[]

    for i in 1:k
        start = 3 * i - 2
        push!(edge_list, (start, start+1))
        push!(edge_list, (start+1, start+2))
        push!(edge_list, (start, start+2))
        if start > 3
            push!(edge_list, (start, start-3))
        end
    end

    return ChipFiringGraph(3*k, edge_list)
end

function tet(k::Int)
    # 
    edge_list = Tuple{Int, Int}[]

    for i in 1:k
        start = 5 * i - 4
        push!(edge_list, (start, start+1))
        # push!(edge_list, (start+1, start+2))
        push!(edge_list, (start+2, start+3))
        push!(edge_list, (start, start+3))
        push!(edge_list, (start+4, start))
        push!(edge_list, (start+4, start+1))
        push!(edge_list, (start+4, start+2))
        push!(edge_list, (start+4, start+3))
        if start > 3
            push!(edge_list, (start, start-2))
        end
    end

    return ChipFiringGraph(5*k, edge_list)
end