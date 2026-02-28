# Setup parallel computing
using FileIO, JLD2
using Distributed
using Base.Threads
using Mmap

# cores = 4
#
# proc_count = cores + 1
#
# addp = proc_count - nprocs()
#
# addprocs(addp)

println("procs: ",nprocs())


@everywhere using SharedArrays
# @everywhere using Memoize

# This section only needed for testing in Juno because
#   working directory does not populate correctly
@everywhere using ParallelDataTransfer
loc = pwd()
@everywhere loc = @getfrom 1 loc
@everywhere cd(loc)
# End juno only section

@everywhere include("solve_states.jl")

function solve_last_period(asset_grid,u_grid)
    # Get grid sizes
    asset_size = size(asset_grid,1)
    u_size = size(u_grid,1)
    # Set up array
    value_array = Array{Float64}(undef,asset_size,u_size)

    # get utilities because people will all their assets
    value_flat = @.utility(asset_grid,0)
    # Set into array for all values of u
    @. value_array[:,:] = value_flat

    return value_array
end


function solve_retirement(asset_grid,u_grid,retiree_periods)

    # Get grid sizes
    asset_size = size(asset_grid,1)
    u_size = size(u_grid,1)

    # set up arrays
    consumption_choice = SharedArray{Float64}(retiree_periods,asset_size,u_size)
    next_asset_choice = SharedArray{Float64}(retiree_periods,asset_size,u_size)
    next_asset_index = SharedArray{Int64}(retiree_periods,asset_size,u_size)
    value_array = SharedArray{Float64}(retiree_periods,asset_size,u_size)
    income_array = SharedArray{Float64}(retiree_periods,asset_size,u_size)

    # First we do the last period
    # consumption choice must be all your assets
    @. consumption_choice[retiree_periods,:,:] = asset_grid
    # get the values
    last_period_value = solve_last_period(asset_grid,u_grid)
    @. value_array[retiree_periods,:,:] = last_period_value

    # Now for the remaining periods
    # First let's solve for income given u

    # First find social security income
    avg_est_inc_grid = @.est_avg_income(u_grid)
    ss_income_grid = @.disability_amount(avg_est_inc_grid)
    fs_income_grid = @.food_stamps_amount(ss_income_grid)

    tot_income_grid = @. (ss_income_grid + fs_income_grid)

    for k = 1:u_size
        @. income_array[:,:,k] = tot_income_grid[k]
    end

    @. income_array[retiree_periods,:,:] = 0

    for i = (retiree_periods - 1):-1:1
        # Note next_period index
        next_period = i+1
        period_values = value_array[next_period,:,:]
        @sync @distributed for j = 1:asset_size
            # Note this period assets
            current_assets = asset_grid[j]
            for k = 1:u_size

                next_values = period_values[:,k]
                # next_values = weight_for_u_transition(period_values,k,u_transition)

                income = tot_income_grid[k]

                value, cons, next_asset, next_asset_ind = solve_basic(income,j,next_values,asset_grid)

                # Now get and set values
                consumption_choice[i,j,k] = cons
                next_asset_choice[i,j,k] = next_asset
                next_asset_index[i,j,k] = next_asset_ind
                value_array[i,j,k] = value

            end
        end
    end

    return consumption_choice, next_asset_choice, next_asset_index, value_array, income_array
end



