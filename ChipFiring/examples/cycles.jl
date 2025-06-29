function cycle(k::Int)
    edge_list = Tuple{Int, Int}[]

    for i in 1:(k-1)
        push!(edge_list, (i, i+1))
    end

    if k>2
        push!(edge_list, (1,k))
    end

    for i in 1:k
        push!(edge_list, (i, k+1))
    end
    return ChipFiringGraph(k+1, edge_list)
end