using LinearAlgebra
include("params.jl")

function utility(consumption, P)
    num = (consumption * exp(eta * P)) ^ (1-gamma)
    den = 1 - gamma
    return num / den
end

function detwage(age)
    return exp(alpha + beta_1 * age + beta_2 * (age ^ 2))
end

function fullwage(age,u,a)
    return detwage(age) * exp(u) * exp(a)
end

function quarterly_income(age,u,a)
    return h * fullwage(age,u,a)
end

function estimated_avg_wage(u)
    return detwage(est_avg_income_age) * exp(u)
end

function est_avg_income(u)
    return h * estimated_avg_wage(u)
end

function unemployment_amount(wage_prior_to_unemployment)
    return b * h * wage_prior_to_unemployment
end

function unemployment_income_amount(income_prior_to_unemployment)
    return b * income_prior_to_unemployment
end

function net_income(gross_income)
    net = ((1 - tau_w) * gross_income) - standard_deduction
    if net >= 0
        return net
    else
        return 0
    end
end

function food_stamps_amount(gross_income)
    net_inc = net_income(gross_income)
    if net_inc <= poverty_line
        allocation = max_food_stamp_allotment - .3 * net_inc
        if allocation > 0
            return allocation
        else
            return 0
        end
    else
        return 0
    end
end

function disability_amount(approx_prior_earnings)
    if approx_prior_earnings <= a_1
        return .9 * approx_prior_earnings
    elseif approx_prior_earnings <= a_2
        return .9 * a_1 + .32 * (approx_prior_earnings - a_1)
    elseif approx_prior_earnings <= a_3
        return .9 * a_1 + .32 * (a_2 - a_1) + .15 * (approx_prior_earnings - a_2)
    else
        return .9 * a_1 + .32 * (a_2 - a_1) + .15 * (a_3 - a_2)
    end
end
