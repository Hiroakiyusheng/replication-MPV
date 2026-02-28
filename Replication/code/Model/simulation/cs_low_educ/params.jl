include("grid_functions.jl")

###################### Model Parameters #######################################
# Constant Parameters
# risk aversion paramater from utility function
const gamma = 1.5
# const gamma = 3
# Probability of an income shock
const P_zeta = .25
# Percent of income given by UI
const b = .75
# Hours worked
const h = 500
# tax on wages
const tau_w = 0
# Max UI benefit
const UI_cap = 3178
# Probability of acceptance to disability if applying
const P_disability_acceptance = .5

# Time Periods
# Periods per year
const periods_per_year = 4
# Start age
const start_age = 23#!!!!!!!!!!!!!!!!!!!!
# Years where you are work eligible
const working_years = 40
const over_50_start_age = 51
# Years of retirement
const retiree_years = 10

const total_years = working_years + retiree_years

const total_periods = total_years * periods_per_year

# Periods
const retiree_periods = retiree_years * periods_per_year
const working_periods = working_years * periods_per_year

const until_50_periods = (50 + 1 - start_age) * periods_per_year
const over_50_periods = (working_years - (50 + 1 - start_age)) * periods_per_year

# Disability/ SS cutoffs
const a_1 = 1203
const a_2 = 7260
const a_3 = 16638

# # initial assets
# const init_A = .001

# Interest rate and discount factor
const r = .015
const R = (1 + r) ^ (1/4)
const beta = 1 / R

###Clint sourced###
const standard_deduction = 6200 / 4
const max_food_stamp_allotment = 203 * 3
# const max_food_stamp_allotment = 1500
const poverty_line = (6970 + 2460) / 4
# poverty_line = max_food_stamp_allotment / .3
###End Clint sourced###

# Age for Deterministic wage when calculating social security and disability
const est_avg_income_age = 50

# Education Varying Parameters
##### Set education level ###############
const education = "low"
# In format low, high
# Discount for working in utility fn
eta_options = [-0.62 -0.55]
# eta_options = @. eta_options * 0 #/ 15
# std dev of income shocks
sigma_zeta_options = [0.095 0.106]
# std dev of job match dist
sigma_a_options =[.226 .229]
# Probability of job destruction
delta_options = [0.049 0.028]
# Job offer Probability
lambda_e_options = [0.67 0.72]
lambda_n_options = [0.76 0.82]
# Fixed cost of working
F_options = [1088 1213]

#Deterministic wage coefficients
alpha_options = [1. .642]
beta_1_options = [0.0486 0.0829]
beta_2_options = [-0.0004816 -0.0007768]



if education == "low"
    const eta = eta_options[1]
    const sigma_zeta = sigma_zeta_options[1]
    const sigma_a = sigma_a_options[1]
    # const delta = delta_options[1]
    # const lambda_e = lambda_e_options[1]
    # const lambda_n = lambda_n_options[1]
    delta = delta_options[1]
    lambda_e = lambda_e_options[1]
    lambda_n = lambda_n_options[1]
    const F = F_options[1]
    const alpha = alpha_options[1]
    const beta_1 = beta_1_options[1]
    const beta_2 = beta_2_options[1]
else
    const eta = eta_options[2]
    const sigma_zeta = sigma_zeta_options[2]
    const sigma_a = sigma_a_options[2]
    delta = delta_options[2]

    lambda_e = lambda_e_options[2]
    lambda_n = lambda_n_options[2]
    const F = F_options[2]
    const alpha = alpha_options[2]
    const beta_1 = beta_1_options[2]
    const beta_2 = beta_2_options[2]
end


###################### Numerical Parameters ###################################

# Min asset grid value
const asset_min = 1000
# max asset grid value
# Note that this must be atleast as great as the maximum income
const asset_max = 500000
# Number of Points on the asset grid
# asset_size = asset_max
# asset_size = round(asset_size)
# asset_size = Int(asset_size)

# note that the grid must not be spaced ane less tightly then asset minimum
asset_size = (asset_max / asset_min) + 10
asset_size = round(asset_size)
asset_size = Int(asset_size)


