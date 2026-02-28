using LinearAlgebra
# @everywhere using Memoize

include("base.jl")


function weight_for_u_transition(potential_values,u_index,u_transition)
        potential_values_diff_u = potential_values * u_transition[:,u_index]
        potential_values_same_u = potential_values[:,u_index]

        weighted_potential_values_diff_u = @.  P_zeta * potential_values_diff_u

        no_shock_weight = (1- P_zeta)
        weighted_potential_values_same_u = @. no_shock_weight * potential_values_same_u

        potential_values_final = Array{Float64,1}(undef,size(potential_values,1))
        potential_values_final = @. weighted_potential_values_diff_u + weighted_potential_values_same_u

        return potential_values_final
end

function weight_for_u_transition_1d(potential_values,u_index,u_transition)
        potential_values_diff_u = potential_values * u_transition[:,u_index]
        potential_values_same_u = potential_values[u_index]

        weighted_potential_values_diff_u = P_zeta * potential_values_diff_u

        no_shock_weight = (1- P_zeta)
        weighted_potential_values_same_u = no_shock_weight * potential_values_same_u

        potential_values_final = weighted_potential_values_diff_u + weighted_potential_values_same_u

        return potential_values_final
end


function solve_basic(next_income,asset_index,value_array,asset_grid;working=0)

        # current_assets = 0.0
        current_assets = asset_grid[asset_index]::Float64

        # # Eliminate asset choices too low
        # below_min = @. (asset_grid < next_income)
        # # Note index of lowest next period asset choice
        # min_asset_choice = sum(below_min) + 1
        min_asset_choice = (sum(x -> x < next_income, asset_grid) + 1)

        # Find max asset choice for tomorrow
        # This is technically true but leads to additional computational complexity
        # max_asset = current_assets * R + next_income
        # We keep things much simpler by putting a slightly lower upper bound on their consumption
        # max_asset = current_assets + next_income
        # eliminate asset choices too high
        # Note that this also enforces consumtion > 0
        end_assets = @. asset_grid - next_income
        end_assets = @. end_assets / R
        above_max = @. (end_assets < current_assets)
        # Note index of highest choice
        max_asset_choice = sum(above_max)
        # Find discrete count of potential next asset choices
        potential_next_assets = asset_grid[min_asset_choice:max_asset_choice]
        # Now get consumptions choices
        potential_end_assets = end_assets[min_asset_choice:max_asset_choice]
        potential_cons_choices = @. current_assets - potential_end_assets
        # Then utilities
        # Note not working is assumed
        potential_utils = @. utility(potential_cons_choices,working)
        # now get potential value functions
        potential_vf = value_array[min_asset_choice:max_asset_choice]
        # discount the vf appropriately
        disc_potential_vf = @.(beta * potential_vf)
        # Now put together
        potential_options = @.(potential_utils + disc_potential_vf)
        # ensure potential options are expected shape
        # potential_options = reshape(potential_options,:,1)
        # # Now get the best choice
        # if sizeof(potential_options) == 0
        #         println(next_income)
        #         println(asset_index)
        #         println(current_assets)
        # end
        best = argmax(potential_options)
        best = best[1]

        # get values
        # actual_consumption = potential_cons_choices[best]
        # actual_next_asset = potential_next_assets[best]
        # actual_asset_index = (min_asset_choice + best - 1)
        # actual_value = potential_options[best]
        out_array = Array{Float64,1}(undef,4)
        out_array[1] = potential_options[best]
        out_array[2] = potential_cons_choices[best]
        out_array[3] = potential_next_assets[best]
        out_array[4] = (min_asset_choice + best - 1)

        # return actual_value, actual_consumption, actual_next_asset, actual_asset_index
        return out_array
end