function solve_over_50(delta,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,a_weights,
                        over_50_periods,next_value_array_over50
                        ;start_age=over_50_start_age)
    # Get grid sizes
    asset_size = size(asset_grid,1)
    u_size = size(u_grid,1)
    a_size = size(a_grid,1)
    # state_count = 6
    #
    # # There are 6 states, we save 0 to represent N/A
    # # 0 - N/A
    # # 1 - Working
    # #   Choices: To work or quit
    # working_state = 1
    # # 2 - Job Offer, DI ineligible
    # #   Choices: work or not work
    # offer_di_ineligible_state = 2
    # # 3 - Unemployed DI eligible & UI receiving
    # #   Choices: To apply for DI or wait for job
    # unemployed_ui_state = 3
    # # 4 - Unemployed DI eligible
    # #   Choices: To apply for DI or wait for job
    # unemployed_di_elig_state = 4
    # # 5 - Unemployed DI ineligible
    # #   Choices: no choices, must wait for job or remain unemployed
    # unemployed_di_inelig_state = 5
    # # 6 - Disability
    # #   Choices: no choices, disability is an absorbing state
    # disability_state = 6

    # set up arrays
    consumption_choice = SharedArray{Float64}(over_50_periods,asset_size,u_size,state_count,a_size)
    next_asset_choice = SharedArray{Float64}(over_50_periods,asset_size,u_size,state_count,a_size)
    next_asset_index = SharedArray{Int64}(over_50_periods,asset_size,u_size,state_count,a_size)
    value_array = SharedArray{Float64}(over_50_periods,asset_size,u_size,state_count,a_size)
    realized_income_array = SharedArray{Float64}(over_50_periods,asset_size,u_size,state_count,a_size)
    choice_array = SharedArray{Float64}(over_50_periods,asset_size,u_size,state_count,a_size)
    # Choices
    # 0 - N/A
    # 1 - Work
    # 2 - Don't work
    # 3 - don't apply for DI, i.e. stay unemployed
    # 4 - apply for DI

    # First we get income and disability values

    # First find disability income
    est_avg_prior_inc_grid = @.est_avg_income(u_grid)
    di_income_grid = @.disability_amount(est_avg_prior_inc_grid)
    di_fs_income_grid = @.food_stamps_amount(di_income_grid)
    # Get total di income with foodstamps
    tot_di_income_grid = @. (di_income_grid + di_fs_income_grid)

    # Now find income if you are working
    # Get years
    tot_years = Int(over_50_periods / 4)
    max_age = start_age + tot_years - 1
    ages = start_age:1:max_age

    # calculate income values
    income_array = Array{Float64}(undef,tot_years,u_size,a_size)
    unemployment_array = Array{Float64}(undef,tot_years,u_size,a_size)
    for (i,x) = enumerate(ages)
        for (j,y) = enumerate(u_grid)
            for (k,z) = enumerate(a_grid)
                income = quarterly_income(x,y,z)
                # Get normal income
                fs_income = food_stamps_amount(income)
                income_array[i,j,k] = income + fs_income
                # Get UI income
                ui_income = unemployment_income_amount(income)
                fs_ui = food_stamps_amount(ui_income)
                unemployment_array[i,j,k] = ui_income + fs_ui

            end
        end
    end
    # Get foodstamps amount with 0 income
    unemployed_post_ui_income = food_stamps_amount(0)
    # Now solve pre retirement period
    cur_age = max_age
    cur_period = over_50_periods
    @sync @distributed for i = 1:asset_size
        for j = 1:u_size
            # Now we solve for each state
            for k = 1:state_count
                # If you're employed
                if k == 1
                    # Must consider all job fit possibilities
                    for m = 1: a_size
                        # we assume no stochastic shocks in the last period
                        keep_working_values = next_value_array_over50[:,j]
                        stop_working_values = keep_working_values
                        working_income = income_array[tot_years,j,m]
                        value, cons, next_asset, next_asset_ind, realized_income, work_choice =
                            solve_employed(working_income,unemployed_post_ui_income,
                                        i,keep_working_values,stop_working_values,asset_grid)

                        # Note that since DI eligibility is null in the last period
                        #   We need not do k = 2
                        consumption_choice[over_50_periods,i,j,k,m] = cons
                        next_asset_choice[over_50_periods,i,j,k,m] =next_asset
                        next_asset_index[over_50_periods,i,j,k,m] = next_asset_ind
                        value_array[over_50_periods,i,j,k,m] = value
                        choice_array[over_50_periods,i,j,k,m] = work_choice
                        realized_income_array[over_50_periods,i,j,k,m] = realized_income
                    end
                elseif k == 2
                    # Taken care of by identical case 1
                    for m = 1: a_size
                        consumption_choice[over_50_periods,i,j,k,m] = consumption_choice[over_50_periods,i,j,k-1,m]
                        next_asset_choice[over_50_periods,i,j,k,m] = next_asset_choice[over_50_periods,i,j,k-1,m]
                        next_asset_index[over_50_periods,i,j,k,m] = next_asset_index[over_50_periods,i,j,k-1,m]
                        value_array[over_50_periods,i,j,k,m] = value_array[over_50_periods,i,j,k-1,m]
                        choice_array[over_50_periods,i,j,k,m] = choice_array[over_50_periods,i,j,k-1,m]
                        realized_income_array[over_50_periods,i,j,k,m] = realized_income_array[over_50_periods,i,j,k-1,m]
                    end
                elseif k == 3
                    # Must consider all job fit possibilities
                    for m = 1: a_size
                        # we assume no stochastic shocks in the last period
                        next_values = next_value_array_over50[:,j]
                        income = unemployment_array[tot_years,j,m]
                        value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                        consumption_choice[over_50_periods,i,j,k,m] = cons
                        next_asset_choice[over_50_periods,i,j,k,m] = next_asset
                        next_asset_index[over_50_periods,i,j,k,m] = next_asset_ind
                        value_array[over_50_periods,i,j,k,m] = value
                        realized_income_array[over_50_periods,i,j,k,m] = income
                    end
                elseif k == 4
                    # we assume no stochastic shocks in the last period
                    next_values = next_value_array_over50[:,j]
                    income = unemployed_post_ui_income
                    value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                    @. consumption_choice[over_50_periods,i,j,k,:] = cons
                    @. next_asset_choice[over_50_periods,i,j,k,:] = next_asset
                    @. next_asset_index[over_50_periods,i,j,k,:] = next_asset_ind
                    @. value_array[over_50_periods,i,j,k,:] = value
                    @. realized_income_array[over_50_periods,i,j,k,:] = income

                elseif k == 5
                    # we assume no stochastic shocks in the last period
                    next_values = next_value_array_over50[:,j]
                    income = unemployed_post_ui_income
                    value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                    @. consumption_choice[over_50_periods,i,j,k,:] = cons
                    @. next_asset_choice[over_50_periods,i,j,k,:] = next_asset
                    @. next_asset_index[over_50_periods,i,j,k,:] = next_asset_ind
                    @. value_array[over_50_periods,i,j,k,:] = value
                    @. realized_income_array[over_50_periods,i,j,k,:] = income

                elseif k == 6
                    # we assume no stochastic shocks in the last period
                    next_values = next_value_array_over50[:,j]
                    income = tot_di_income_grid[j]
                    value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                    @. consumption_choice[over_50_periods,i,j,k,:] = cons
                    @. next_asset_choice[over_50_periods,i,j,k,:] = next_asset
                    @. next_asset_index[over_50_periods,i,j,k,:] = next_asset_ind
                    @. value_array[over_50_periods,i,j,k,:] = value
                    @. realized_income_array[over_50_periods,i,j,k,:] = income

                else
                    error("state unrecognized")
                end
            end
        end
    end

    # solve for all remaining periods in this bin
    for cur_period = (over_50_periods - 1):-1:1
        # @everywhere GC.gc()
        println("Period: ",(112 + cur_period))
        # get the age
        cur_year = Int(floor(cur_period / 4) + 1)
        # get next values
        next_value_array = value_array[(cur_period + 1),:,:,:,:]
        # Consider all initial asset possibilities
        @time @sync @distributed for i = 1:asset_size
            # consider all stochastic job possibilities
            for j = 1:u_size
                # Now we solve for each state
                for k = 1:state_count
                    # If you're employed
                    if k == 1
                        # Must consider all job fit possibilities
                        for m = 1:a_size
                            keep_working_values = get_work_values(j,m,
                                            next_value_array,
                                                delta,lambda_e,working_state,unemployed_ui_state,
                                                    u_transition,a_weights)
                            stop_working_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                    working_state,unemployed_di_elig_state,u_transition,a_weights)

                            working_income = income_array[cur_year,j,m]
                            value, cons, next_asset, next_asset_ind, realized_income, work_choice =
                                            solve_employed(working_income,
                                                unemployed_post_ui_income,i,
                                                keep_working_values,stop_working_values,
                                                asset_grid)

                            consumption_choice[cur_period,i,j,k,m] = cons
                            next_asset_choice[cur_period,i,j,k,m] =next_asset
                            next_asset_index[cur_period,i,j,k,m] = next_asset_ind
                            value_array[cur_period,i,j,k,m] = value
                            choice_array[cur_period,i,j,k,m] = work_choice
                            realized_income_array[cur_period,i,j,k,m] = realized_income
                        end
                    elseif k == 2
                        # Must consider all job fit possibilities
                        for m = 1: a_size
                            keep_working_values = get_work_values(j,m,
                                            next_value_array,
                                                delta,lambda_e,working_state,unemployed_ui_state,
                                                    u_transition,a_weights)
                            stop_working_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                    working_state,unemployed_di_inelig_state,u_transition,a_weights)

                            working_income = income_array[cur_year,j,m]
                            value, cons, next_asset, next_asset_ind, realized_income, work_choice = solve_employed(working_income,unemployed_post_ui_income,i,keep_working_values,stop_working_values,asset_grid)

                            consumption_choice[cur_period,i,j,k,m] = cons
                            next_asset_choice[cur_period,i,j,k,m] =next_asset
                            next_asset_index[cur_period,i,j,k,m] = next_asset_ind
                            value_array[cur_period,i,j,k,m] = value
                            choice_array[cur_period,i,j,k,m] = work_choice
                            realized_income_array[cur_period,i,j,k,m] = realized_income
                        end
                    elseif k == 3
                        # unemployed ui state
                        # Must consider all job fit possibilities
                        for m = 1: a_size
                            wait_for_job_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                    working_state,unemployed_di_elig_state,u_transition,a_weights)
                            income = unemployment_array[cur_year,j,m]
                            if j < disability_cutoff_index
                            apply_for_di_values = get_di_apply_values(j,
                                        next_value_array,
                                        unemployed_di_inelig_state,disability_state)


                            value, cons, next_asset, next_asset_ind, di_choice = solve_unemployed_w_di(income,i,wait_for_job_values,apply_for_di_values,asset_grid)
                            else
                                value, cons, next_asset, next_asset_ind = solve_basic(income,i,wait_for_job_values,asset_grid)

                                di_choice = choose_to_not_apply_for_di
                            end
                            consumption_choice[cur_period,i,j,k,m] = cons
                            next_asset_choice[cur_period,i,j,k,m] = next_asset
                            next_asset_index[cur_period,i,j,k,m] = next_asset_ind
                            value_array[cur_period,i,j,k,m] = value
                            choice_array[cur_period,i,j,k,m] = di_choice
                            realized_income_array[cur_period,i,j,k,m] = income
                        end
                    elseif k == 4
                        # we assume no stochastic shocks in the last period
                        wait_for_job_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                working_state,unemployed_di_elig_state,u_transition,a_weights)
                        income = unemployed_post_ui_income

                        if j < disability_cutoff_index
                            apply_for_di_values = get_di_apply_values(j,
                                        next_value_array,
                                        unemployed_di_inelig_state,disability_state)


                            value, cons, next_asset, next_asset_ind, di_choice = solve_unemployed_w_di(income,i,wait_for_job_values,apply_for_di_values,asset_grid)
                        else
                            value, cons, next_asset, next_asset_ind = solve_basic(income,i,wait_for_job_values,asset_grid)

                            di_choice = choose_to_not_apply_for_di
                        end
                        @. consumption_choice[cur_period,i,j,k,:] = cons
                        @. next_asset_choice[cur_period,i,j,k,:] = next_asset
                        @. next_asset_index[cur_period,i,j,k,:] = next_asset_ind
                        @. value_array[cur_period,i,j,k,:] = value
                        @. choice_array[cur_period,i,j,k,:] = di_choice
                        @. realized_income_array[cur_period,i,j,k,:] = income

                    elseif k == 5
                        # we assume no stochastic shocks in the last period
                        next_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                working_state,unemployed_di_inelig_state,u_transition,a_weights)
                        income = unemployed_post_ui_income
                        value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                        @. consumption_choice[cur_period,i,j,k,:] = cons
                        @. next_asset_choice[cur_period,i,j,k,:] = next_asset
                        @. next_asset_index[cur_period,i,j,k,:] = next_asset_ind
                        @. value_array[cur_period,i,j,k,:] = value
                        @. realized_income_array[cur_period,i,j,k,:] = income

                    elseif k == 6
                        # we assume no stochastic shocks in the last period
                        next_values = next_value_array[:,j,k,1]
                        income = tot_di_income_grid[j]
                        value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                        @. consumption_choice[cur_period,i,j,k,:] = cons
                        @. next_asset_choice[cur_period,i,j,k,:] = next_asset
                        @. next_asset_index[cur_period,i,j,k,:] = next_asset_ind
                        @. value_array[cur_period,i,j,k,:] = value
                        @. realized_income_array[cur_period,i,j,k,:] = income

                    else
                        error("state unrecognized")
                    end
                end
            end
        end
    end




    return consumption_choice, next_asset_choice, next_asset_index, value_array, choice_array, realized_income_array
