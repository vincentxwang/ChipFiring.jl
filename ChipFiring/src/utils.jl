"""

generate_effective_divisors(num_vertices, degree) -> Vector{Divisor}


Generates all effective divisors (chip configurations with non-negative chips)
of a given total degree.

"""
function generate_effective_divisors(num_vertices, degree)
    return Divisor.(collect(multiexponents(num_vertices, convert(Int64, degree))))
end 

"""
    has_rank_at_least_one(g::ChipFiringGraph, d::Divisor) -> Bool

Internal helper for `compute_gonality`. Checks if a divisor `D` has rank at least 1.
"""
function has_rank_at_least_one(g::ChipFiringGraph, d::Divisor)
    for v in 1:g.num_vertices
        d.chips[v] -= 1
        if !is_winnable(g, d)
            return false
        end
        d.chips[v] += 1
    end
    return true
end