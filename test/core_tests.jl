using ChipFiring
using Test

@testset "ChipFiring.jl Tests" begin

    @testset "basic checks" begin
        #   1 == 2
        #   |    |
        #   4 -- 3
        multiplicity_matrix = [
            0 2 0 1;
            2 0 1 0;
            0 1 0 1;
            1 0 1 0   
        ]
        g = ChipFiringGraph(multiplicity_matrix)


        @test g.degree_list == [3,3,2,2]
        @test length(g.edge_list) == 5
        @test g.num_edges == 5
    end

    @testset "lend 1 (line)" begin
            # 3-vertex line graph: 1 -- 2 -- 3
            adj_matrix = [
                0 1 0;
                1 0 1;
                0 1 0
            ]
            # Create a graph with some initial chips
            g = ChipFiringGraph(adj_matrix,)
            d = Divisor([1, 5, 2])
            
            # Fire vertex 2
            lend!(g, d, 2)
            
            @test d.chips == [2, 3, 3]

            lend!(g, d, [1, 2])

            @test d.chips == [2, 2, 4]
    end

    @testset "lend_vertex 2 (cube)" begin
        adj_matrix_cube = [
            0 1 0 1 1 0 0 0;
            1 0 1 0 0 1 0 0;
            0 1 0 1 0 0 1 0;
            1 0 1 0 0 0 0 1;
            1 0 0 0 0 1 0 1;
            0 1 0 0 1 0 1 0;
            0 0 1 0 0 1 0 1;
            0 0 0 1 1 0 1 0
        ]
        g_cube = ChipFiringGraph(adj_matrix_cube)
        d = Divisor([5, 0, 0, 0, 0, 0, 0, 0])

        lend!(g_cube, d, 1)

        @test d.chips == [2, 1, 0, 1, 1, 0, 0, 0]
    end


    @testset "neighbors (cube)" begin
        # 8-vertex cube graph
        adj_matrix_cube = [
            0 1 0 1 1 0 0 0;
            1 0 1 0 0 1 0 0;
            0 1 0 1 0 0 1 0;
            1 0 1 0 0 0 0 1;
            1 0 0 0 0 1 0 1;
            0 1 0 0 1 0 1 0;
            0 0 1 0 0 1 0 1;
            0 0 0 1 1 0 1 0
        ]
        g_cube = ChipFiringGraph(adj_matrix_cube)

        # Test neighbors of vertex 1 (connected to 2, 4, 5)
        @test sort(neighbors(g_cube, 1)) == [2, 4, 5]
        
        # Test neighbors of vertex 7 (connected to 3, 6, 8)
        @test sort(neighbors(g_cube, 7)) == [3, 6, 8]
    end


    @testset "is_winnable + rank 1 (cube)" begin
        # cube graph
        #     5-------6
        #     /|      /|
        #    / |     / |
        #   1-------2  |
        #   |  8----|--7
        #   | /     | /
        #   |/      |/
        #   4-------3
    
        cube_adj_matrix = [
            0 1 0 1 1 0 0 0;
            1 0 1 0 0 1 0 0;
            0 1 0 1 0 0 1 0;
            1 0 1 0 0 0 0 1;
            1 0 0 0 0 1 0 1;
            0 1 0 0 1 0 1 0;
            0 0 1 0 0 1 0 1;
            0 0 0 1 1 0 1 0
        ]
        g = ChipFiringGraph(cube_adj_matrix)

        divisor1 = Divisor([0, 0, 0, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor1) == true
        @test divisor_rank(g, divisor1) == 0

        divisor2 = Divisor([0, -1, 0, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor2) == false
        @test divisor_rank(g, divisor2) == -1

        divisor3 = Divisor([1, -1, 0, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor3) == false

        divisor4 = Divisor([-1, 0, 0, 0, 0, 0, 1, 0])

        @test is_winnable(g, divisor4) == false

        divisor5 = Divisor([1, 0, 1, 0, 0, 1, -1, 1])

        @test is_winnable(g, divisor5) == true

        divisor6 = Divisor([1, 0, 1, 0, 0, 1, -10, 1])

        @test is_winnable(g, divisor6) == false

        divisor7 = Divisor([-1, 0, 3, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor7) == false
    end

    @testset "rank at least 1 (cube)" begin
        cube_adj_matrix = [
            0 1 0 1 1 0 0 0;
            1 0 1 0 0 1 0 0;
            0 1 0 1 0 0 1 0;
            1 0 1 0 0 0 0 1;
            1 0 0 0 0 1 0 1;
            0 1 0 0 1 0 1 0;
            0 0 1 0 0 1 0 1;
            0 0 0 1 1 0 1 0
        ]
        g = ChipFiringGraph(cube_adj_matrix)

        @test has_rank_at_least_r(g, Divisor([1, 0, 1, 0, 0, 1, 0, 1]), 1) == true

        @test has_rank_at_least_r(g, Divisor([1, 0, 0, 0, 0, 1, 0, 1]), 1) == false
    end

    @testset "dhar 1 (trivial cases)" begin
        # 4-cycle graph
        adj_matrix = [
            0 1 0 1;
            1 0 1 0;
            0 1 0 1;
            1 0 1 0
        ]
        g = ChipFiringGraph(adj_matrix)
        
        # Test case that should NOT be super-stable (does not fully burn)
        divisor1 = Divisor([1, 1, 1, 1])
        
        is_superstable1, legals = dhar(g, divisor1, 1)
        @test is_superstable1 == false
        @test sort(legals) == [2, 3, 4] # Only source vertex 1 burns
        
        # Test case that SHOULD be super-stable (fully burns)
        divisor2 = Divisor([0, 0, 0, 0])
        is_superstable2, legals = dhar(g, divisor2, 1)
        @test is_superstable2 == true
        @test isempty(legals)
    end

    @testset "dhar 2 (house)" begin
        # House Graph
        #
        #      (5)
        #     /   \
        #    /     \
        #  (3)-----(4)
        #   |       |
        #   |       |
        #  (1)-----(2)
        #
        house_adj_matrix = [
        0 1 1 0 0;
        1 0 0 1 0;
        1 0 0 1 1;
        0 1 1 0 1;
        0 0 1 1 0
    ]
        g_house = ChipFiringGraph(house_adj_matrix)

        divisor = Divisor([0, 0, 2, 0, 1])

        is_superstable, legals = dhar(g_house, divisor, 1)
        @test is_superstable == false
        @test sort(legals) == [3, 5]
    end

    @testset "q-reduced (house)" begin
        # House Graph
        #
        #      (5)
        #     /   \
        #    /     \
        #  (3)-----(4)
        #   |       |
        #   |       |
        #  (1)-----(2)
        #
        house_adj_matrix = [
        0 1 1 0 0;
        1 0 0 1 0;
        1 0 0 1 1;
        0 1 1 0 1;
        0 0 1 1 0
        ]
        g_house = ChipFiringGraph(house_adj_matrix)

        divisor = Divisor([1, 0, -1, -2, 3])
        @test q_reduced(g_house, divisor, 1).chips == [-1, 0, 0, 2, 0]
    end

    @testset "silly vertex" begin
        g = ChipFiringGraph(zeros(Int, 1,1))
        @test compute_gonality(g) == 1
    end

    @testset "get_num_edges" begin
        adj_matrix = [
        0 1 1 0 0;
        1 0 0 1 0;
        1 0 0 1 3;
        0 1 1 0 1;
        0 0 3 1 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test get_num_edges(g, 1,2) == 1
        @test get_num_edges(g, 3, 5) == 3
    end
end
