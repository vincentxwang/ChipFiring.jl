using ChipFiring
using Test

@testset "ChipFiring.jl Tests" begin

    @testset "degree" begin
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

        @test degree(g, 1) == 3
        @test degree(g, 2) == 3
        @test degree(g, 3) == 2
        @test degree(g, 4) == 2
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

    @testset "compute_gonality (C_4)" begin
        # 4-cycle graph (C_4)
        #   1 -- 2
        #   |    |
        #   4 -- 3
        adj_matrix = [
            0 1 0 1;
            1 0 1 0;
            0 1 0 1;
            1 0 1 0
        ]
        g = ChipFiringGraph(adj_matrix)
        
        # The gonality of a cycle graph is 2
        @test compute_gonality(g) == 2
    end

    @testset "compute_gonality 2 (cube)" begin
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
        
        # The gonality of the cube graph is 4 (https://arxiv.org/pdf/2407.05158)
        @test compute_gonality(g, max_d=4, verbose=true) == 4
    end


    @testset "compute_gonality 3 (icosahedron)" begin

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
        
        # The gonality of the icosahedron graph is 9 (https://arxiv.org/pdf/2407.05158)
        @test compute_gonality(g, max_d=9, verbose=true) == 9
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

        @test is_winnable(g, divisor1) == true

        divisor2 = Divisor([0, -1, 0, 0, 0, 0, 0, 0])

        @test is_winnable(g, divisor2) == false

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

        divisor1 = Divisor([1, 0, 1, 0, 0, 1, 0, 1])

        @test has_rank_at_least_one(g, divisor1) == true

        divisor2 = Divisor([1, 0, 0, 0, 0, 1, 0, 1])

        @test has_rank_at_least_one(g, divisor2) == false
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
        # Divisor has enough chips to resist burning everywhere
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

        # Test case that should be super-stable (fully burns)
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
        g_house = ChipFiringGraph(house_adj_matrix, zeros(Int, 5))

        # Test case that should be super-stable (fully burns)
        divisor = Divisor([1, 0, -1, -2, 3])
        @test q_reduced(g_house, divisor, 1).chips == [-1, 0, 0, 2, 0]
    end
end

@testset "for fun" begin
    adj = [
    0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0;
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1;
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0;
    0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0;
    0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0;
    0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0;
    0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 1;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 1 0;
    0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1;
    0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 0;
    0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 0 0 0 0;
    0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0;
    0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0;
    0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0;
    0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0;
]
g = ChipFiringGraph(adj)
compute_gonality(g, verbose=true)
end