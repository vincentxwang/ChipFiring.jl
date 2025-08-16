using Test
using ChipFiring

@testset "from_graph6" begin
    @testset "K_1" begin
        g = parse_graph6("@")
        @test g.num_vertices == 1
        @test g.num_edges == 0
    end

    @testset "K_4" begin
        g = parse_graph6("C~")
        @test g.num_vertices == 4
        @test g.num_edges == 6
        @test all(d == 3 for d in g.valency_list)
    end

    @testset "K_10" begin
        g = parse_graph6("I~~~~~~~w")
        @test g.num_vertices == 10
        @test g.num_edges == 45
        @test all(d == 9 for d in g.valency_list)
    end

    # The test cases below were taken from NetworkX tests
    @testset "K_6,9" begin
        g = parse_graph6("N??F~z{~Fw^_~?~?^_?")
        @test g.num_vertices == 15
        @test g.num_edges == 54
    end

    @testset "K_67" begin
        g = parse_graph6("~?@B" * "~"^368 * "w")
        @test g.num_vertices == 67
        @test g.num_edges == 2211
        @test all(d == 66 for d in g.valency_list)
    end
end