#Create asset grid
const asset_grid = Array(range(asset_min, stop=asset_max, length=asset_size))

# asset_size = 250
# const asset_grid = gen_logspace(asset_min,asset_max,asset_size)

# const asset_grid = range(asset_min, stop=asset_max, length=asset_size)
# println(asset_grid)
# const asset_space = asset_grid[2] - asset_grid[1]
# const consumption_grid = @.(asset_grid - asset_space)


# Discretize a
a_sigmas = 3.5
a_bins = a_sigmas  * 15
a_bins = 11
# Ensure the number of bins is odd
if (a_bins % 2) != 1
    a_bins = a_bins + 1
end

const a_grid, a_weights = discretize_norm_dist(0,sigma_a,sigma_count=a_sigmas,bins=a_bins)

const cum_a_weights = cumsum(a_weights)


# max value on u grid
# u_bins = u_sigmas * 15
u_bins = 61
# Ensure the number of bins is odd
if (u_bins % 2) != 1
    u_bins = u_bins + 1
end

# Minimum value on u grid
# u_sigmas = 15
u_sigmas = u_bins / 2

delta_sigma_u_decline = 1

sigmas_per_index = 2 * u_sigmas / u_bins

u_decline_for_delta_test = Int(round(delta_sigma_u_decline / sigmas_per_index))

const u_decline_for_delta = maximum([1,u_decline_for_delta_test])

const u_grid, u_transition = discretize_norm_random_walk(0,sigma_zeta,sigma_count=u_sigmas,bins=u_bins)

const cum_u_transition = cumsum(u_transition;dims=1)

disability_cutoff_sigmas = .7 * u_sigmas

disability_cutoff_u = -1 * disability_cutoff_sigmas * sigma_zeta

const disability_cutoff_index = sum(x -> x <= disability_cutoff_u,u_grid)
# println("dis cutoff index ", disability_cutoff_index)
# # Note for until 50 periods
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

const state_count = 6

# There are 6 states, we save 0 to represent N/A
# 0 - N/A
# 1 - Working
#   Choices: To work or quit
const working_state = 1
# 2 - Job Offer, DI ineligible
#   Choices: work or not work
const offer_di_ineligible_state = 2
# 3 - Unemployed DI eligible & UI receiving
#   Choices: To apply for DI or wait for job
const unemployed_ui_state = 3
# 4 - Unemployed DI eligible
#   Choices: To apply for DI or wait for job
const unemployed_di_elig_state = 4
# 5 - Unemployed DI ineligible
#   Choices: no choices, must wait for job or remain unemployed
const unemployed_di_inelig_state = 5
# 6 - Disability
#   Choices: no choices, disability is an absorbing state
const disability_state = 6


# Choices
# 0 - N/A
# 1 - Work
const choose_to_work = 1
# 2 - Don't work
const choose_not_to_work = 2
# 3 - don't apply for DI, i.e. stay unemployed
const choose_to_not_apply_for_di = 3
# 4 - apply for DI
const choose_to_apply_for_di = 4

# Set initial values for sim

const init_assets = 5

const init_u = Int(floor(u_bins / 2) + 1)

# const init_state = 0
#
# const init_a = 0


# #######Testing section for normality of u
using Plots
# size1 = 41
# mid1 = Int(((size1 -1) / 2) + 1)
# count1 = size1 / 2
#
# t = zeros(size1)
# t[mid1] = 1
# println(t)
#
# # u_grid1, u_transition1 = discretize_norm_random_walk(0,sigma_zeta,sigma_count=u_sigmas,bins=u_bins)
# u_grid1, u_transition1 = discretize_norm_random_walk(0,sigma_zeta,sigma_count=count1,bins=size1)
#
# u_transition1 = @. .25 * u_transition1
#
# Imat = Matrix{Float64}(I,size1,size1)
# Imat = @. Imat * .75
#
# u_transition1 = @. u_transition1 + Imat
#
# for i = 1:160
#     global t = u_transition1 * t
# end
# println(t)
# plot(u_grid1,t)
