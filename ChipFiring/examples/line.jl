function path_cone(k::Int)
    # 
    edge_list = Tuple{Int, Int}[]
    apex = k+1
    apex2 = k+2

    for i in 1:k
        push!(edge_list, (apex, i))
        push!(edge_list, (apex2, i))
        if i <= k-1
            push!(edge_list, (i, i+1))
        end
    end
    push!(edge_list, (apex, apex2))

    return ChipFiringGraph(k+2, edge_list)
end