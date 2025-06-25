# using ChipFiring
using Test

@testset "gonality tests" begin
    @testset "K_2" begin
        #  1 -- 2
        adj_matrix = [
            0 1 1 1 1;
            1 0 1 1 1;
            1 1 0 1 1;
            1 1 1 0 1;
            1 1 1 1 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g, r = 6, cgon = false, verbose = true, max_d=10) == 9
    end

end