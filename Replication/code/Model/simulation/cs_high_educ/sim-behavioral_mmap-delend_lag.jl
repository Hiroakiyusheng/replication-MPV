using FileIO, JLD2
using Mmap
using DataFrames, CSV
using Random
Random.seed!(1234)

include("sim_funs_lag.jl")


function simulate_basic_one_beh(rand_nums, until_50_periods,over_50_periods,retiree_periods,consumption_choices, asset_ind_choices::Array{Int64}, choices, income, delta, delta_grid, asset_grid, u_transition, a_weights;verbose=false,fix_per_delta=false,fixed_per_delta=false,u_ind=true)


    asset_size = size(asset_grid,1)
    a_size = size(a_weights,1)
    u_size = size(u_transition,1)

    # Note states defined in parameters

    pre_retirement_periods = until_50_periods+over_50_periods
    total_periods = until_50_periods+over_50_periods+retiree_periods

    # allocate max u array
    max_u_possibilities = Array{Int64,1}(undef,2)
    max_u_possibilities[1] = 1

    # pre calculate no new job offer value
    no_new_job_offer_cutoff = delta + (1 - delta) * (1 - lambda_e)

    # generate tracker indices
    state_array = Array{Int64}(undef,total_periods)
    asset_ind_array = Array{Int64}(undef,total_periods)
    cons_array = Array{Float64}(undef,total_periods)
    inc_array =  zeros(total_periods)
    work_array = zeros(total_periods)
    delta_array = zeros(total_periods)
    p_delta_array = Array{Float64}(undef,total_periods)

    # Indices:
    # 1 - Assets
    # 2 - u
    # 3 - state
    # 4 - a

    # For rand numbers indices are
    # 1 - u shock
    rand_u_shock_index = 1
    # 2 - u transition
    rand_u_index = 2
    # 3 - job offer/ destruction
    rand_job_index = 3
    # 4 - a transition
    rand_a_index = 4
    # 5 - disability success
    rand_disability_index = 5

    # Give initial values
    cur_assets = init_assets
    # cur_assets = 1
    if u_ind == true
        cur_u = init_u
    else
        cur_u = u_ind
    end

    if fix_per_delta
        if fixed_per_delta == false
            cur_p_delta = delta_grid_map(delta,delta_grid)
        else
            cur_p_delta = delta_grid_map(fixed_per_delta,delta_grid)
        end
    else
        cur_p_delta = delta_grid_map(delta,delta_grid)
    end

    cur_state = working_state #employed

    cur_a = map_a(rand_nums[1,rand_a_index])

    state_array[1] = cur_state
    asset_ind_array[1] = cur_assets
    cons_array[1] = consumption_choices[1,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]
    inc_array[1] = income[1,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]
    decision = choices[1,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]

    # get assets
    cur_assets = asset_ind_choices[1,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]

    if decision == 1
        work_array[1] = 1
        rand_job = rand_nums[1,rand_job_index]
        if rand_job < delta
            delta_array[1] = 1
            if verbose
                println("job lost")#
            end
            cur_state = unemployed_ui_state
            max_u_possibilities[2] = cur_u - u_decline_for_delta
            cur_u = maximum(max_u_possibilities)
        elseif rand_job < (delta + (1 - delta) * (1 - lambda_e))
            # nothing
        else
            rand_a = rand_nums[1,rand_a_index]
            new_a = map_a(rand_a)
            if new_a > cur_a
                cur_a = new_a
            end
        end
    end

    # advance u, happens regardless of state
    rand_u_shock = rand_nums[1,rand_u_shock_index]
    rand_u = rand_nums[1,rand_u_index]
    cur_u = next_u(rand_u_shock,rand_u,cur_u)

    n_u = cur_u
    # Loop over until 50 periods
    for i = 2:until_50_periods
        if verbose
            println(i," ",cur_a," ",cur_state)
            println(i," ",cur_p_delta)
        end

        cur_u = n_u

        # record current state

        state_array[i] = cur_state
        asset_ind_array[i] = cur_assets

        # recalculate p_delta
        if fix_per_delta
            nothing
        else
            cur_p_delta = next_delta_map(delta_array,work_array,i,delta,delta_grid)
        end

        cons_array[i] = consumption_choices[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]
        inc_array[i] = income[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]

        # get assets
        cur_assets = asset_ind_choices[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]


        # advance u, happens regardless of state
        rand_u_shock = rand_nums[i,rand_u_shock_index]
        rand_u = rand_nums[i,rand_u_index]
        n_u = next_u(rand_u_shock,rand_u,cur_u)


        # will need rand job in all cases
        rand_job = rand_nums[i,rand_job_index]
        #if employed
        if cur_state == working_state
            # get decision
            decision = choices[i,asset_ind_array[i],cur_u,cur_state,cur_a,cur_p_delta]
            if decision == choose_to_work
                work_array[i] = 1
                # If job destroyed
                if rand_job < delta
                    delta_array[i] = 1
                    if verbose
                        println("job lost")#
                    end
                    cur_state = unemployed_ui_state
                    # decrease u due for unemployment scarring
                    max_u_possibilities[2] = n_u - u_decline_for_delta
                    n_u = maximum(max_u_possibilities)
                    # a not important in this state

                # If no new job offer
                elseif rand_job < no_new_job_offer_cutoff
                    # cur_state = 1
                    # no change to a
                    # cur_a = cur_a

                # if new job offered
                else
                    # cur_state = 1
                    rand_a = rand_nums[i,rand_a_index]
                    new_a = map_a(rand_a)

                    # New job only accepted if it is better than the cur job
                    if new_a > cur_a
                        cur_a = new_a
                    end
                    # cur_a = cur_a
                end

            elseif decision == choose_not_to_work
                if verbose
                    println("no worky")#
                end
                # If new job offer
                if rand_job < lambda_n
                    cur_state = working_state
                    rand_a = rand_nums[i,rand_a_index]
                    cur_a = map_a(rand_a)
                # no job offered
                else
                    # become unemployed
                    cur_state = unemployed_di_elig_state
                    # a won't matter
                end
            else
                println(decision)
                println(i," ",asset_ind_array[i]," ",cur_u," ",cur_state," ",cur_a)
                println(i)
                error("bad decision")
            end

        elseif cur_state == unemployed_ui_state
            # If new job offer
            if rand_job < lambda_n
                cur_state = working_state
                rand_a = rand_nums[i,rand_a_index]
                cur_a = map_a(rand_a)
            # no job offered
            else
                cur_state = unemployed_di_elig_state
                # a won't matter
            end
        elseif cur_state == unemployed_di_elig_state
            if rand_job < lambda_n
                cur_state = working_state
                rand_a = rand_nums[i,rand_a_index]
                cur_a = map_a(rand_a)
            # no job offered
            else
                cur_state = unemployed_di_elig_state
                # a won't matter
            end
        else
            error("bad state")
        end
    end

    # loop over over 50 before retirement periods
    for i = (until_50_periods+1):(pre_retirement_periods)
        if i < pre_retirement_periods
            cur_u = n_u
        end
        # record current state
        state_array[i] = cur_state
        asset_ind_array[i] = cur_assets
        cons_array[i] = consumption_choices[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]
        inc_array[i] = income[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]

        # recalculate p_delta
        if fix_per_delta
            nothing
        else
            cur_p_delta = next_delta_map(delta_array,work_array,i,delta,delta_grid)
        end

        # get assets
        cur_assets = asset_ind_choices[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]


        # will need rand job in all cases
        rand_job = rand_nums[i,rand_job_index]
        #if employed
        if cur_state == working_state
            # advance u
            rand_u_shock = rand_nums[i,rand_u_shock_index]
            rand_u = rand_nums[i,rand_u_index]
            n_u = next_u(rand_u_shock,rand_u,cur_u)

            # get decision
            decision = choices[i,asset_ind_array[i],cur_u,cur_state,cur_a,cur_p_delta]
            if decision == choose_to_work
                work_array[i] = 1
                # If job destroyed
                if rand_job < delta
                    delta_array[i] = 1
                    cur_state = unemployed_ui_state
                    # decrease u due for unemployment scarring
                    max_u_possibilities[2] = cur_u - u_decline_for_delta
                    cur_u = maximum(max_u_possibilities)
                    # a not important in this state

                # If no new job offer
                elseif rand_job < no_new_job_offer_cutoff
                    # cur_state = 1
                    # no change to a
                    # cur_a = cur_a

                # if new job offered
                else
                    # cur_state = 1
                    rand_a = rand_nums[i,rand_a_index]
                    new_a = map_a(rand_a)

                    # New job only accepted if it is better than the cur job
                    if new_a > cur_a
                        cur_a = new_a
                    end
                    # cur_a = cur_a
                end

            elseif decision == choose_not_to_work
                if verbose
                    println("no worky")#
                end
                # If new job offer
                if rand_job < lambda_n
                    cur_state = working_state
                    rand_a = rand_nums[i,rand_a_index]
                    cur_a = map_a(rand_a)
                # no job offered
                else
                    # become unemployed
                    cur_state = unemployed_di_elig_state
                    # a won't matter
                end
            else
                error("bad decision")
            end
        elseif cur_state == offer_di_ineligible_state
            # advance u
            rand_u_shock = rand_nums[i,rand_u_shock_index]
            rand_u = rand_nums[i,rand_u_index]
            n_u = next_u(rand_u_shock,rand_u,cur_u)

            # get decision
            decision = choices[i,asset_ind_array[i],cur_u,cur_state,cur_a,cur_p_delta]
            # Recall decision 1 is to work decision 2 is to not work

            # If they work
            if decision == choose_to_work
                work_array[i] = 1
                # If job destroyed
                if rand_job < delta
                    delta_array[i] = 1
                    cur_state = unemployed_ui_state
                    # decrease u due for unemployment scarring
                    max_u_possibilities[2] = cur_u - u_decline_for_delta
                    cur_u = maximum(max_u_possibilities)
                    # a not important in this state

                # If no new job offer
                elseif rand_job < no_new_job_offer_cutoff
                    # cur_state = 1
                    # no change to a
                    # cur_a = cur_a

                # if new job offered
                else
                    # cur_state = 1
                    rand_a = rand_nums[i, rand_a_index]
                    new_a = map_a(rand_a)

                    # New job only accepted if it is better than the cur job
                    if new_a > cur_a
                        cur_a = new_a
                    end
                    # cur_a = cur_a
                end
            # if they don't work
            elseif decision == choose_not_to_work
                if verbose
                    println("no worky")#
                end
                # If new job offer
                if rand_job < lambda_n
                    cur_state = offer_di_ineligible_state
                    rand_a = rand_nums[i,rand_a_index]
                    cur_a = map_a(rand_a)
                # no job offered
                else
                    # become unemployed
                    cur_state = unemployed_di_inelig_state
                    # a won't matter
                end
            else
                error("bad decision")
            end
        elseif cur_state == unemployed_ui_state
            # get decision
            decision = choices[i,asset_ind_array[i],cur_u,cur_state,cur_a,cur_p_delta]
            # recall 3 is to not apply for DI
            # 4 is to apply

            if decision == choose_to_not_apply_for_di
                # advance u
                rand_u_shock = rand_nums[i,rand_u_shock_index]
                rand_u = rand_nums[i,rand_u_index]
                n_u = next_u(rand_u_shock,rand_u,cur_u)

                # If new job offer
                if rand_job < lambda_n
                    cur_state = working_state
                    rand_a = rand_nums[i,rand_a_index]
                    cur_a = map_a(rand_a)
                # no job offered
                else
                    cur_state = unemployed_di_elig_state
                    # a won't matter
                end

            elseif decision == choose_to_apply_for_di
                rand_disability = rand_nums[i,rand_disability_index]

                # accepted for di
                if rand_disability < P_disability_acceptance
                    cur_state = disability_state
                    # a no longer matters
                    # u fixed

                # rejected for di
                else
                    # advance u
                    rand_u_shock = rand_nums[i,rand_u_shock_index]
                    rand_u = rand_nums[i,rand_u_index]
                    n_u = next_u(rand_u_shock,rand_u,cur_u)
                    # must stay unemployed to apply
                    cur_state = unemployed_di_inelig_state
                    # a doesn't matter
                end
            else
                if i == pre_retirement_periods
                    # next period is retirement
                    # no u shock
                    # no a shock
                    # state doesn't matter will be set to 6
                else
                    error("bad choice")
                end
            end

        elseif cur_state == unemployed_di_elig_state
            # get decision
            decision = choices[i,asset_ind_array[i],cur_u,cur_state,cur_a,cur_p_delta]
            # recall 3 is to not apply for DI
            # 4 is to apply

            if decision == choose_to_not_apply_for_di
                # advance u
                rand_u_shock = rand_nums[i,rand_u_shock_index]
                rand_u = rand_nums[i,rand_u_index]
                n_u = next_u(rand_u_shock,rand_u,cur_u)

                # If new job offer
                if rand_job < lambda_n
                    cur_state = working_state
                    rand_a = rand_nums[i,rand_a_index]
                    cur_a = map_a(rand_a)
                # no job offered
                else
                    cur_state = unemployed_di_elig_state
                    # a won't matter
                end

            elseif decision == choose_to_apply_for_di
                # println("hello1")
                rand_disability = rand_nums[i,rand_disability_index]

                # accepted for disability
                if rand_disability < P_disability_acceptance
                    # println("hello2")
                    # println(i)
                    cur_state = disability_state
                    # a no longer matters
                    # u fixed

                # rejected for disability
                else
                    # advance u
                    rand_u_shock = rand_nums[i,rand_u_shock_index]
                    rand_u = rand_nums[i,rand_u_index]
                    n_u = next_u(rand_u_shock,rand_u,cur_u)

                    # must stay unemployed to apply
                    cur_state = unemployed_di_inelig_state
                    # a doesn't matter
                end
            else
                if i == pre_retirement_periods
                    # next period is retirement
                    # no u shock
                    # no a shock
                    # state doesn't matter will be set to 6
                else
                    error("bad choice")
                end
            end

        elseif cur_state == unemployed_di_inelig_state
            # no choices

            rand_u_shock = rand_nums[i,rand_u_shock_index]
            rand_u = rand_nums[i,rand_u_index]
            n_u = next_u(rand_u_shock,rand_u,cur_u)

            # If new job offer
            if rand_job < lambda_n
                cur_state = offer_di_ineligible_state
                rand_a = rand_nums[i,rand_a_index]
                cur_a = map_a(rand_a)
            # no job offered
            else
                # still unemployed
                cur_state = unemployed_di_inelig_state
                # a won't matter
            end

        elseif cur_state == disability_state
            # no change in anything
            # cur_state = disability_state
            # cur_u = cur_u
            # a doesn't matter
        else
            error("bad state")
        end
    end

    # now on di / retirement
    cur_state = 6

    # loop over retirement periods
    for i = (pre_retirement_periods+1):(total_periods)
        # println(i,"f")
        # println(cur_assets)
        # record current state
        state_array[i] = cur_state
        asset_ind_array[i] = cur_assets
        cons_array[i] = consumption_choices[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]
        inc_array[i] = income[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]

        # get assets
        cur_assets = asset_ind_choices[i,cur_assets,cur_u,cur_state,cur_a,cur_p_delta]

        # state, u fixed and a irrelevant

    end
    return state_array, asset_ind_array, cons_array, inc_array, work_array, delta_array
