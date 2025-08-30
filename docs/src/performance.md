# Performance tips

[ChipFiring.jl](https://github.com/vincentxwang/ChipFiring.jl) is a package intended for performance-sensitive applications. Below are some tips on using the package if users are interested in performance.

# Workspace

A key design pattern in this package is the `Workspace` environment, a structure that pre-allocates memory for divisors and vertex sets. Most users won't need to interact with this directly, as all functions that use a `Workspace` also have a convenient wrapper function. However, for performance-critical applications involving many calls to low-level operations (e.g., `dhar`, `q_reduced`), you should use the `Workspace` counterparts (e.g., `dhar!` and `q_reduced!`). Typically, just passing any `Workspace` will work, but there are some instances where a certain field of a `Workspace` is read as input to a function.

# Multi-threading

If you're processing many graphs on a multi-core CPU, you can parallelize the work using Julia's `@threads` macro. For gonality computations, the workloads tend to be very unbalanced, so it's best to use the `:greedy` scheduler to prevent threads from remaining idle. This option is available in Julia v1.11+. An example is below:

```julia
@threads :greedy for i in 1:num_graphs
        println(compute_gonality(graphs_to_process[i]))
end
```

Crucially, you *cannot* share a single `Workspace` between multiple threads.
