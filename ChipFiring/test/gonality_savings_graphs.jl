# using ChipFiring
using Test

@testset "graphs that have gonality savings" begin
    @testset "Tricycle" begin 
        # Graph from the discrete/metric graph gonality can be different paper
        # 6 to 5

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

    @testset "Bug Graph" begin
        num_vertices = 7
        edge_list = [(1,2),(1,2),(2,3),(2,4),(2,4),(2,5),(3,4),(3,4),(4,5),(4,5),(5,7),(5,7),(3,6),(3,6),(6,7)]
        g = ChipFiringGraph(num_vertices,edge_list)
        @test compute_gonality(g, max_d=6, verbose=true) == 6  
        
        s2 = subdivide(g,2)
        @test compute_gonality(s2, max_d=5, verbose=true) == 5

    end

    @testset "Ralph's Genus 8" begin
        num_vertices = 19
        edge_list = [(1,2),(1,15),(1,3),(2,4),(2,10),(3,5),(3,4),(4,5),(5,18),(6,7),(6,8),(6,16),(7,10),(7,8),(8,9),(9,10),(11,12),(11,13),(11,19),(12,13),(12,15),(13,14),(14,15),(9,14),(16,17),(17,18),(17,19)]
        g = ChipFiringGraph(num_vertices,edge_list)
        @test compute_gonality(g, max_d=6, verbose=true) == 5

        s2 = subdivide(g,2)
        @test compute_gonality(s2, max_d=5, verbose=true) == 4
    end

    @testset "Ralph's Tricycleish 5 to 4"
        num_vertices = 7
        edge_list = [(1,2), (1,6), (1,6), (1,6), (1,7), (2,3), (2,3), (2,3), (3,4), (3,7), (4,5), (4,5), (4,5), (5,6), (5,7)]
        g = ChipFiringGraph(num_vertices, edge_list)

        @test compute_gonality(g, max_d=6, verbose=true) == 5

        s2 = subdivide(g,2)
        @test compute_gonality(s2, max_d=5, verbose=true) == 4
   
    end 

@testset "Misc Graphs" begin

    #Complete Graphs
    @testset "K_6" begin
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

        @test compute_gonality(g, r = 6, cgon = true, verbose = false, max_d=10) == 9
    end

    @testset "K_5" begin
        #  1 -- 2
        adj_matrix = [
            0 1 1 1 1;
            1 0 1 1 1;
            1 1 0 1 1;
            1 1 1 0 1;
            1 1 1 1 0
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g, r = 6, cgon = true, verbose = false, max_d=10) == 9
    end

    @testset "K_4" begin
        adj_matrix = [
            0 1 1 1;
            1 0 1 1;
            1 1 0 1;
            1 1 1 0
        ]
        g = ChipFiringGraph(adj_matrix)
    end

    @testset "K_3" begin
    #  1 -- 2
        adj_matrix = [
            0 1 1;
            1 0 1;
            1 1 0;
        ]
        g = ChipFiringGraph(adj_matrix)

        @test compute_gonality(g, r = 6, cgon = true, verbose = false, max_d=10) == 9
    end

    #Complete Bipartite Graphs
    @testset "K_2,3" begin
        adj_matrix = [
            0 0 1 1 1;
            0 0 1 1 1;
            1 1 0 0 0;
            1 1 0 0 0;
            1 1 0 0 0;
        ]
        g = ChipFiringGraph(adj_matrix);
    end

    @testset "K_3,3" begin
            adj_matrix = [
                0 0 0 1 1 1;
                0 0 0 1 1 1;
                0 0 0 1 1 1;
                1 1 1 0 0 0;
                1 1 1 0 0 0;
                1 1 1 0 0 0;
            ]
            g = ChipFiringGraph(adj_matrix);
        end

    @testset "K_3,4" begin
        adj_matrix = [
            0 0 0 0 1 1 1;
            0 0 0 0 1 1 1;
            0 0 0 0 1 1 1;
            0 0 0 0 1 1 1;
            1 1 1 1 0 0 0;
            1 1 1 1 0 0 0;
            1 1 1 1 0 0 0; 
        ]
        g = ChipFiringGraph(adj_matrix);
    end

    @testset "K_4,4" begin
        adj_matrix = [
            0 0 0 0 1 1 1 1;
            0 0 0 0 1 1 1 1;
            0 0 0 0 1 1 1 1;
            0 0 0 0 1 1 1 1;
            1 1 1 1 0 0 0 0;
            1 1 1 1 0 0 0 0;
            1 1 1 1 0 0 0 0; 
            1 1 1 1 0 0 0 0; 
        ]
        g = ChipFiringGraph(adj_matrix);
    end

    #Cycle graphs
    @testset "C4" begin
        adj_matrix = [
                    0 1 0 1;
                    1 0 1 0;
                    0 1 0 1;
                    1 0 1 0
        ]
        g = ChipFiringGraph(adj_matrix)
    end
    @testset "C5" begin
            adj_matrix = [
                        0 1 0 0 1;
                        1 0 1 0 0;
                        0 1 0 1 0;
                        0 0 1 0 1;
                        1 0 0 1 0;
            ]
            g = ChipFiringGraph(adj_matrix)
    end

    #Random Graphs
    @testset "House" begin
            adj_matrix = [
                        0 1 0 0 1;
                        1 0 1 0 1;
                        0 1 0 1 0;
                        0 0 1 0 1;
                        1 1 0 1 0;
            ]
            g = ChipFiringGraph(adj_matrix)
    end

    @testset "Shell-3" begin
            adj_matrix = [
                        0 1 0 0 1;
                        1 0 1 0 1;
                        0 1 0 1 1;
                        0 0 1 0 1;
                        1 1 1 1 0;
            ]
            g = ChipFiringGraph(adj_matrix)
    end
    @testset "Shell-4" begin
            adj_matrix = [
                        0 1 0 0 1 0;
                        1 0 1 0 1 0;
                        0 1 0 1 1 0;
                        0 0 1 0 1 1;
                        1 1 1 1 0 1;
                        0 0 0 1 1 0;
            ]
            g = ChipFiringGraph(adj_matrix)
    end

    @testset "Shell-5" begin
            adj_matrix = [
                        0 1 0 0 1 0 0;
                        1 0 1 0 1 0 0;
                        0 1 0 1 1 0 0;
                        0 0 1 0 1 1 0;
                        1 1 1 1 0 1 1;
                        0 0 0 1 1 0 1;
                        0 0 0 0 1 1 0;
            ]
            g = ChipFiringGraph(adj_matrix)
    end

end