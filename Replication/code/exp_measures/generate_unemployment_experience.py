import pandas as pd
import itertools as it
import numpy as np

# TODO: Memoize exponentiated weight vector, as weights[], up to max_age
# TODO: Make this use np.dot and np.sum
# Age in periods
def experience(weights, interval, unemp_by_period):
    birth_period, cur_period = interval
    age = cur_period - birth_period
    
    weights = weights[0:age-1]

    denom = np.sum(weights)
    exp = np.dot(weights, unemp_by_period[birth_period+1:cur_period]) / denom

    return exp

def experiences(lambd, intervals, unemp_by_period):
    max_interval = max([b-a for a,b in intervals])
    weights = np.arange(1, max_interval + 1) ** lambd
    res = np.zeros(len(intervals))
    for i in range(len(intervals)):
        res[i] = experience(weights, intervals[i], unemp_by_period)
    return res

def generate_experience(start_year, end_year, periods_per_year, unemp_by_period):

    def valid_interval(birth, current):
        return birth+1 < current

    def period_to_year(p):
        return start_year + int(p / periods_per_year)

    def period_to_term(p):
        return 1 + (p % periods_per_year) # periods are 1-based
    
    def weights(lambd):
        return np.arange(1, (end_year - start_year) * periods_per_year + 1) ** lambd
    
    periods = range((end_year - start_year) * periods_per_year)
    intervals = filter(lambda p: valid_interval(p[0], p[1]),
                       it.product(periods, periods))
    intervals = list(intervals) # need to memoize the iterator for reuse!
    
    exps_lambda1_0  = experiences((1.0), intervals, unemp_by_period)
    exps_lambda1_5  = experiences((1.5), intervals, unemp_by_period)
    exps_lambda2_0  = experiences((2.0), intervals, unemp_by_period)
    exps_lambda3_0  = experiences((3.0), intervals, unemp_by_period)
    
    res = {
        'birth_year':   [period_to_year(birth) for (birth,_) in intervals],
        'birth_term':   [period_to_term(birth) for (birth,_) in intervals],
        'current_year': [period_to_year(cur)   for (_,cur)   in intervals],
        'current_term': [period_to_term(cur)   for (_,cur)   in intervals],
        'experience_lambda1_0': exps_lambda1_0,
        'experience_lambda1_5': exps_lambda1_5,
        'experience_lambda2_0': exps_lambda2_0,
        'experience_lambda3_0': exps_lambda3_0,
    }
    df = pd.DataFrame(res)
    return df

start_year = 1890
end_year = 2018+1

################################ Annual #################################
# Only the _converted file has year from 1890-1920...
unemployment_annual = pd.read_stata('../../raw/nat_UE_1890_2017.dta') \
                        .sort_values(by=['panel_year']).UE_rate
unemp_by_year = np.asarray(unemployment_annual)

df = generate_experience(start_year, end_year, 1, unemp_by_year)
df.to_stata('../../data/MSC/generated_years.dta', write_index=False)

############################### Quarterly ###############################
unemployment_quarterly = pd.read_excel('../../raw/unemployment_raw_q.xlsx')       \
                            .sort_values(by=['panel_year','panel_q'])   \
                            .Civilianunemploymentrate
unemp_by_quarter = np.asarray(unemployment_quarterly)
df = generate_experience(start_year, end_year, 4, unemp_by_quarter)
df.to_stata('../../data/CEX/generated_quarters.dta', write_index=False)

################################ Monthly ################################
unemployment_monthly   = pd.read_excel('../../raw/unemployment_raw_m.xlsx')       \
                            .sort_values(by=['panel_year','month'])     \
                            .Civilianunemploymentrate
unemp_by_month = np.asarray(unemployment_monthly)
df = generate_experience(start_year, end_year, 12, unemp_by_month)
df.to_stata('../../data/Nielsen/generated_months.dta', write_index=False)