end

function solve_until_50(delta,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,a_weights,
                        until_50_periods,next_value_array_until50
                        ;start_age=start_age)
    # Get grid sizes
    asset_size = size(asset_grid,1)
    u_size = size(u_grid,1)
    a_size = size(a_grid,1)
    # state_count = 6 #we use the same array size so indexing will work
    #                     #and we can append the arrays later
    #
    # # There are 3 states, we save 0 to represent N/A
    # # 0 - N/A
    # # 1 - Working
    # #   Choices: To work or quit
    # working_state = 1
    # # 3 - Unemployed  UI receiving
    # #   Choices: None
    # unemployed_ui_state = 3
    # # 4 - Unemployed
    # #   Choices: None
    # unemployed_di_elig_state = 4
    # # although you can't get di in this period, these people will be di elig
    # #   when retired

    # set up arrays
    consumption_choice = SharedArray{Float64}(until_50_periods,asset_size,u_size,state_count,a_size)
    next_asset_choice = SharedArray{Float64}(until_50_periods,asset_size,u_size,state_count,a_size)
    next_asset_index = SharedArray{Int64}(until_50_periods,asset_size,u_size,state_count,a_size)
    value_array = SharedArray{Float64}(until_50_periods,asset_size,u_size,state_count,a_size)
    choice_array = SharedArray{Float64}(until_50_periods,asset_size,u_size,state_count,a_size)
    realized_income_array = SharedArray{Float64}(until_50_periods,asset_size,u_size,state_count,a_size)
    # Choices
    # 0 - N/A
    # 1 - Work
    # 2 - Don't work

    # First we get income values
    # find income if you are working
    # Get years
    tot_years = Int(until_50_periods / 4)
    max_age = start_age + tot_years - 1
    ages = start_age:1:max_age
    # println(ages)
    # calculate income values
    income_array = Array{Float64}(undef,tot_years,u_size,a_size)
    unemployment_array = Array{Float64}(undef,tot_years,u_size,a_size)
    for (i,x) = enumerate(ages)
        for (j,y) = enumerate(u_grid)
            for (k,z) = enumerate(a_grid)
                income = quarterly_income(x,y,z)
                # Get normal income
                fs_income = food_stamps_amount(income)
                income_array[i,j,k] = income + fs_income
                # Get UI income
                ui_income = unemployment_income_amount(income)
                fs_ui = food_stamps_amount(ui_income)
                unemployment_array[i,j,k] = ui_income + fs_ui
            end
        end
    end
    # Get foodstamps amount with 0 income
    unemployed_post_ui_income = food_stamps_amount(0)

    # Now solve pre retirement period
    cur_age = max_age
    cur_period = until_50_periods
    @sync @distributed for i = 1:asset_size
        for j = 1:u_size
            # Now we solve for each state
            for k = 1:state_count
                # If you're employed
                if k == 1
                    # Must consider all job fit possibilities
                    for m = 1: a_size
                        # we assume no stochastic shocks in the last period
                        keep_working_values = get_work_values(j,m,
                                        next_value_array_until50,
                                            delta,lambda_e,working_state,unemployed_ui_state,
                                                u_transition,a_weights)
                        stop_working_values = get_dont_work_values(j, next_value_array_until50,lambda_n,
                                                working_state,unemployed_di_elig_state,u_transition,a_weights)
                        working_income = income_array[tot_years,j,m]
                        value, cons, next_asset, next_asset_ind, realized_income, work_choice =
                            solve_employed(working_income,unemployed_post_ui_income,
                                        i,keep_working_values,stop_working_values,asset_grid)

                        # Note that since DI eligibility is null in the last period
                        #   We need not do k = 2
                        consumption_choice[until_50_periods,i,j,k,m] = cons
                        next_asset_choice[until_50_periods,i,j,k,m] =next_asset
                        next_asset_index[until_50_periods,i,j,k,m] = next_asset_ind
                        value_array[until_50_periods,i,j,k,m] = value
                        choice_array[until_50_periods,i,j,k,m] = work_choice
                        realized_income_array[until_50_periods,i,j,k,m] = realized_income
                    end
                elseif k == 3
                    # Must consider all job fit possibilities
                    for m = 1: a_size
                        # we assume no stochastic shocks in the last period
                        next_values = get_dont_work_values(j, next_value_array_until50,lambda_n,
                                                working_state,unemployed_di_elig_state,u_transition,a_weights)
                        income = unemployment_array[tot_years,j,m]
                        value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                        consumption_choice[until_50_periods,i,j,k,m] = cons
                        next_asset_choice[until_50_periods,i,j,k,m] = next_asset
                        next_asset_index[until_50_periods,i,j,k,m] = next_asset_ind
                        value_array[until_50_periods,i,j,k,m] = value
                        realized_income_array[until_50_periods,i,j,k,m] = income
                    end
                elseif k == 4
                    # # we assume no stochastic shocks in the last period
                    next_values = get_dont_work_values(j, next_value_array_until50,lambda_n,
                                            working_state,unemployed_di_elig_state,u_transition,a_weights)
                    income = unemployed_post_ui_income
                    value, cons, next_asset, next_asset_ind = solve_basic(income,i,next_values,asset_grid)

                    @. consumption_choice[until_50_periods,i,j,k,:] = cons
                    @. next_asset_choice[until_50_periods,i,j,k,:] = next_asset
                    @. next_asset_index[until_50_periods,i,j,k,:] = next_asset_ind
                    @. value_array[until_50_periods,i,j,k,:] = value
                    @. realized_income_array[until_50_periods,i,j,k,:] = income
                else
                    nothing
                end
            end
        end
    end

    # solve for all remaining periods in this bin
    for cur_period = (until_50_periods - 1):-1:1
        next_value_array = value_array[(cur_period + 1),:,:,:,:]
        println("Period: ",cur_period)
        # get the age
        cur_year = Int(floor(cur_period / 4) + 1)
        # Consider all initial asset possibilities
        @time @sync @distributed for i = 1:asset_size
            # consider all stochastic job possibilities
            for j = 1:u_size
                # Now we solve for each state
                for k = 1:state_count
                    # If you're employed
                    if k == 1
                        # Must consider all job fit possibilities
                        for m = 1: a_size
                            keep_working_values = get_work_values(j,m,
                                            next_value_array,
                                                delta,lambda_e,working_state,unemployed_ui_state,
                                                    u_transition,a_weights)
                            stop_working_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                    working_state,unemployed_di_elig_state,u_transition,a_weights)

                            working_income = income_array[cur_year,j,m]
                            value, cons, next_asset, next_asset_ind, realized_income, work_choice =
                                            solve_employed(working_income,
                                                unemployed_post_ui_income,i,
                                                keep_working_values,stop_working_values,
                                                asset_grid)


                            consumption_choice[cur_period,i,j,k,m] = cons
                            next_asset_choice[cur_period,i,j,k,m] = next_asset
                            next_asset_index[cur_period,i,j,k,m] = next_asset_ind
                            value_array[cur_period,i,j,k,m] = value
                            choice_array[cur_period,i,j,k,m] = work_choice
                            realized_income_array[cur_period,i,j,k,m] = realized_income

                            # if (cur_period==1)&(i==5)&(j==6)&(k==1)&(m==5)
                            #     println("hello yall")
                            #     println(cons)
                            #     println(next_asset)
                            #     println(next_asset_ind)
                            #     println(next_asset_index[cur_period,i,j,k,m])
                            #     println(next_asset_index[1,5,6,1,5])
                            # end

                        end
                    elseif k == 3
                        # unemployed ui state
                        # Must consider all job fit possibilities
                        for m = 1: a_size
                            wait_for_job_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                    working_state,unemployed_di_elig_state,u_transition,a_weights)

                            income = unemployment_array[cur_year,j,m]
                            value, cons, next_asset, next_asset_ind = solve_basic(income,i,wait_for_job_values,asset_grid)

                            consumption_choice[cur_period,i,j,k,m] = cons
                            next_asset_choice[cur_period,i,j,k,m] = next_asset
                            next_asset_index[cur_period,i,j,k,m] = next_asset_ind
                            value_array[cur_period,i,j,k,m] = value
                            realized_income_array[cur_period,i,j,k,m] = income
                        end
                    elseif k == 4
                        # we assume no stochastic shocks in the last period
                        wait_for_job_values = get_dont_work_values(j, next_value_array,lambda_n,
                                                working_state,unemployed_di_elig_state,u_transition,a_weights)

                        income = unemployed_post_ui_income
                        value, cons, next_asset, next_asset_ind = solve_basic(income,i,wait_for_job_values,asset_grid)

                        @. consumption_choice[cur_period,i,j,k,:] = cons
                        @. next_asset_choice[cur_period,i,j,k,:] = next_asset
                        @. next_asset_index[cur_period,i,j,k,:] = next_asset_ind
                        @. value_array[cur_period,i,j,k,:] = value
                        @. realized_income_array[cur_period,i,j,k,:] = income
                    else
                        nothing
                    end
                end
            end
        end
    end




    return consumption_choice, next_asset_choice, next_asset_index, value_array, choice_array, realized_income_array
