# ChipFiring.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://vincentxwang.github.io/ChipFiring.jl/dev/)

[This package](https://github.com/vincentxwang/ChipFiring.jl) contains routines to quickly calculate graph gonality of chip-firing graphs. The codes are roughly based on the algorithms given in *Sandpiles and Divisors: An Introduction to Chip-Firing* by Corry and Perkinson (2018).

# Contents

Currently, this package supports the following:

- Basic operations on chip-firing graphs (e.g. firing, lending)
- Computations of graph gonality
- Subdivisions of graphs
- Rank computations
- q-reduction and Dhar's burning algorithm

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

# Acknowledgements

This package was developed during the SMALL 2025 REU hosted at Williams College, funded by NSF Grant DMS2241623. Special thanks to Madeline Reeve and Charlotte Chen for contributing code.