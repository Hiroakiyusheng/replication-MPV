# Setup parallel computing
using Distributed
@everywhere using SharedArrays
@everywhere using Distributions
@everywhere using LinearAlgebra

# This script defines functions to create disctete probability distros

function get_middle(n)
    # find middle of odd number n
    if (n % 2) != 1
        error("n should be odd")
    end
    x =  n - 1
    x = x / 2
    x = x + 1
    return Int(x)
end

function discretize_norm_dist(mu,sigma;sigma_count=3,bins=21)
# Inputs:
# mu: float, mean of normal dist
# sigma: float, std dev of normal dist
# sigma_count: int, number of sigmas to go out from mean
# bins: bins, number of bins to use
    # Ensure even number of bins
    if (bins % 2) != 1
        println("The number of bins should be odd for best results.")
        bins = bins + 1
        println("Now using ", bins," bins")
    end
    # set up dist
    dist = Normal(mu,sigma)

    # Get min and max grid values
    range_min = mu - sigma * sigma_count
    range_max = mu + sigma * sigma_count

    # set up outputs
    grid = Array(range(range_min, stop=range_max, length=bins))
    weights = SharedArray{Float64}(bins)

    #handle the first bin
    cutoff = mean([grid[1] grid[2]])

    weights[1] = cdf(dist, cutoff)

    @sync @distributed for i = 2:(bins - 1)
        cutoff_low = mean([grid[i-1] grid[i]])
        cutoff_high = mean([grid[i] grid[i+1]])

        weights[i] = cdf(dist, cutoff_high) - cdf(dist, cutoff_low)
    end
    # handle last bins
    # Solve by default
    # weights[bins] = 0
    # weights[bins] = 1 - sum(weights)
    # solve by cdf
    cutoff = mean([grid[bins-1] grid[bins]])
    weights[bins] = 1 - cdf(dist, cutoff)

    return grid, weights
end

function discretize_norm_dist_force_grid(mu,sigma,grid)
# Inputs:
# mu: float, mean of normal dist
# grid: array, forced as grid
    # set up dist
    dist = Normal(mu,sigma)

    # Get bin count
    bins = size(grid,1)

    # Create array for weights
    weights = SharedArray{Float64}(bins)

    #handle the first bin
    cutoff = mean([grid[1] grid[2]])

    weights[1] = cdf(dist, cutoff)

    @sync @distributed for i = 2:(bins - 1)
        cutoff_low = mean([grid[i-1] grid[i]])
        cutoff_high = mean([grid[i] grid[i+1]])

        weights[i] = cdf(dist, cutoff_high) - cdf(dist, cutoff_low)
    end
    # handle last bins
    # Solve by default
    # weights[bins] = 0
    # weights[bins] = 1 - sum(weights)
    # solve by cdf
    cutoff = mean([grid[bins-1] grid[bins]])
    weights[bins] = 1 - cdf(dist, cutoff)

    return weights
end

function discretize_norm_random_walk(mu,sigma;sigma_count=3,bins=21)
    # Inputs:
    # mu: float, mean of normal dist
    # sigma: float, std dev of normal dist
    # sigma_count: int, number of sigmas to go out from mean
    # bins: bins, number of bins to use

    if (bins % 2) != 1
        println("The number of bins should be odd for best results.")
        bins = bins + 1
        println("Now using ", bins," bins")
    end

    grid, weights = discretize_norm_dist(mu,sigma;sigma_count=sigma_count,bins=bins)

    transition_probs = SharedArray{Float64}(bins,bins)

    middle_pt = get_middle(bins)
    even_side_count = middle_pt - 1

    # Set middle to array
    for i = 1:bins
        transition_probs[i,middle_pt] = weights[i]
    end

    for i = 1:even_side_count
        cur_mu = grid[i]

        cur_weights = discretize_norm_dist_force_grid(cur_mu,sigma,grid)

        transition_probs[:,i] = cur_weights

        rev_cur_weights = reverse(cur_weights)

        transition_probs[:,(bins + 1) - i] = rev_cur_weights

    end

    return Array(grid), Array(transition_probs)
end

function gen_logspace(min_val,max_val,points)
    logmin = log(min_val)
    logmax = log(max_val)

    pre_space = range(logmin, stop=logmax, length=points)
    a_pre_space = Array(pre_space)

    e = exp(1)

    space = @. e ^ (a_pre_space)

    return space
end

function get_max_grid_space(grid)

    big = grid[2:end]
    little = grid[1:(end-1)]

    differences = @. big - little

    max_dif = maximum(differences)

    return max_dif
end

function gen_logspace_w_max_min_space(min_val,max_val,min_space;start_points::Int64=10,time_out::Int64=1000)
    cur_points = start_points

    cur_space = min_space + 1

    cur_grid = 0

    repeat = true

    while cur_space >= min_space
        cur_grid = gen_logspace(min_val, max_val, cur_points)

        cur_space = get_max_grid_space(cur_grid)

        cur_points = cur_points + 1
        if cur_points > time_out
            msg = string("time out, exceeded ",time_out," points")
            error(msg)
        end
    end
    return cur_grid
end
