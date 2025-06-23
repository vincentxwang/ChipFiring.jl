using TreeWidthSolver
using Graphs

g = cycle_graph(6)
add_vertex!(g)
add_edge!(g, 2, 7)
add_edge!(g, 4, 7)
add_edge!(g, 6, 7)

exact_treewidth(g)

plot(g)