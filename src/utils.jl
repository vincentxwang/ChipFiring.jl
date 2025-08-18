"""
    subdivide(G::ChipFiringGraph, k::Int) -> ChipFiringGraph

Given a ChipFiringGraph ``G```, produces another ChipFiringGraph which is an ``k``-uniform subdivision of ``G``.

# Arguments
- `g::ChipFiringGraph`: The original graph
- `k::Int`: Number of uniform subdivisions (e.g., `1` returns original graph, `2` produces ``2``-uniform subdivision)

# Returns 
- A ``k``-uniform subdivided ChipFiringGraph
"""
function subdivide(g::ChipFiringGraph, subdivisions::Int)
    # if no subdivisions 
    if subdivisions <= 1
        return g
    end

    n = g.num_vertices
    m = g.num_edges

    N = n + (subdivisions-1)*m # new number of edges

    edge_list = g.edge_list
    new_edge_list = Vector{Tuple{Int, Int}}()

    new_vertex = n+1 # label for new vertex
    for (u,v) in edge_list
       # if more than 2, need to add more nodes and edges
        push!(new_edge_list, (u, new_vertex)) # add vertex from source
        # basically make a chain 
        for i in 1:(subdivisions-2) # loop won't run if subdivisions = 2, so just add 1 edge
            push!(new_edge_list, (new_vertex, new_vertex+1))
            new_vertex +=1
        end
        push!(new_edge_list, (new_vertex, v))
        new_vertex += 1
    end
    # total vertices is now n + (subdivisions-1)*m
    new_G = ChipFiringGraph(N, new_edge_list)
    return new_G
end

const _GRAPH6_OFFSET = 63
const _GRAPH6_BITS_PER_CHUNK = 6

"""
    parse_graph6(g6_string::String) -> ChipFiringGraph

Parses a graph from a string in the `graph6` format and returns a `ChipFiringGraph`.

This function fully implements the `graph6` specification for simple, undirected
graphs, including the 1, 4, and 8-byte encodings for the number of vertices.

# Arguments
- `g6_string::String`: The string representing the graph. An optional header
  `>>graph6<<` is ignored if present.

# Returns
- A `ChipFiringGraph` object.

# Throws
- `ArgumentError`: If the string is malformed, contains invalid characters, or
  ends unexpectedly.
"""
function parse_graph6(g6_string::String)
    # step 1: sanitization and validation
    s = startswith(g6_string, ">>graph6<<") ? g6_string[11:end] : g6_string
    bytes = Vector{UInt8}(s)

    # ASCII character validation
    if !all(b -> _GRAPH6_OFFSET <= b <= 126, bytes)
        throw(ArgumentError("Invalid character in graph6 string. Bytes must be in range 63-126."))
    end
    
    isempty(bytes) && return ChipFiringGraph(0, []) # empty graph case

    # step 2. find # of vertices
    cursor = 1
    
    function read_byte()
        cursor > length(bytes) && throw(ArgumentError("Invalid graph6 string: unexpected end of data."))
        val = bytes[cursor]
        cursor += 1
        return val
    end

    n::Int = 0
    b1 = read_byte()

    if b1 != 126 # N(n) is 1 byte for n <= 62
        n = b1 - _GRAPH6_OFFSET
    else # N(n) starts with 126
        b2 = read_byte()
        if b2 != 126 # N(n) is 4 bytes
            b3 = read_byte()
            b4 = read_byte()
            n = ((Int(b2) - _GRAPH6_OFFSET) << 12) + 
                ((Int(b3) - _GRAPH6_OFFSET) << 6) + 
                (Int(b4) - _GRAPH6_OFFSET)
        else # N(n) is 8 bytes for very large n
            vals = [Int(read_byte() - _GRAPH6_OFFSET) for _ in 1:6]
            n = (vals[1] << 30) + (vals[2] << 24) + (vals[3] << 18) +
                (vals[4] << 12) + (vals[5] << 6) + vals[6]
        end
    end

    # step 3: find edge_data
    edge_list = Tuple{Int, Int}[]
    chunk = 0x00
    bits_in_chunk = 0

    # Iterate through the upper triangle of the adjacency matrix
    for j in 1:(n - 1)
        for i in 0:(j - 1)
            # If our current 6-bit chunk is empty, load the next byte
            if bits_in_chunk == 0
                cursor > length(bytes) && break
                chunk = read_byte() - _GRAPH6_OFFSET
                bits_in_chunk = _GRAPH6_BITS_PER_CHUNK
            end

            # Check the most significant bit of the chunk to see if an edge exists
            if (chunk >> (_GRAPH6_BITS_PER_CHUNK - 1)) & 1 == 1
                # Convert 0-based spec indices to 1-based graph indices
                push!(edge_list, (i + 1, j + 1))
            end

            # We've consumed one bit, so left-shift the chunk to expose the next one
            chunk <<= 1
            bits_in_chunk -= 1
        end
    end

    return ChipFiringGraph(n, edge_list)
end