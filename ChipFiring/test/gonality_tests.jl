# using ChipFiring
using Test

@testset "gonality tests" begin
    @testset "K_2" begin
        #  1 -- 2
        adj_matrix = [
            0 1;
            1 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g, max_d=3, verbose=true) == 1
        @test compute_gonality(g, max_d=3, verbose=true, r=2) == 2
    end

    @testset "K_2 but with two edges" begin
        #  1 == 2
        adj_matrix = [
            0 2;
            2 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g, max_d=3, verbose=true, cgon=true, r=2) == 2
        @test compute_gonality(g, max_d=3, verbose=true, r=2) == 3
    end

    @testset "C_4" begin
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
        @test compute_gonality(g, max_d=3, verbose=true) == 2

        @test compute_gonality(g, max_d=4, verbose=true, r=2) == 3

        @test compute_gonality(g, max_d=5, verbose=true, r=3) == 4

        @test compute_gonality(g, max_d=6, verbose=true, r=4) == 5

        @test compute_gonality(g, max_d=7, verbose=true, r=5) == 6
    end

    @testset "subdivide C_4" begin
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
        @test compute_gonality(subdivide(g,2), max_d=2, verbose=true) == 2
    end

    @testset "Cube" begin
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


    @testset "Icosahedron" begin

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

    @testset "Tetrahedron" begin

        tet_adj_matrix =[
            0 1 1 1
            1 0 1 1;
            1 1 0 1;
            1 1 1 0;
        ]
        
        g = ChipFiringGraph(tet_adj_matrix)
        
        # The gonality of the tetrahedron graph is 3 (https://arxiv.org/pdf/2407.05158)
        @test compute_gonality(g, max_d=4, verbose=true) == 3

        # second gonality is 4 (https://arxiv.org/pdf/2002.07753)
        @test compute_gonality(g, max_d=5, verbose=true, r=2) == 4
    
        # third gonality is 6
        @test compute_gonality(g, max_d=7, verbose=true, r=3) == 6
    end

    @testset "Tricycle" begin

        tricycle_adj_matrix =[
            0 1 1 1 1 1 1;
            1 0 1 0 0 0 2;
            1 1 0 2 0 0 0;
            1 0 2 0 1 0 0;
            1 0 0 1 0 2 0;
            1 0 0 0 2 0 1;
            1 2 0 0 0 1 0;
        ]
        
        g = ChipFiringGraph(tricycle_adj_matrix)
        
        # The gonality of the tricycle graph is 6 (https://arxiv.org/pdf/2106.12568)
        @test compute_gonality(g, max_d=6, verbose=true) == 6

        # After we subdivide it, the gonality becomes 5!
        g = subdivide(g, 2)
        @test compute_gonality(g, max_d=5, verbose=true) == 5
    end

    @testset "weird case" begin

        adj_matrix =[
            0 5 0 0 1 0;
            5 0 1 0 0 0;
            0 1 0 5 0 0;
            0 0 5 0 0 1;
            1 0 0 0 0 5;
            0 0 0 1 5 0;
        ]
        
        g = ChipFiringGraph(adj_matrix)
        
        @test compute_gonality(g, max_d=6, verbose=true) == 3
    end

    @testset "K_5 (6-th concentrated gonality)" begin
  
        adj_matrix = [
            0 1 1 1 1;
            1 0 1 1 1;
            1 1 0 1 1;
            1 1 1 0 1;
            1 1 1 1 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g) == 4
        @test compute_gonality(g, r = 6, cgon = true, verbose = true, max_d=10) == 9
    end
end