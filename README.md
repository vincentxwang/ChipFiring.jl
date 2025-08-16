# ChipFiring.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://vincentxwang.github.io/ChipFiring.jl/dev/)
[![codecov](https://codecov.io/gh/vincentxwang/ChipFiring.jl/graph/badge.svg?token=TKJBAIMQ6D)](https://codecov.io/gh/vincentxwang/ChipFiring.jl)

[ChipFiring.jl](https://github.com/vincentxwang/ChipFiring.jl) is a Julia package for analyzing chip-firing games on graphs. The codes are roughly based on the algorithms given in *Sandpiles and Divisors: An Introduction to Chip-Firing* by Corry and Perkinson (2018). A key objective is for the package to be useful for both researchers and students. The package is built around a two-tier API design: a simple layer for interactive use, and a high-performance layer for intensive computations. Its features include:

- Basic operations on chip-firing graphs (e.g. firing, lending)
- Computations of $r$-th graph gonality
- Uniform subdivisions of graphs
- Rank computations
- q-reduction, Dhar's burning algorithm, and equivalence
- Conversion from graph6 format

# Installation

This package is on the official Julia registry and can be installed via `Pkg.add(ChipFiring)`. For more details, see the documentation [here](https://vincentxwang.github.io/ChipFiring.jl/dev/).

# Basic Usage

```julia-repl
julia> multiplicity_matrix = [
    0 2 0 1;
    2 0 1 0;
    0 1 0 1;
    1 0 1 0   
]
[output omitted]

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

This package was developed during the SMALL 2025 REU hosted at Williams College, funded by NSF Grant DMS2241623. Special thanks to [Charlotte Chen](https://github.com/cjc-11), [Benham Cobb](https://github.com/BenhamCobb), [Ralph Morrison](https://sites.williams.edu/10rem/), [Noam Pasman](https://github.com/NoamPasman), [Madeline Reeve](https://github.com/maddie2003), for contributing code and/or feedback.