end



function solve_all(delta,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
                        a_weights,until_50_periods,
                        over_50_periods,retiree_periods)

    state_count = 6
    a_size = size(a_grid,1)


    con_retired, ass_retired, assi_retired, val_retired, inc_retired = solve_retirement(asset_grid,
                                                            u_grid,retiree_periods)

    s = size(val_retired)

    con_retired_f = Array{Float64}(undef,s[1],s[2],s[3],state_count,a_size)
    ass_retired_f = Array{Float64}(undef,s[1],s[2],s[3],state_count,a_size)
    assi_retired_f = Array{Int64}(undef,s[1],s[2],s[3],state_count,a_size)
    val_retired_f = Array{Float64}(undef,s[1],s[2],s[3],state_count,a_size)
    inc_retired_f = Array{Float64}(undef,s[1],s[2],s[3],state_count,a_size)

    for i = 1:s[1]
        for j = 1:s[2]
            for k = 1:s[3]
                @. con_retired_f[i,j,k,:,:] = con_retired[i,j,k]
                @. ass_retired_f[i,j,k,:,:] = ass_retired[i,j,k]
                @. assi_retired_f[i,j,k,:,:] = assi_retired[i,j,k]
                @. val_retired_f[i,j,k,:,:] = val_retired[i,j,k]
                @. inc_retired_f[i,j,k,:,:] = inc_retired[i,j,k]
            end
        end
    end

    next_value_array1 = val_retired[1,:,:]
    con_over50, ass_over50, assi_over50, val_over50, choice_over50, inc_over50 = solve_over_50(delta,lambda_e,lambda_n,
                                            asset_grid,u_grid,u_transition,a_grid,
                                            a_weights,over_50_periods,next_value_array1)
    @everywhere GC.gc()
    next_value_array2 = val_over50[1,:,:,:,:]
    con_under50, ass_under50, assi_under50, val_under50, choice_under50, inc_under50 = solve_until_50(delta,lambda_e,lambda_n,asset_grid,
                                                u_grid,u_transition,a_grid,a_weights,
                                                until_50_periods,next_value_array2)

    println("solveall")
    #println(assi_under50[1,5,6,1,5])

    con_all = cat(con_under50, con_over50, con_retired_f;dims=1)
    ass_all = cat(ass_under50, ass_over50, ass_retired_f;dims=1)
    assi_all = cat(assi_under50, assi_over50, assi_retired_f;dims=1)
    val_all = cat(val_under50, val_over50,val_retired_f;dims=1)
    inc_all = cat(inc_under50, inc_over50,inc_retired_f;dims=1)
    choice_all = cat(choice_under50,choice_over50;dims=1)

    # println(assi_all[1,5,6,1,5])

    return con_all, ass_all, assi_all, val_all, choice_all, inc_all
