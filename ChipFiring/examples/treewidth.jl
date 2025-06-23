using TreeWidthSolver
using Graphs

g = cycle_graph(6)
add_vertex!(g)
add_edge!(g, 2, 7)
add_edge!(g, 4, 7)
add_edge!(g, 6, 7)

exact_treewidth(g)

plot(g)



##### pinwheel but 

tricycle_adj_matrix =[
    0 1 1 1 1 1 1;
    1 0 1 0 0 0 1;
    1 1 0 1 0 0 0;
    1 0 1 0 1 0 0;
    1 0 0 1 0 1 0;
    1 0 0 0 1 0 1;
    1 1 0 0 0 1 0;
]