K = Dict(
    1 => [],
    2 => [(1, 2)],
    3 => [(1, 2), (1, 3), (2, 3)],
    4 => [(1, 2), (1, 3), (1, 4), (2, 3), (2, 4), (3, 4)],
    5 => [(1, 2), (1, 3), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5), (3, 4), (3, 5), (4, 5)],
    6 => [
        (1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
        (2, 3), (2, 4), (2, 5), (2, 6),
        (3, 4), (3, 5), (3, 6),
        (4, 5), (4, 6),
        (5, 6)
    ],
    7 => [
        (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7),
        (2, 3), (2, 4), (2, 5), (2, 6), (2, 7),
        (3, 4), (3, 5), (3, 6), (3, 7),
        (4, 5), (4, 6), (4, 7),
        (5, 6), (5, 7),
        (6, 7)
    ],
    8 => [
        (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8),
        (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8),
        (3, 4), (3, 5), (3, 6), (3, 7), (3, 8),
        (4, 5), (4, 6), (4, 7), (4, 8),
        (5, 6), (5, 7), (5, 8),
        (6, 7), (6, 8),
        (7, 8)
    ],
    9 => [
        (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9),
        (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9),
        (3, 4), (3, 5), (3, 6), (3, 7), (3, 8), (3, 9),
        (4, 5), (4, 6), (4, 7), (4, 8), (4, 9),
        (5, 6), (5, 7), (5, 8), (5, 9),
        (6, 7), (6, 8), (6, 9),
        (7, 8), (7, 9),
        (8, 9)
    ])

function degree_k_nonnegative_partitions(n::Int, k::Int)
    results = []
    function helper(current, i, remaining)
        if i == n + 1
            if remaining == 0
                push!(results, copy(current))
            end
            return
        end
        for val in 0:remaining
            current[i] = val
            helper(current, i + 1, remaining - val)
        end
    end
    helper(Vector{Int}(undef, n), 1, k)
    return results
end
function split_divisors_by_rank(n::Int, d::Int)
    divisors = degree_k_nonnegative_partitions(n, d)

    positive_rank = []
    zero_rank = []

    for D in divisors
        if has_positive_rank(D)
            push!(positive_rank, D)
        else
            push!(zero_rank, D)
        end
    end

    return positive_rank, zero_rank
end
function probability_positive_rank(n::Int, d::Int)
    divisors = degree_k_nonnegative_partitions(n, d)
    total = length(divisors)
    num_positive_rank = count(has_positive_rank, divisors)

    return num_positive_rank / total
end

function has_positive_rank(divisor::Vector{Int})
    n = length(divisor)
    sorted_div = sort(divisor, rev=true)

    for k in 1:(n - 1)  # exclude k = n
        num_at_least_k = count(x -> x ≥ k, sorted_div)
        if num_at_least_k ≥ n - k
            return true
            println("Found positive rank for k = $k: $num_at_least_k >= $(n - k)")
        end
    end
    return false
end

for i in 2:8
    g = ChipFiringGraph(i, K[i])
    gon = compute_gonality(g)
    genusPlusOne = g.num_edges - g.num_vertices + 2
    println("K$i(gon: $gon, g+1: $genusPlusOne)")
    len_zero_prob = Dict{Int, Float64}()
    expect = zeros(Float64, genusPlusOne - gon + 1)
    tracker = 0
    k = 1
    for j in gon:genusPlusOne
        len = length(degree_k_nonnegative_partitions(i, j))
        pos, zero = split_divisors_by_rank(i, j)
        len_pos = length(pos)
        len_zero = length(zero)
        println("degree: $j, total divisors: $len, winnable ones: $len_pos, zero-rank ones: $len_zero, prob: $(probability_positive_rank(i, j))")
        expect[k] = j * len_pos
        tracker += len_pos
        k += 1
    end
    println("Expected Degree Value: ", sum(expect)/tracker)
end
