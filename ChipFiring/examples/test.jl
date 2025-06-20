tricycle_adj_matrix =[
    0 2 2 0 1 0;
    2 0 2 1 2 0;
    2 2 0 0 0 0;
    0 1 0 0 2 2;
    1 2 0 2 0 2;
    0 0 0 2 2 0;    
]

g = ChipFiringGraph(tricycle_adj_matrix)

# The gonality of the tricycle graph is 6 (https://arxiv.org/pdf/2106.12568)
@test compute_gonality(g, max_d=9, verbose=true) == 6
