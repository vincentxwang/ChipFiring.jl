# Background and conventions

# Graphs and divisors

We take a graph to be with multi-edges, connected, and no self-loops. We label the vertices $\{1, \dots, n\}$. The valence of a vertex $v$ is the number of edges incident to $v$.

A `ChipFiringGraph` encodes the graph structure. It can be constructed through either a multiplicity matrix or an edge list.

For example:

```julia-repl
julia> multiplicity_matrix = [
    0 2 0 1;
    2 0 1 0;
    0 1 0 1;
    1 0 1 0   
]
[output omitted]

julia> edge_list = [(1,2), (1,2), (1,4), (2,3), (3,4)]
[output omitted]

# Constructor: multiplicity matrix
julia> g = ChipFiringGraph(multiplicity_matrix)
Graph(V=4, E=5, Edges=[(1, 2), (1, 2), (1, 4), (2, 3), (3, 4)])

# Constructor: number of vertices and edge list
julia> g = ChipFiringGraph(4, edge_list)
```

The `ChipFiringGraph` implements `AbstractGraph` from [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl). 

A `Divisor` encodes a divisor on a graph. However, it is a distinct object from a `ChipFiringGraph`  and for all practical purposes, it will act like a vector, where the $i$-th index corresponds to the number of chips on vertex $i$.

```julia-repl
julia> d = Divisor([1, 2, 3, -1])
4-element Divisor:
  1
  2
  3
 -1
```