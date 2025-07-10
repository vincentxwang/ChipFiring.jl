using Plots

function plot_cgon_sequence(g::ChipFiringGraph, maxd::Int, maxr::Int)
    r_values = 1:maxr
    
    cgon_values = [compute_gonality(g, r = rval, cgon = true, verbose = false, max_d=maxd) for rval in r_values]

    scatter(r_values, cgon_values, grid = true,
    xlabel = "r",
    ylabel = "cgon_r",
    title = "Scatter Plot of Function Output",
    legend = false,
    markerstrokewidth = 0.5,
    markersize = 6,
    color = :blue
)
end


function plot_gon_sequence(g::ChipFiringGraph, maxd::Int, maxr::Int)
    r_values = 1:maxr
    gon_values = [compute_gonality(g, r = rval, verbose = false, max_d = maxd) for rval in r_values]
    genus = g.num_edges - g.num_vertices + 1

    scatter(r_values, gon_values,
    xlabel = "r",
    ylabel = "gon_r",
    title = "Scatter Plot of Function Output",
    legend = false,
    markerstrokewidth = 0.5,
    markersize = 6,
    color = :red,
    )
    vline!([genus])
end

function plot_both(g::ChipFiringGraph, max::Int, highR::Int)
    r_values = 1:highR
    cgon_values = [compute_gonality(g, r = rval, cgon = true, verbose = false, max_d=max) for rval in r_values]
    gon_values = [compute_gonality(g, r = rval, verbose = false, max_d = max) for rval in r_values]
    genus = g.num_edges - g.num_vertices + 1
    scatter(r_values, cgon_values, grid = true, xticks=0:highR, yticks=0:max,
    xlabel = "r",
    ylabel = "cgon_r",
    title = "Scatter Plot of Function Output",
    legend = false,
    markerstrokewidth = 0.5,
    markersize = 6,
    color = :blue
    )

    
    scatter!(r_values, gon_values, grid = true,
    xlabel = "r", 
    ylabel = "gon_r",
    title = "Scatter Plot of Function Output",
    legend = false,
    markerstrokewidth = 0.5,
    markersize = 4,
    color = :red
    )
    vline!([genus])
    vline!()
end