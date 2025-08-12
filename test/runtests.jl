using Test

@testset "All" begin
    include("core_tests.jl");
    include("gonality_tests.jl")
    include("graph6_tests.jl")
end