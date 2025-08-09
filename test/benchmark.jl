using ChipFiring
using BenchmarkTools

function profile_test()
    icosahedron_adj_matrix =[
        0 1 1 1 1 0 0 0 1 0 0 0;
        1 0 1 0 1 1 1 0 0 0 0 0;
        1 1 0 0 0 0 1 1 1 0 0 0;
        1 0 0 0 1 0 0 0 1 1 1 0;
        1 1 0 1 0 1 0 0 0 1 0 0;
        0 1 0 0 1 0 1 0 0 1 0 1;
        0 1 1 0 0 1 0 1 0 0 0 1;
        0 0 1 0 0 0 1 0 1 0 1 1;
        1 0 1 1 0 0 0 1 0 0 1 0;
        0 0 0 1 1 1 0 0 0 0 1 1;
        0 0 0 1 0 0 0 1 1 1 0 1;
        0 0 0 0 0 1 1 1 0 1 1 0
    ]
    
    g = ChipFiringGraph(icosahedron_adj_matrix)
    compute_gonality(g)
end

# @profview profile_test()

# function test()
#     for div in multiexponents(15,7)
#         c = div
#     end
# end
# @btime test()
# @btime multiexponents(8, 5)

@btime profile_test()

# @testset "for fun" begin
#     adj = [
#     0 2 1;
#     2 0 1;
#     1 1 0;
# ]
# g = ChipFiringGraph(adj)
# compute_gonality(g, verbose=true)
# end

# @allocated 