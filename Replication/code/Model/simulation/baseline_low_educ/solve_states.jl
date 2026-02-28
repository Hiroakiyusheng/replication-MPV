using LinearAlgebra
# @everywhere using Memoize

include("base.jl")


function weight_for_u_transition(potential_values,u_index,u_transition)
        potential_values_diff_u = potential_values * u_transition[:,u_index]
        potential_values_same_u = potential_values[:,u_index]

        weighted_potential_values_diff_u = @.  P_zeta * potential_values_diff_u

        no_shock_weight = (1- P_zeta)
        weighted_potential_values_same_u = @. no_shock_weight * potential_values_same_u

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

        current_assets = asset_grid[asset_index]

        # Eliminate asset choices too low
        below_min = @. (asset_grid < next_income)
        # Note index of lowest next period asset choice
        min_asset_choice = sum(below_min) + 1

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
        actual_consumption = potential_cons_choices[best]
        actual_next_asset = potential_next_assets[best]
        actual_asset_index = (min_asset_choice + best - 1)
        actual_value = potential_options[best]
        return actual_value, actual_consumption, actual_next_asset, actual_asset_index
end


function solve_employed(working_income,stop_working_income,asset_index,keep_working_values,stop_working_values,asset_grid)
    # create array of income options
    # subtract fixed cost of working
    adjusted_work_income = working_income - F
    if adjusted_work_income < 1
     adjusted_work_income = 1
    end
    incomes = [adjusted_work_income stop_working_income]

    actual_consumption = Array{Float64}(undef,2)
    actual_next_asset = Array{Float64}(undef,2)
    actual_asset_index = Array{Float64}(undef,2)
    actual_value = Array{Float64}(undef,2)

    for i = 1:2

        # get correct value array
        if i == 1
                value_array = keep_working_values
        else
                value_array = stop_working_values
        end

        # pull income
        next_income = incomes[i]
        # Eliminate asset choices too low
        if i == 1
                # Make working
                value, cons, next_asset, next_asset_ind = solve_basic(next_income,asset_index,value_array,asset_grid;working=1)
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
            return actual_value[1], actual_consumption[1], actual_next_asset[1], actual_asset_index[1], adjusted_work_income, choose_to_work
    else
            # return do not work values
            return actual_value[2], actual_consumption[2], actual_next_asset[2], actual_asset_index[2], stop_working_income, choose_not_to_work
    end
end

function get_work_values(u_index, job_fit_index,next_value_array,delta,lambda_e,
                        working_state,unemployed_ui_state,u_transition,a_weights)
        a_size = size(a_weights,1)
        asset_size = size(next_value_array,1)
        u_size = size(next_value_array,2)

        # Get possibility of lay off
        laid_off_possibilities = next_value_array[:,:,unemployed_ui_state,job_fit_index]
        # weight on u shock
        laid_off_possibilities = weight_for_u_transition(laid_off_possibilities,u_index,u_transition)
        laid_off_component = delta * laid_off_possibilities
        # no new job offer component
        # Get array of possibilities
        same_job_possibilities = next_value_array[:,:,working_state,job_fit_index]
        # reduce by weighting u probabilities
        same_job_possibilities = weight_for_u_transition(same_job_possibilities,u_index,u_transition)
        same_job_weight = ((1 - delta) * (1 - lambda_e) + (1 - delta) * lambda_e * sum(a_weights[1:job_fit_index]))
        same_job_component = @. same_job_weight * same_job_possibilities

        # Get new job possibilities
        if job_fit_index < a_size
                # get data
                new_job_possibilities = next_value_array[:,:,working_state,(job_fit_index + 1):end]
                # get array to put values in
                new_job_possibilities_red = zeros(asset_size)
                for i = 1:asset_size
                        # get 1 asset 2-dim array to work with
                        new_job_pre_red = new_job_possibilities[i,:,:]
                        # Eliminate 1 dim by weighting a proberly with matrix vector product
                        new_job_pre_red = new_job_pre_red * a_weights[(job_fit_index + 1):end]
                        # Use dot product to handle u reduction
                        new_job_pre_red_transpose = new_job_pre_red'
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

        # get no job offer values
        # Get possibility of no job offer
        still_unemployed_possibilities = next_value_array[:,:,unemployed_state,1]
        # weight on u shock
        still_unemployed_possibilities = weight_for_u_transition(still_unemployed_possibilities,u_index,u_transition)
        still_unemployed_weight = 1 - lambda_n
        still_unemployed_component = @. still_unemployed_weight * still_unemployed_possibilities

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

        rejected_possibilities = next_value_array[:,:,unemployed_di_inelig_state,1]
        # weight for u
        rejected_possibilities = weight_for_u_transition(rejected_possibilities,u_index,u_transition)
        rejected_weight = 1 - P_disability_acceptance
        rejected_component = @. rejected_weight * rejected_possibilities

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
                    # Make working
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
