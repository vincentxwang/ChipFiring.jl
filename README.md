# ChipFiring.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://vincentxwang.github.io/ChipFiring.jl/dev/)

A highly-performant Julia package for calculating graph gonality. This is in development so expect things to change frequently.

# Basic Usage

```julia-repl
julia> multiplicity_matrix = [
    0 2 0 1;
    2 0 1 0;
    0 1 0 1;
    1 0 1 0   
]

julia> g = ChipFiringGraph(multiplicity_matrix)
Graph(V=4, E=5, Edges=[(1, 2), (1, 2), (1, 4), (2, 3), (3, 4)])

julia> compute_gonality(g)
2

julia> d = Divisor([1, 1, 1, 1])
Divisor([1, 1, 1, 1])

julia> q_reduced(g, d, 1)
Divisor([-4, 1, 1, 0])
```