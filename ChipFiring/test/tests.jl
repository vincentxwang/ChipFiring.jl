# using ChipFiring
using Test

@testset "ChipFiring.jl Tests" begin

    @testset "basic checks" begin
        #   1 == 2
        #   |    |
        #   4 -- 3
        multiplicity_matrix = [
            0 2 0 1;  # vertex 1
            2 0 1 0;  # vertex 2
            0 1 0 1;  # vertex 3
            1 0 1 0   # vertex 4
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


    @testset "is_winnable 1 (cube)" begin
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
        d2 = deepcopy(divisor1)

        @test is_winnable(g, divisor1, d2) == true

        divisor2 = Divisor([0, -1, 0, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor2, d2) == false

        divisor3 = Divisor([1, -1, 0, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor3, d2) == false

        divisor4 = Divisor([-1, 0, 0, 0, 0, 0, 1, 0])

        @test is_winnable(g, divisor4, d2) == false

        divisor5 = Divisor([1, 0, 1, 0, 0, 1, -1, 1])

        @test is_winnable(g, divisor5, d2) == true

        divisor6 = Divisor([1, 0, 1, 0, 0, 1, -10, 1])

        @test is_winnable(g, divisor6, d2) == false

        divisor7 = Divisor([-1, 0, 3, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor7, d2) == false
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

        divisor1 = Divisor([1, 0, 1, 0, 0, 1, 0, 1])
        d2 = deepcopy(divisor1)

        @test has_rank_at_least_r(g, divisor1, 1, false, d2) == true

        divisor2 = Divisor([1, 0, 0, 0, 0, 1, 0, 1])

        @test has_rank_at_least_r(g, divisor2, 1, false, d2) == false
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
        is_superstable1, legals1 = dhar(g, divisor1, 1)
        @test is_superstable1 == false
        @test sort(legals1) == [2, 3, 4] # Only source vertex 1 burns
        
        # Test case that SHOULD be super-stable (fully burns)
        divisor2 = Divisor([0, 0, 0, 0])
        is_superstable2, legals2 = dhar(g, divisor2, 1)
        @test is_superstable2 == true
        @test isempty(legals2)
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
        @test q_reduced(g_house, divisor, 1, deepcopy(divisor)).chips == [-1, 0, 0, 2, 0]
    end
end

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

@profview profile_test()

@btime multiexponents(8, 5)

@btime profile_test()

@testset "for fun" begin
    adj = [
    0 2 1;
    2 0 1;
    1 1 0;
]
g = ChipFiringGraph(adj)
compute_gonality(g, verbose=true)
end