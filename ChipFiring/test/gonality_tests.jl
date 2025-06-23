# using ChipFiring
using Test

@testset "gonality tests" begin
    @testset "tree" begin
        adj_matrix = [
            0 1 1;
            1 0 0;
            1 0 0;
        ]
        g = ChipFiringGraph(adj_matrix)
        
        @test compute_gonality(g, max_d=1, verbose = true) == 1
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
        @test compute_gonality(g, max_d=2, verbose=true) == 2
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
        @test compute_gonality(g, max_d=9, verbose=true) == 3
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
end