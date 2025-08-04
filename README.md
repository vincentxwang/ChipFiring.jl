# ChipFiring.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://vincentxwang.github.io/BernsteinBasis.jl/dev/)

A highly-performant Julia package for calculating graph gonality. This is in development so expect things to change frequently.

# Basic Usage

```julia-repl
julia> tet_adj_matrix =[
    0 1 1 1
    1 0 1 1;
    1 1 0 1;
    1 1 1 0;
]

julia> g = ChipFiringGraph(tet_adj_matrix)
Graph(V=4, E=6, Edges=[(1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)])

julia> compute_gonality(g)
3
```
