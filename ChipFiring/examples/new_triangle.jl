function max_planar(k::Int)
    # 
    edge_list = Tuple{Int, Int}[]   

    for i in 1:k
        push!(edge_list, (3 * i - 2, 3 * i - 1))
        push!(edge_list, (3 * i - 1, 3 * i))
        push!(edge_list, (3 * i, 3 * i - 2))
    end

    for i in 1:(k-1)
        push!(edge_list, (3 * i - 2, 3 * i + 1))
        push!(edge_list, (3 * i - 1, 3 * i + 2))
        push!(edge_list, (3 * i, 3 * i + 3))
    end

    next = 1
    for i in 1:3*(k-1)
        prev = next
        if i%3 == 1
            next = next + 4
        elseif i%3 == 2
            next = next - 2
        elseif i%3 == 0
            next = next + 1
        end
            push!(edge_list, (prev, next))
    end

    return ChipFiringGraph(3*k, edge_list)
end