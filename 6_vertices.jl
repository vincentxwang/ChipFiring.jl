# Some notes.

# LOVE http://combos.org/nauty. generates all graphs. 

include("ChipFiring/src/ChipFiring.jl")

function save_gon(g::ChipFiringGraph)
    gon1 = compute_gonality(g)
    gon2 = compute_gonality(subdivide(g, 3), max_d= gon1 - 1)
    return gon1, gon2
    # end
    return -1, -1
end


"""
    parse_graph_line(line::String) -> ChipFiringGraph

Parses a single line from the input file into a `ChipFiringGraph` object.
The line format is expected to be: `ID: v1,v2; v3,v4; ...`
"""
function parse_graph_line(line::String)
    # Split the line into the ID and the edge data string
    # e.g., "1: 1,4; 2,4; 3,4" -> " 1,4; 2,4; 3,4"
    _, edge_data_str = split(line, ':')

    # Split the edge data string into individual edge strings
    # e.g., " 1,4; 2,4; 3,4" -> [" 1,4", " 2,4", " 3,4"]
    edge_strs = split(strip(edge_data_str), ';')

    edge_list = Tuple{Int, Int}[]
    max_vertex = 0

    for es in edge_strs
        # Skip if the string is empty after trimming
        clean_es = strip(es)
        if isempty(clean_es) continue end

        # Parse the two vertices from the edge string
        vertex_strs = split(clean_es, ',')
        v1 = parse(Int, vertex_strs[1])
        v2 = parse(Int, vertex_strs[2])

        push!(edge_list, (v1, v2))

        # Track the largest vertex index to determine the number of vertices
        max_vertex = max(max_vertex, v1, v2)
    end

    num_vertices = max_vertex
    # Use the constructor that takes the number of vertices and the edge list
    return ChipFiringGraph(num_vertices, edge_list)
end


function process_multigraph_expansions(simple_graph::ChipFiringGraph, max_multiplicity::Int)
    n = simple_graph.num_vertices
    unique_edges = collect(Set(simple_graph.edge_list))
    num_unique_edges = length(unique_edges)
    results = Tuple{Int, Int}[]
    results_string = String[]

    println("Starting multigraph expansion for a graph with $n vertices and $num_unique_edges unique edges.")
    println("Expanding each edge with multiplicity up to $max_multiplicity.")
    println("This will generate up to $(((max_multiplicity)^num_unique_edges)) multigraphs.")

    # A recursive helper to generate all combinations of multiplicities
    function generate_and_check(edge_idx::Int, current_multiedge_list::Vector{Tuple{Int, Int}})
        # Base case: if we have assigned a multiplicity to every unique edge
        if edge_idx > num_unique_edges
            # We have a complete multigraph, process it
            # Skip if the edge list is empty
            if !isempty(current_multiedge_list)
                multigraph = ChipFiringGraph(n, current_multiedge_list)
                gon1, gon2 = save_gon(multigraph)
                if gon2 != -1
                    println("Saved from $(gon1) to $(gon2)!")
                    println(sprint_graph(multigraph))
                    push!(results, (gon1, gon2))
                    push!(results_string, sprint_graph(multigraph))
                end
            end
            return
        end

        # Recursive step: iterate through all possible multiplicities for the current edge
        current_edge = unique_edges[edge_idx]
        for multiplicity in 1:max_multiplicity
            # Add the current edge 'multiplicity' times
            for _ in 1:multiplicity
                push!(current_multiedge_list, current_edge)
            end
            
            # Recurse to the next edge type
            generate_and_check(edge_idx + 1, current_multiedge_list)
            
            # Backtrack: remove the edges added at this level to prepare for the next multiplicity
            for _ in 1:multiplicity
                pop!(current_multiedge_list)
            end
        end
    end

    # Start the recursion with the first edge and an empty list of edges
    generate_and_check(1, Tuple{Int, Int}[])
    println("Finished multigraph expansion.")
    return results, results_string
end

###### START SCRIPT #######

function main()
    input_filename = "pinwheel.txt"
    output_filename = "pinwheel.out"

    if !isfile(input_filename)
        println("Error: File '$input_filename' not found.")
        # Create a dummy file for demonstration purposes
        println("Creating a dummy '4.txt' to run the script.")
        open(input_filename, "w") do f
            write(f, "1: 1,4; 2,4; 3,4\n")
            write(f, "2: 1,3; 1,4; 2,4\n")
            write(f, "3: 1,3; 1,4; 2,4; 3,4\n")
            write(f, "4: 1,3; 1,4; 2,3; 2,4\n")
            write(f, "5: 1,3; 1,4; 2,3; 2,4; 3,4\n")
            write(f, "6: 1,2; 1,3; 1,4; 2,3; 2,4; 3,4\n")
        end
    end

    processed_count = 0
    # Open the output file for writing
    open(output_filename, "w") do outfile
        # Open the input file for reading
        open(input_filename) do infile
            println("Processing graphs from '$input_filename' and writing results to '$output_filename'...")
            write(outfile, "Graph Gonality Analysis Results\n")
            write(outfile, "================================\n\n")

            # --- Process file line-by-line using a while loop to avoid the scoping issue ---
            for (i, line) in enumerate(eachline(infile))
                try
                    # 1. Parse the current line into a graph object.
                    g = parse_graph_line(line)
                    
                    # 2. Process the single graph and write its output immediately.
                    write(outfile, "Graph #$i:\n")
                    write(outfile, "  - Vertices: $(g.num_vertices), Edges: $(g.num_edges)\n")
                    write(outfile, "  - Degree List: $(g.degree_list)\n")

                    # 3. Run the computation for the current graph.
                    results, results_string = process_multigraph_expansions(g, 2)


                    write(outfile, "  - Result of results(): $results\n")
                    write(outfile, "  - Associated graphs: $results_string\n")

                    write(outfile, "----------------------------------------\n")
                    
                    
                    # Increment the counter upon successful processing
                    global processed_count += 1
                catch e
                    println("Warning: Could not parse line $i: \"$line\". Error: $e")
                    # Optionally write an error to the output file as well
                    write(outfile, "Error processing Graph #$i. Invalid format.\n")
                    write(outfile, "----------------------------------------\n")
                end
            end
        end
    end
    
    # Need to declare processed_count as global to print it here
    global processed_count
    println("Successfully processed $processed_count graphs.")
    println("Done. Results have been saved to '$output_filename'.")
end

# Define processed_count as a global variable before main is called
processed_count = 0
# Run the script
main()