function solve_employed(working_income,stop_working_income,asset_index,keep_working_values,stop_working_values,asset_grid)
    # create array of income options
    # subtract fixed cost of working
    adjusted_work_income = working_income - F

    cond = true
    cond = adjusted_work_income < 1
    if cond
     adjusted_work_income = 1
    end

    incomes = Array{Float64}(undef,2)
    incomes[1] = adjusted_work_income
    incomes[2] = stop_working_income

    solved_array = Array{Float64,2}(undef,2,4)

    for i = 1:2

        # get correct value array
        if i == 1
                @views value_array = keep_working_values
        else
                @views value_array = stop_working_values
        end

        # pull income
        next_income = incomes[i]
        # Eliminate asset choices too low
        # if i == 1
        #         # Make working
        #         # value, cons, next_asset, next_asset_ind = solve_basic(next_income,asset_index,value_array,asset_grid;working=1)
        #         solved_array[1,:] = solve_basic(next_income,asset_index,value_array,asset_grid)
        # else
        #         # value, cons, next_asset, next_asset_ind = solve_basic(next_income,asset_index,value_array,asset_grid)
        #         solved_array[2,:] = solve_basic(next_income,asset_index,value_array,asset_grid)
        # end
        if i == 1
                # account for working
                solved_array[i,:] = solve_basic(next_income,asset_index,value_array,asset_grid; working=1)
        else
                solved_array[i,:] = solve_basic(next_income,asset_index,value_array,asset_grid)
        end

        # \ get values
        # actual_consumption[i] = cons
        # actual_next_asset[i] = next_asset
        # actual_asset_index[i] = next_asset_ind
        # actual_value[i] = value
    end
    out_array = Array{Float64,1}(undef,6)
    if solved_array[1,1] > solved_array[2,1]
            # Return work values
            # return actual_value[1], actual_consumption[1], actual_next_asset[1], actual_asset_index[1], adjusted_work_income, choose_to_work
            out_array[1:4] = solved_array[1,:]
            out_array[5] = adjusted_work_income
            out_array[6] = choose_to_work
    else
            # return do not work values
            # return actual_value[2], actual_consumption[2], actual_next_asset[2], actual_asset_index[2], stop_working_income, choose_not_to_work
            out_array[1:4] = solved_array[2,:]
            out_array[5] = stop_working_income
            out_array[6] = choose_not_to_work
    end
    return out_array
end

function get_work_values(u_index, job_fit_index,next_value_array,delta,lambda_e,
                        working_state,unemployed_ui_state,u_transition,a_weights)
        a_size = size(a_weights,1)
        asset_size = size(next_value_array,1)
        u_size = size(next_value_array,2)

        # Get possibility of lay off
        laid_off_possibilities = next_value_array[:,:,unemployed_ui_state,job_fit_index]
        # weight on u shock
        u_ind_options = Array{Int64,1}(undef,2)
        u_ind_options[1] = 1
        u_ind_options[2] = u_index - u_decline_for_delta

        u_index_laid_off = maximum(u_ind_options)
        laid_off_possibilities = weight_for_u_transition(laid_off_possibilities,u_index_laid_off,u_transition)
        laid_off_component = delta * laid_off_possibilities
        # no new job offer component
        # Get array of possibilities
        same_job_possibilities = next_value_array[:,:,working_state,job_fit_index]
        # reduce by weighting u probabilities
        same_job_possibilities = weight_for_u_transition(same_job_possibilities,u_index,u_transition)
        same_job_weight = ((1 - delta) * (1 - lambda_e) + (1 - delta) * lambda_e * sum(a_weights[1:job_fit_index]))

        same_job_component = Array{Float64,1}(undef,a_size)
        same_job_component = @. same_job_weight * same_job_possibilities

        # Get new job possibilities
        cond = true
        cond = job_fit_index < a_size
        if cond
                # get data
                new_job_possibilities = next_value_array[:,:,working_state,(job_fit_index + 1):end]
                # get array to put values in
                new_job_possibilities_red = zeros(asset_size)
                for i = 1:asset_size
                        # get 1 asset 2-dim array to work with
                        new_job_pre_red = new_job_possibilities[i,:,:]
                        # Eliminate 1 dim by weighting a proberly with matrix vector product
                        new_job_pre_red2 = new_job_pre_red * a_weights[(job_fit_index + 1):end]
                        # Use dot product to handle u reduction
                        new_job_pre_red_transpose = new_job_pre_red2'
                        new_job_val = weight_for_u_transition_1d(new_job_pre_red_transpose,u_index,u_transition)
                        # Now write float to array
                        new_job_possibilities_red[i] = new_job_val
                end
                new_job_weight = (1 - delta) * lambda_e
                # Note we didn't have to multiply the weight by sum(a_weights[(job_fit_index+1):end]))
                        #  This is because in the reduction of the a dimension the matrix
                        #       Has only a sum of sum(a_weights[(job_fit_index+1):end]))
                        #       Thus the weighting for that part of a occurs at that step
                new_job_component = @. new_job_weight * new_job_possibilities_red

                #sum components
                tot_value = laid_off_component + same_job_component + new_job_component
        else
                tot_value = laid_off_component + same_job_component
        end


        return tot_value
end


