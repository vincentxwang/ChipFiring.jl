# Background and conventions

We take a graph to be with multi-edges, connected, and no self-loops. We label the vertices $\{1, \dots, n\}$. Throughout this package, 

Do note that `Divisors` should be explicitly constructed to the functions instead of passing a vector. For example, `has_rank_at_least_r(g, Divisor([1, 0, 1, 0, 0, 1, 0, 1]), 1)`.