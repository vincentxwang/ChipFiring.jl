function cone_square(k::Int)
    # 
    edge_list = Tuple{Int, Int}[]
    apex = 2*k + 1

    for i in 1:k
        v1 = 2*i -1
        v2 = 2*i 
        push!(edge_list, (apex, v1))
        push!(edge_list, (apex, v2))
        push!(edge_list, (v1, v2))
        if i <= k-1
            if i%2 == 1
                push!(edge_list, (v1, v1+2))
                push!(edge_list, (v2, v2+2))
                #Triangulate?
                push!(edge_list, (v2, v1+2))
            else
                push!(edge_list, (v1, v1+2))
                push!(edge_list, (v2, v2+2))
                #Triangulate?
                push!(edge_list, (v1, v2+2))
            end

        end
    end

    return ChipFiringGraph(2*k+1, edge_list)
end