function get_dont_work_values(u_index, next_value_array,lambda_n,
                        working_state,unemployed_state,u_transition,a_weights)
        # get sizes
        a_size = size(a_weights,1)
        asset_size = size(next_value_array,1)
        u_size = size(next_value_array,2)

        # allocate memory for returned item
        tot_value = Array{Float64,1}(undef,asset_size)

        # get no job offer values
        # Get possibility of no job offer
        still_unemployed_possibilities = next_value_array[:,:,unemployed_state,1]
        # weight on u shock
        still_unemployed_possibilities2 = weight_for_u_transition(still_unemployed_possibilities,u_index,u_transition)
        still_unemployed_weight = 1 - lambda_n
        still_unemployed_component = @. still_unemployed_weight * still_unemployed_possibilities2

        # get data
        new_job_possibilities = next_value_array[:,:,working_state,:]
        # get array to put values in
        new_job_possibilities_red = zeros(asset_size)
        for i = 1:asset_size
                # get 1 asset 2-dim array to work with
                new_job_pre_red = new_job_possibilities[i,:,:]
                # Eliminate 1 dim by weighting a proberly with matrix vector product
                # new_job_pre_red = new_job_pre_red * a_weights[:]
                new_job_pre_red = new_job_pre_red * a_weights
                # Use dot product to handle u reduction
                new_job_pre_red_transpose = new_job_pre_red'
                new_job_val = weight_for_u_transition_1d(new_job_pre_red_transpose,u_index,u_transition)
                # Now write float to array
                new_job_possibilities_red[i] = new_job_val
        end
        new_job_weight = lambda_n
        new_job_component = @. new_job_weight * new_job_possibilities_red

        # sum 2 cases to get total value
        tot_value = still_unemployed_component + new_job_component


        return tot_value


end

function get_di_apply_values(u_index,next_value_array,unemployed_di_inelig_state,disability_state)
        # get sizes
        a_size = size(a_weights,1)
        asset_size = size(next_value_array,1)
        u_size = size(next_value_array,2)

        # allocate memory for returned item
        tot_value = Array{Float64,1}(undef,asset_size)

        rejected_possibilities = next_value_array[:,:,unemployed_di_inelig_state,1]
        # weight for u
        rejected_possibilities2 = weight_for_u_transition(rejected_possibilities,u_index,u_transition)
        rejected_weight = 1 - P_disability_acceptance
        rejected_component = @. rejected_weight * rejected_possibilities2

        # we assume that your u doesn't changes if accepted into disability
        accepted_possibilities = next_value_array[:,u_index,disability_state,1]
        # accepted_possibilities = accepted_possibilities * u_transition[:,u_index]
        accepted_weight = P_disability_acceptance
        accepted_component = @. accepted_weight * accepted_possibilities

        tot_value = accepted_component + rejected_component

        return tot_value

end

function solve_unemployed_w_di(income,asset_index,wait_for_job_values,apply_for_di_values,asset_grid)
        # Get the assets
        current_assets = asset_grid[asset_index]

        actual_consumption = Array{Float64}(undef,2)
        actual_next_asset = Array{Float64}(undef,2)
        actual_asset_index = Array{Float64}(undef,2)
        actual_value = Array{Float64}(undef,2)

        # pull income
        next_income = income

        for i = 1:2

            # get correct value array
            if i == 1
                    value_array = wait_for_job_values
            else
                    value_array = apply_for_di_values
            end

            if i == 1
                    value, cons, next_asset, next_asset_ind = solve_basic(next_income,asset_index,value_array,asset_grid)
            else
                    value, cons, next_asset, next_asset_ind = solve_basic(next_income,asset_index,value_array,asset_grid)
            end

            # get values
            actual_consumption[i] = cons
            actual_next_asset[i] = next_asset
            actual_asset_index[i] = next_asset_ind
            actual_value[i] = value

        end
        if actual_value[1] > actual_value[2]
                # Return work values
                return actual_value[1], actual_consumption[1], actual_next_asset[1], actual_asset_index[1], choose_to_not_apply_for_di
        else
                # return do not work values
                return actual_value[2], actual_consumption[2], actual_next_asset[2], actual_asset_index[2], choose_to_apply_for_di
        end

end


# t1 = rand(33)
# t2 = 5
# t3 = rand(33)
#
#
# f() = solve_basic(t1,t2,t3,asset_grid;working=0)
#
#
# using Profile, ProfileView
# using Juno
# Profile.clear()
# # Profile.init()
# Profile.init(delay=.0001)
# @profile solve_basic(t1,t2,t3,asset_grid;working=0)
# ProfileView.view()
# # Juno.profiletree()
# # Juno.profiler()
# # @profiler solve_basic(t1,t2,t3,asset_grid;working=0)
