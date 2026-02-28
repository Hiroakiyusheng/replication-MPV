include("base.jl")

# deprecated due to slower run time
# function get_index_map(float,array)
#     out = (sum(x -> x < float, array) + 1)
#     return out
# end
#
# function map_a2(float)
#     a_val = get_index_map(float,cum_a_weights)
#     return a_val
# end


# get the a index from a random number
function map_a(float)::Int
    a_val = (sum(x -> x <= float, cum_a_weights) + 1)
    return a_val
end


# get the u index from a random number
function map_u(float,current_u_ind)::Int
    cum_u_weights = cum_u_transition[:,current_u_ind]
    u_val = (sum(x -> x < float, cum_u_weights) + 1)
    return u_val
end

function next_u(float1,float2,current_u_ind)
    if float1 > P_zeta
        return current_u_ind
    else
        out = map_u(float2,current_u_ind)
        return out
    end
end


function delta_grid_map(val,delta_grid)
    # println(delta_grid)
    # println(val)
    find_dist = x -> abs(x - val)
    dists = @. find_dist(delta_grid)
    delta_index = argmin(dists)
    return delta_index
end

# # linear weights
# function perceived_delta(delta_array,work_array,i,true_delta)
#     # generate linear weights
#     weights = Array(1:(i-1))
#     # now weight top
#     weighted_numerator = @. weights * delta_array[1:(i-1)]
#     weighted_denominator = @. weights * work_array[1:(i-1)]
#     # now sum components and divide
#     perceived_experience_delta = sum(weighted_numerator) / sum(weighted_denominator)
#     preceived_delta = .5 * delta + .5 * perceived_experience_delta
#     return val
# end

# equal weights
function perceived_delta(delta_array,work_array,i,true_delta;lambda=3)
    if i < 3
        return true_delta
    end
    # generate unit weights
    weights = Array(1:(i-2))
    weights = @. weights ^ lambda
    # now weight top
    weighted_numerator = @. weights * delta_array[1:(i-2)]
    weighted_denominator = @. weights * work_array[1:(i-2)]
    # now sum components and divide
    per_experience_delta = sum(weighted_numerator) / sum(weighted_denominator)
    per_delta = per_experience_delta
    return per_delta
end

function next_delta_map(delta_array,work_array,i,delta,delta_grid)
    val = perceived_delta(delta_array,work_array,i,delta)
    delta_index = delta_grid_map(val,delta_grid)
    return delta_index
end


function get_p_delta_path(delta_array,work_array,true_delta;last_period=200)

    out_array = Array{Float64,1}(undef,last_period)
    @. out_array[1:2] = delta
    for i = 3:last_period
        if sum(work_array[1:(i-2)]) < .5
            out_array[i] = delta
        else
            out_array[i] = perceived_delta(delta_array[1:i],work_array[1:i],i,true_delta)
        end
    end
    if sum(@. isnan(out_array)) > 0
        println(delta_array)
        println(work_array)
        println(out_array)
        for i = 2:last_period
            println("period ", i)
            println(sum(work_array[1:(i-1)]))
            if sum(work_array[1:(i-1)]) < .5
                out_array[i] = delta
            else
                out_array[i] = perceived_delta(delta_array[1:i],work_array[1:i],i,true_delta)
            end
            print(out_array[i])
        end
        error("nan delta val")
    end
return out_array
end