end

# function solve_delta_grid(delta_grid,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
#                         a_weights,until_50_periods,
#                         over_50_periods,retiree_periods)
#
#     state_count = 6
#     delta_size = sizeof(delta_grid)
#     a_size = sizeof(a_grid)
#     u_size = sizeof(u_grid)
#     asset_size = sizeof(asset_grid)
#     total_periods = until_50_periods + over_50_periods + retiree_periods
#
#     con_all = Array{Float64}(undef,delta_size,total_periods,asset_size,u_size,state_count,a_size)
#     ass_all = Array{Float64}(undef,delta_size,total_periods,asset_size,u_size,state_count,a_size)
#     assi_all = Array{Int64}(undef,delta_size,total_periods,asset_size,u_size,state_count,a_size)
#     val_all = Array{Float64}(undef,delta_size,total_periods,asset_size,u_size,state_count,a_size)
#     choice_all = Array{Int64}(undef,delta_size,total_periods,asset_size,u_size,state_count,a_size)
#     inc_all = Array{Float64}(undef,delta_size,total_periods,asset_size,u_size,state_count,a_size)
#
#     for i = 1:delta_grid
#         con_1, ass_1, assi_1, val_1, choice_1, inc_1 = solve_all(delta,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
#                                 a_weights,until_50_periods,
#                                 over_50_periods,retiree_periods)
#     con_all[i,:,:,:,:,:] = con_1
#     ass_all[i,:,:,:,:,:] = ass_1
#     assi_all[i,:,:,:,:,:] = assi_1
#     val_all[i,:,:,:,:,:] = val_1
#     choice_all[i,:,:,:,:,:] = choice_1
#     inc_all[i,:,:,:,:,:] = inc_1
#     end
#
#     return con_all, ass_all, assi_all, val_all, choice_all, inc_all
#
# end

