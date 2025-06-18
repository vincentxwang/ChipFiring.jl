push!(LOAD_PATH, "/Users/vincentwang/Documents/ChipFiring.jl")

using ChipFiring

println("--- Using the ChipFiring Package ---")

# 3. Create a graph
# A simple 4-vertex cycle graph
multiplicity_matrix = [
    0 1 0 1;
    1 0 1 0;
    0 1 0 1;
    1 0 1 0
]
initial_chips = [3, 1, 0, 0] # An unstable configuration

# The main constructor from your package
g = ChipFiringGraph(multiplicity_matrix, initial_chips)

println("\nInitial configuration:")
println("Chips: ", g.chips)

# 4. Call functions from the package
println("\nStabilizing the graph...")
stabilize!(g, verbose=false)

println("\nFinal stable configuration:")
println("Chips: ", g.chips)

# You can also compute properties like gonality
println("\nComputing gonality...")
gon = compute_gonality(g)
println("The gonality of this graph is: ", gon)