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

function maxdim(g,d)
    return floor(g * (1 + 2/(d-1)) + 2*d - 1)
end

g = ChipFiringGraph(7, [
    (1 ,2) , 
    (1 ,6) , (1 ,6) , (1 ,6) , 
    (1 ,7) , 
    (2 ,3) , (2 ,3) , (2 ,3) , 
    (3 ,4) ,
    (3 ,7) , 
    (4 ,5) , (4 ,5) , (4 ,5) , 
    (5 ,6) ,(5 ,7),
    (1 ,2) , 
    (1 ,6) , (1 ,6) , (1 ,6) , 
    (1 ,7) , 
    (2 ,3) , (2 ,3) , (2 ,3) , 
    (3 ,4) ,
    (3 ,7) , 
    (4 ,5) , (4 ,5) , (4 ,5) , 
    (5 ,6) ,(5 ,7) 
])

compute_gonality(g, r=2)
compute_gonality(subdivide(g,2), r=2, verbose=true)