function save_solve_dg_output(delta_grid,lambda_e,lambda_n,con, ass, assi, val, choice, inc)
    dg_size = size(delta_grid,1)
    tag = string("solve_delta_51-100_grid_", dg_size, "_lam_e_", lambda_e, "_lam_n_", lambda_n)
    tag = replace(tag,"0." => "")
    file_name = string(tag,".jld2")
    println(file_name)
    save(file_name,Dict("delta_grid" => delta_grid,"con" => con, "ass" => ass, "assi" => assi, "val" => val, "choice" => choice, "inc" => inc))
end

function solve_save_delta_grid(delta_grid,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
                        a_weights,until_50_periods,
                        over_50_periods,retiree_periods)

    state_count = 6
    delta_size = size(delta_grid,1)
    a_size = size(a_grid,1)
    u_size = size(u_grid,1)
    asset_size = size(asset_grid,1)
    total_periods = until_50_periods + over_50_periods + retiree_periods

    con_io = open("con1.bin","w+")
    ass_io = open("ass1.bin","w+")
    assi_io = open("assi1.bin","w+")
    val_io = open("val1.bin","w+")
    choice_io = open("choice1.bin","w+")
    inc_io = open("inc1.bin","w+")

    con = Mmap.mmap(con_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
    ass = Mmap.mmap(ass_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
    assi = Mmap.mmap(assi_io,Array{Int64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
    val = Mmap.mmap(val_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))
    choice = Mmap.mmap(choice_io,Array{Int64,6},(delta_size,(until_50_periods+over_50_periods),asset_size,u_size,state_count,a_size))
    inc = Mmap.mmap(inc_io,Array{Float64,6},(delta_size,total_periods,asset_size,u_size,state_count,a_size))


    for i = 1:delta_size
        delta_1 = delta_grid[i]
        con_1, ass_1, assi_1, val_1, choice_1, inc_1 = solve_all(delta_1,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
                                a_weights,until_50_periods,
                                over_50_periods,retiree_periods)
        con[i,:,:,:,:,:] = con_1
        ass[i,:,:,:,:,:] = ass_1
        assi[i,:,:,:,:,:] = assi_1
        val[i,:,:,:,:,:] = val_1
        choice[i,:,:,:,:,:] = choice_1
        inc[i,:,:,:,:,:] = inc_1
    end

    Mmap.sync!(con)
    Mmap.sync!(ass)
    Mmap.sync!(assi)
    Mmap.sync!(val)
    Mmap.sync!(choice)
    Mmap.sync!(inc)

    save_solve_dg_output(delta_grid,lambda_e,lambda_n,con, ass, assi, val, choice, inc)

    close(con_io)
    close(ass_io)
    close(assi_io)
    close(val_io)
    close(choice_io)
    close(inc_io)

    rm("con1.bin")
    rm("ass1.bin")
    rm("assi1.bin")
    rm("val1.bin")
    rm("choice1.bin")
    rm("inc1.bin")

    return 1

end

function save_solve_all_output(delta,lambda_e,lambda_n,con, ass, assi, val, choice, inc)
    tag = string("solve_mats_delta_", delta, "_lam_e_", lambda_e, "_lam_n_", lambda_n)
    tag = replace(tag,"0." => "")
    file_name = string(tag,".jld2")
    println(file_name)
    save(file_name,Dict("con" => con, "ass" => ass, "assi" => assi, "val" => val, "choice" => choice, "inc" => inc))
end



# function save_solve_all_output_hold_break(delta,lambda_e,lambda_n,con, ass, assi, val, choice, inc)
#     tag = string("solve_mats_delta_", delta, "_lam_e_", lambda_e, "_lam_n_", lambda_n)
#     tag = replace(tag,"0." => "")
#     file_name = string("./hold/",tag,".jld2")
#     println(file_name)
#     save(file_name,Dict("con" => con, "ass" => ass, "assi" => assi, "val" => val, "choice" => choice, "inc" => inc))
#
#     for i = 1:total_periods
#         for j = 1:asset_size
#             for k = 1:sizeof(u_grid)
#                 for l = 1:state_count
#                     for m = 1:sizeof(a_grid)
#                         con_x = con[i,j,k,l,m]
#                         ass_x = ass[i,j,k,l,m]
#                         assi_x = assi[i,j,k,l,m]
#                         val_x = val[i,j,k,l,m]
#                         choice_x = choice[i,j,k,l,m]
#                         inc_x = inc[i,j,k,l,m]
#
#                         tag = string("break_delta_", delta, "_lam_e_", lambda_e,
#                         "_lam_n_", lambda_n,"_period_",i,"_assets_",j,
#                         "_u_",k,"_state_",l,"_a_",m)
#                         tag = replace(tag,"0." => "")
#                         file_name = string("./hold/",tag,".jld2")
#
#                         save(file_name,Dict("con" => con_x, "ass" => ass_x, "assi" => assi_x, "val" => val_x, "choice" => choice_x, "inc" => inc_x))
#                     end
#                 end
#             end
#         end
#     end
# end

# function save_delta_grid_output(delta_grid,lambda_e,lambda_n,con, ass, assi, val, choice, inc)
#     delta_size = sizeof(delta_grid)
#     tag = string("solve_mats_0-50_delta_size_", delta_size, "_lam_e_", lambda_e, "_lam_n_", lambda_n)
#     tag = replace(tag,"0." => "")
#     file_name = string(tag,".jld2")
#     println(file_name)
#     save(file_name,Dict("delta_grid" => delta_grid, "a_grid" => a_grid, "u_grid" => u_grid, "asset_grid" => asset_grid,
#                         "a_weights" => a_weights, "u_transition" => u_transition,
#                         "P_zeta" => P_zeta,
#                         "until_50_periods" => until_50_periods,"over_50_periods" => over_50_periods,
#                             "retiree_periods" => retiree_periods,
#                         "con" => con, "ass" => ass, "assi" => assi, "val" => val, "choice" => choice, "inc" => inc))
# end

a = precompile(solve_last_period,(Array{Float64,1},Array{Float64,1}))
b_ = precompile(solve_retirement,(Array{Float64,1},Array{Float64,1},Int64))
c = precompile(solve_over_50,(Float64,Float64,Float64,Array{Float64,1},
            Array{Float64,1},Array{Float64,2},Array{Float64,1},Array{Float64,1}
            ,Int64,Array{Float64,2}))

d = precompile(solve_over_50,(Float64,Float64,Float64,Array{Float64,1},
            Array{Float64,1},Array{Float64,2},Array{Float64,1},Array{ Float64,1}
            ,Int64,Array{Float64,2}))
e = precompile(solve_all,(Float64,Float64,Float64,Array{Float64,1},Array{Float64,1},Array{Float64,2},Array{Float64,1},
                        Array{Float64,1},Int64,
                        Int64,Int64))

println(a," ",b_," ",c," ",d," ",e)

# println("retirement")
# @time con1, ass1, assi1, val1 = solve_retirement(asset_grid,u_grid,retiree_periods)
# # @time con, ass, assi, val = solve_retirement(asset_grid,u_grid,retiree_periods)
# # @time con, ass, assi, val = solve_retirement(asset_grid,u_grid,retiree_periods)
# # @time con, ass, assi, val = solve_retirement(asset_grid,u_grid,retiree_periods)
#
# next_value_array = val1[1,:,:]
# println("over 50")
# @time con2, ass2, assi2, val2, choice2 = solve_over_50(delta,lambda_e,lambda_n,
#                                         asset_grid,u_grid,u_transition,a_grid,
#                                         a_weights,over_50_periods,next_value_array)
# # @time con, ass, assi, val, choice = solve_over_50(delta,lambda_e,lambda_n,
# #                                         asset_grid,u_grid,u_transition,a_grid,
# #                                         a_weights,over_50_periods,next_value_array)
# # @time solve_over_50(asset_grid,u_grid,u_transition,a_grid,a_weights,over_50_periods,next_value_array)
# # @time solve_over_50(asset_grid,u_grid,u_transition,a_grid,a_weights,over_50_periods,next_value_array)
#
# next_value_array = val2[1,:,:,:,:]
# println("until 50")
# @time con3, ass3, assi3, val3, choice3 = solve_until_50(delta,lambda_e,lambda_n,asset_grid,
#                                             u_grid,u_transition,a_grid,a_weights,
#       +                                      until_50_periods,next_value_array)
# # @time con, ass, assi, val, choice = solve_until_50(delta,lambda_e,lambda_n,asset_grid,
# #                                             u_grid,u_transition,a_grid,a_weights,
# #                                             until_50_periods,next_value_array)

# @time con, ass, assi, val, choice, inc = solve_all(delta,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
#                         a_weights,until_50_periods,
#                         over_50_periods,retiree_periods)
#
# @time save_solve_all_output(delta,lambda_e,lambda_n,con, ass, assi, val, choice, inc)

#delta_grid = Array(range(0,stop=1,length=101))
delta_grid = Array(.51:.01:1)

# delta_grid = Array(range(0,stop=1,length=8))

# @save "delta_g1.jld2" delta_grid

@time solve_save_delta_grid(delta_grid,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
                        a_weights,until_50_periods,
                        over_50_periods,retiree_periods)

# delta_grid1 = Array(0:.01:1)
#
# @time con, ass, assi, val, choice, inc = solve_delta_grid(delta_grid1,lambda_e,lambda_n,asset_grid,u_grid,u_transition,a_grid,
#                         a_weights,until_50_periods,
#                         over_50_periods,retiree_periods)
# #
# @time save_delta_grid_output(delta_grid1,lambda_e,lambda_n,con, ass, assi, val, choice, inc)

nothing
