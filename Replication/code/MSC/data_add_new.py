# %%
import numpy as np
import pandas as pd

key_cols = [
    "yyyy",
    "yyyymm",
    "ehsgrd",
    "eclgrd",
    "income",
    "sex",
    "marry",
    "age",
    "bexp",
    "pexp",
    "dur",
    "unemp",
    "wt",
]
# %%
# load data
data_new = pd.read_csv("../../raw/MSC/ms_data_1.csv", low_memory=False)
data_new.columns = [x.lower() for x in list(data_new.columns)]
data_new = data_new[key_cols]

data_new2 = pd.read_csv("../../raw/MSC/ms_data_2.csv", low_memory=False)
data_new2.columns = [x.lower() for x in list(data_new2.columns)]
data_new2 = data_new2[key_cols]

data_old = pd.read_stata("../../raw/MSC/ms_pre1978.dta")
data_old = data_old[key_cols]

# %%
new_obs_to_use = (
    (data_new2["yyyy"] > 2012)
    | (data_new2["yyyymm"] == 201211)
    | (data_new2["yyyymm"] == 201212)
)
data_new2 = data_new2.loc[new_obs_to_use, :]


# %%
# set spaces to missing
def clean_spaces(series):
    series_temp = series.copy()
    series_temp = series_temp.str.strip()
    drops = series_temp == ""
    series_temp[drops] = np.nan
    series_temp = series_temp.astype(float)
    return series_temp


series_to_int = ["ehsgrd", "eclgrd", "sex", "marry", "age", "income"]
for i, x in enumerate(series_to_int):
    data_new.loc[:, x] = clean_spaces(data_new.loc[:, x])
    data_new2.loc[:, x] = clean_spaces(data_new2.loc[:, x])

# %%
data_new.loc[data_new.ehsgrd == 5, "ehsgrd"] = 0
data_new.loc[data_new.eclgrd == 5, "eclgrd"] = 0

data_new.loc[data_new.marry == 3, "marry"] = 2
data_new.loc[data_new.marry == 4, "marry"] = 2
data_new.loc[data_new.marry == 5, "marry"] = 2


# %%
data_new = pd.concat([data_new, data_new2], axis=0)

# %%
# now clear bad values
bad_value_map = [
    ["ehsgrd", [8, 9]],
    ["eclgrd", [8, 9]],
    ["bexp", [8, 9]],
    ["pexp", [8, 9]],
    ["dur", [8, 9]],
    ["unemp", [8, 9]],
]

for i, x in enumerate(bad_value_map):
    series_name = x[0]
    bad_vals = x[1]
    drops = data_new[series_name].isin(bad_vals)
    data_new.loc[drops, series_name] = np.nan

# %%
# put data together
# %%
# put data together
out_data = pd.concat([data_old, data_new], axis=0)

# %%
# export data
out_data.to_stata("../../raw/ms_all_1953_2018.dta", write_index=False)

# %%
# Done
