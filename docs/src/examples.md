# Examples

Below are some self-contained examples of the code in [ChipFiring.jl](https://github.com/vincentxwang/ChipFiring.jl).


# 1 Graph construction

```julia
using ChipFiring
# Construction of a house graph with an extra edge
#
#      (5)
#     /   \
#    /     \
#  (3)-----(4)
#   |       |
#   |       |
#  (1)=====(2)
#
multiplicity_matrix = [
    0 2 1 0 0;
    2 0 0 1 0;
    1 0 0 1 1;
    0 1 1 0 1;
    0 0 1 1 0
]

# Construction of a `ChipFiringGraph` via multiplicity matrix
g1 = ChipFiringGraph(multiplicity_matrix)

num_vertices = 5
edge_list = [(1, 2), (1, 2), (1, 3), (2, 4), (3, 4), (3, 5), (4, 5)]

# Construction of a `ChipFiringGraph` via edge list
g2 = ChipFiringGraph(num_vertices, edge_list)
```

# 2 Compute graph gonality

```julia
using ChipFiring

icosahedron_adj_matrix =[
    0 1 1 1 1 0 0 0 1 0 0 0;
    1 0 1 0 1 1 1 0 0 0 0 0;
    1 1 0 0 0 0 1 1 1 0 0 0;
    1 0 0 0 1 0 0 0 1 1 1 0;
    1 1 0 1 0 1 0 0 0 1 0 0;
    0 1 0 0 1 0 1 0 0 1 0 1;
    0 1 1 0 0 1 0 1 0 0 0 1;
    0 0 1 0 0 0 1 0 1 0 1 1;
    1 0 1 1 0 0 0 1 0 0 1 0;
    0 0 0 1 1 1 0 0 0 0 1 1;
    0 0 0 1 0 0 0 1 1 1 0 1;
    0 0 0 0 0 1 1 1 0 1 1 0
]

g = ChipFiringGraph(icosahedron_adj_matrix)

# Compute the gonality of an icosahedron to be 9
compute_gonality(g)

# We can also specify ranks for `compute_gonality` to compute
compute_gonality(g, min_d=7, max_d=10)

# If the function finds that the gonality is greater than `max_d`, then it will return `-1`
compute_gonality(g, min_d=6, max_d=8)

# Verbose mode that prints a winning divisor.
compute_gonality(g, verbose=true)

```

# 3 Uniform subdivision of graphs

```julia
using ChipFiring

tricycle_mult_matrix =[
    0 1 1 1 1 1 1;
    1 0 1 0 0 0 2;
    1 1 0 2 0 0 0;
    1 0 2 0 1 0 0;
    1 0 0 1 0 2 0;
    1 0 0 0 2 0 1;
    1 2 0 0 0 1 0;
]

g = ChipFiringGraph(tricycle_mult_matrix)

# The gonality of the tricycle graph is 6 (https://arxiv.org/pdf/2106.12568)
compute_gonality(g)

# Create a 2-uniform subdivision of the tricycle graph
g_subdivided = subdivide(g, 2)

# The gonality of the subdivided tricycle graph is 5
compute_gonality(g_subdivided)
```