end


println("file open")

delta_grid = Array(0:.01:1)

state_count = 6
delta_size = size(delta_grid,1)
a_size = 11
u_size = 61
asset_size = 510
total_periods = 200


con_io = open("./mmap_hold/con-101hold.bin","r")
ass_io = open("./mmap_hold/ass-101hold.bin","r")
assi_io = open("./mmap_hold/assi-101hold.bin","r")
val_io = open("./mmap_hold/val-101hold.bin","r")
choice_io = open("./mmap_hold/choice-101hold.bin","r")
inc_io = open("./mmap_hold/inc-101hold.bin","r")


con = Mmap.mmap(con_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
ass = Mmap.mmap(ass_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
assi = Mmap.mmap(assi_io,Array{Int64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
val = Mmap.mmap(val_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))
choice = Mmap.mmap(choice_io,Array{Int64,6},(160,asset_size,u_size,state_count,a_size,delta_size))
inc = Mmap.mmap(inc_io,Array{Float64,6},(total_periods,asset_size,u_size,state_count,a_size,delta_size))


Mmap.sync!(con)
Mmap.sync!(ass)
Mmap.sync!(assi)
Mmap.sync!(val)
Mmap.sync!(choice)
Mmap.sync!(inc)


N = 10000
len = total_years * periods_per_year
work_all = Array{Float64}(undef,N,len)
inc_all = Array{Float64}(undef,N,len)
con_all = Array{Float64}(undef,N,len)
ass_all = Array{Float64}(undef,N,len)
p_delta_all = Array{Float64}(undef,N,len)

println("rand time")
# @time shared_rand = rand(N,160,5)
# @time @sync @distributed for i = 1:N
println("sim time")
@time for i = 1:N
           # rand_nums = shared_rand[i,:,:]
           rand_nums = rand(160,5)
           # state_array, asset_ind_array, cons_array,inc_array, work_array = simulate_basic_one_beh(rand_nums,until_50_periods,over_50_periods,retiree_periods,con, assi, choice, inc, delta, delta_grid, asset_grid, u_transition, a_weights)
           state_array, asset_ind_array, cons_array,inc_array, work_array, d_array =  simulate_basic_one_beh(rand_nums,until_50_periods,over_50_periods,retiree_periods,con, assi, choice, inc, delta, delta_grid, asset_grid, u_transition, a_weights)

           work_all[i,:] = work_array
           inc_all[i,:] = inc_array
           con_all[i,:] = cons_array
           # print(maximum(asset_ind_array))
           act_ass = asset_grid[asset_ind_array]
           ass_all[i,:] = act_ass
           p_delta_all[i,:] = get_p_delta_path(d_array,work_array,delta)

end
# generate out data for regs
# generate out data for regs
periods_considered = 200
num_entries = N * periods_considered
agent_out_array = Array{Int64,1}(undef,num_entries)
period_out_array = Array{Int64,1}(undef,num_entries)
income_out_array = Array{Float64,1}(undef,num_entries)
asset_out_array = Array{Float64,1}(undef,num_entries)
cons_out_array = Array{Float64,1}(undef,num_entries)
work_out_array = Array{Float64,1}(undef,num_entries)
p_delta_out_array = Array{Float64,1}(undef,num_entries)

agent_ids = Array(1:N)
for i = 1:periods_considered
    begin_ind = N * (i-1) + 1
    end_ind = N * i

    @. period_out_array[begin_ind:end_ind] = i
    agent_out_array[begin_ind:end_ind] = agent_ids
    income_out_array[begin_ind:end_ind] = inc_all[:,i]
    asset_out_array[begin_ind:end_ind] = ass_all[:,i]
    cons_out_array[begin_ind:end_ind] = con_all[:,i]
    work_out_array[begin_ind:end_ind] = work_all[:,i]
    p_delta_out_array[begin_ind:end_ind] = p_delta_all[:,i]
end

out_df = DataFrame(period = period_out_array,
                    id = agent_out_array,
                    income = income_out_array,
                    assets = asset_out_array,
                    consumption = cons_out_array,
                    work = work_out_array,
                    p_delta = p_delta_out_array)

CSV.write("reg_data-beh_1.csv",out_df)

println("close up files")

close(con_io)
close(ass_io)
close(assi_io)
close(val_io)
close(choice_io)
close(inc_io)
#
# rm("con.bin")
# rm("ass.bin")
# rm("assi.bin")
# rm("val.bin")
# rm("choice.bin")
# rm("inc.bin")
