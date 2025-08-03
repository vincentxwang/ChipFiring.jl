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

        @test compute_gonality(g, max_d=3, verbose=false) == 1
        @test compute_gonality(g, max_d=3, verbose=false, r=2) == 2
    end

    @testset "K_2 but with two edges" begin
        #  1 == 2
        adj_matrix = [
            0 2;
            2 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g, max_d=3, verbose=false, cgon=true, r=2) == 2
        @test compute_gonality(g, max_d=3, verbose=false, r=2) == 3

        # test max_d
        @test compute_gonality(g, max_d=1, verbose=false, r=2) == -1
    end


    @testset "tree" begin
        adj_matrix = [
            0 1 1;
            1 0 0;
            1 0 0;
        ]
        g = ChipFiringGraph(adj_matrix)
        
        @test compute_gonality(g, max_d=1, verbose =false) == 1
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
        @test compute_gonality(g, max_d=3, verbose=false) == 2

        @test compute_gonality(g, max_d=4, verbose=false, r=2) == 3

        @test compute_gonality(g, max_d=5, verbose=false, r=3) == 4

        @test compute_gonality(g, max_d=6, verbose=false, r=4) == 5

        @test compute_gonality(g, max_d=7, verbose=false, r=5) == 6
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
        @test compute_gonality(subdivide(g,2), max_d=2, verbose=false) == 2
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
        @test compute_gonality(g, max_d=4, verbose=false) == 4
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
        @test compute_gonality(g, max_d=9, verbose=false) == 9
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
        @test compute_gonality(g, max_d=4, verbose=false) == 3

        # second gonality is 4 (https://arxiv.org/pdf/2002.07753)
        @test compute_gonality(g, max_d=5, verbose=false, r=2) == 4
    
        # third gonality is 6
        @test compute_gonality(g, max_d=7, verbose=false, r=3) == 6
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
        @test compute_gonality(g, max_d=6, verbose=false) == 6

        # After we subdivide it, the gonality becomes 5!
        g = subdivide(g, 2)
        @test compute_gonality(g, max_d=5, verbose=false) == 5
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
        
        @test compute_gonality(g, max_d=6, verbose=false) == 3
    end
end

# The following test suite tests graphs with different gonality behaviors under uniform subdivision.
@testset "gonality savings graphs (subdivisions)" begin
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
        @test compute_gonality(g, max_d=6, verbose=false) == 6

        # After we subdivide it, the gonality becomes 5!
        g = subdivide(g, 2)
        @test compute_gonality(g, max_d=5, verbose=false) == 5
    end

    @testset "Bug Graph" begin
        num_vertices = 7
        edge_list = [(1,2),(1,2),(2,3),(2,4),(2,4),(2,5),(3,4),(3,4),(4,5),(4,5),(5,7),(5,7),(3,6),(3,6),(6,7)]
        g = ChipFiringGraph(num_vertices,edge_list)
        @test compute_gonality(g, max_d=6, verbose=false) == 6  
        
        s2 = subdivide(g,2)
        @test compute_gonality(s2, max_d=5, verbose=false) == 5

    end

    @testset "Ralph's Genus 8" begin
        num_vertices = 19
        edge_list = [(1,2),(1,15),(1,3),(2,4),(2,10),(3,5),(3,4),(4,5),(5,18),(6,7),(6,8),(6,16),(7,10),(7,8),(8,9),(9,10),(11,12),(11,13),(11,19),(12,13),(12,15),(13,14),(14,15),(9,14),(16,17),(17,18),(17,19)]
        g = ChipFiringGraph(num_vertices,edge_list)
        @test compute_gonality(g, max_d=6, verbose=false) == 5

        s2 = subdivide(g,2)
        @test compute_gonality(s2, max_d=5, verbose=false) == 4
    end

    @testset "Ralph's Tricycleish 5 to 4" begin
        num_vertices = 7
        edge_list = [(1,2), (1,6), (1,6), (1,6), (1,7), (2,3), (2,3), (2,3), (3,4), (3,7), (4,5), (4,5), (4,5), (5,6), (5,7)]
        g = ChipFiringGraph(num_vertices, edge_list)

        @test compute_gonality(g, max_d=6, verbose=false) == 5

        s2 = subdivide(g,2)
        @test compute_gonality(s2, max_d=5, verbose=false) == 4
    end 
end

# The following test suites atims to test concentrated gonality.
@testset "concentrated gonality" begin
    @testset "K_6 (cgon)" begin
        #  1 -- 2
        adj_matrix = [
            0 1 1 1 1 1;
            1 0 1 1 1 1;
            1 1 0 1 1 1;
            1 1 1 0 1 1;
            1 1 1 1 0 1;
            1 1 1 1 1 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g, r = 6, cgon = true, verbose = false, max_d=10) == 6
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
        @test compute_gonality(g, r = 6, cgon = true, verbose = false, max_d=10) == 9
    end
end