# Some notes. 

# This is a basic script for testing a list of graphs without doing anything fancy.

# Modification: we test 1st gonality AND 2nd gonality savings.

# LOVE http://combos.org/nauty. generates all graphs. 


SUBDIVISIONS = 2


include("../ChipFiring/src/ChipFiring.jl")

function save_gon(g::ChipFiringGraph, r)
    gon1 = compute_gonality(g, r=r)
    gon2 = compute_gonality(subdivide(g, SUBDIVISIONS), max_d = (gon1 - 1), r=r)
    return gon1, gon2
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


###### START SCRIPT #######

function main()
    input_filename = "vincent/genus_8_trivalent.txt"
    output_filename = "vincent/genus_8_trivalent.out"

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

                    println("Checking graph #$i.")


                    # 3. Run the computation for the current graph.
                    a, b = save_gon(g, 1)
                    c, d = save_gon(g, 2)
                    # e, f = save_gon(g, 3)

                    if b != -1
                        write(outfile, "FIRST GONALITY SAVINGS! $a -> $b\n")
                        println("FIRST GONALITY SAVINGS")
                        write(outfile, "$(sprint_graph(g))\n")
                    end

                    if d != -1
                        write(outfile, "SECOND GONALITY SAVINGS, $c -> $d\n")
                        println("SECOND GONALITY SAVINGS")
                        write(outfile, "$(sprint_graph(g))\n")
                    end

                    # if f != -1
                    #     write(outfile, "THIRD GONALITY SAVINGS, $e -> $f\n")
                    #     println("THIRD GONALITY SAVINGS")
                    #     write(outfile, "$(sprint_graph(g))\n")
                    # end



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