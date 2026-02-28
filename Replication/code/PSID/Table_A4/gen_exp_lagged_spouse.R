################################################################################
# Content: generate unemployment experience measures for heads and spouses of household from PSID.
# Input files: 1. "individual_for_exp_state_lagged_1_spouse.dta"
#              2. "individual_for_exp_personal_lagged_1_spouse.dta""
#              3. "../../raw/state_UE_1976_2017.dta"
#              4. "../../raw/nat_UE_1890_2017.dta"
# Output files: 1. "individual_exp_state_nat_lagged_1.dta"
#               2. "individual_exp_state_nat_lagged_1_lambda3"
#               3. "individual_exp_personal_lagged_1.dta"
#               4. "individual_exp_personal_lagged_1_lambda3" 

# setwd to the directory where this code is stored "./Replication/code/PSID/Table_A4"
################################################################################
#install.packages("foreign")
library(foreign)

#################################################################################  
## Part I: generate 1-year lagged state-level exp for lambda = 1
heads = read.dta("individual_for_exp_state_lagged_1_spouse.dta")
UE_state = read.dta("../../../raw/state_UE_1976_2017.dta")
UE = read.dta("../../../raw/nat_UE_1890_2017.dta")
rate = UE$UE_rate
year = heads$year
age = heads$age
mark = heads$mark
gsa = heads$GSA
exp_state_5_lagged_1 = numeric()

lambda = 1

for (i in 1:length(year)) {
  if (mark[i] == 0) {
    exp_state_5_lagged_1[i] = NA
  }
  else if (year[i] < 1999) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 2:6) {
      location = gsa[i-j]
      unemp_year = year[i-j]
      k = unemp_year - 1974
      # state unemployment data starts in 1976
      year_unemp = UE_state[, k]
      numer = numer + (age[i-j]^lambda)*year_unemp[location]
    }
    exp_state_5_lagged_1[i] = numer/denom
  }
  # After 1997 is 1999 (no 1998 row)
  else if (year[i] == 1999) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:5) {
      location = gsa[i-j]
      unemp_year = year[i-j]
      k = unemp_year - 1974
      year_unemp = UE_state[, k]
      numer = numer + (age[i-j]^lambda)*year_unemp[location]
    }
    exp_state_5_lagged_1[i] = numer/denom
  }
  # next year in data series after 1999 is 2001
  # experience measure for year 2001 with one lag uses data from years 95 96 97 98 99, need to impute 98 data
  else if (year[i] == 2001) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:4) {
      location = gsa[i-j]
      unemp_year = year[i-j]
      k = unemp_year - 1974
      year_unemp = UE_state[, k]
      numer = numer + (age[i-j]^lambda)*year_unemp[location]
    }
    # use 1997 location for 1998
    location = gsa[i-2]
    year_unemp = UE_state[, 24] #year 1998
    numer = numer + (age[i]-3)^lambda *year_unemp[location]
    # LSS add
    exp_state_5_lagged_1[i] = numer/denom
  }
  # years 2003 onwards draw from consistent biannual data
  else {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    # year-2 location for year t-2
    location = gsa[i-1]
    k = year[i] - 1976
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-2)^lambda *year_unemp[location]
    # year-4 location for years t-3 and t-4
    location = gsa[i-2] 
    k = year[i] - 1977
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-3)^lambda *year_unemp[location]
    k = year[i] - 1978
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-4)^lambda *year_unemp[location]
    # year-6 location for years t-5 and t-6
    location = gsa[i-3]
    k = year[i] - 1979
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-5)^lambda *year_unemp[location]
    k = year[i] - 1980
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-6)^lambda *year_unemp[location]
    exp_state_5_lagged_1[i] = numer/denom
  }
  print(i)
}
heads = cbind(heads, exp_state_5_lagged_1)

# generate state-level and national-level blended exp
exp_state_nat_lagged_1s = apply(heads, 1, function(x) {
  # needs to have mark = 1
  if (x[4] == 0) {
    exp_state_nat_lagged_1s = NA
  }
  # if 7 years old, then the lagged five years is the entire experience
  else if (x[3] == 7) {
    exp_state_nat_lagged_1s = x[6]
  }
  else {
    current_age = x[3]
    # only up to years age-2 goes into current experience measure
    m = 1:(current_age-2)
    denom = sum(m^lambda)
    n = (current_age-6):(current_age-2)
    numer = sum(n^lambda)*x[6]
    current_year = x[2]
    for (i in 1:(current_age-7)) {
      unemp_year = current_year - (current_age - i)
      k = unemp_year - 1889
      numer = numer + i^lambda *rate[k]
    }
    exp_state_nat_lagged_1s = numer/denom
  }
  return(exp_state_nat_lagged_1s)
})
heads = cbind(heads, exp_state_nat_lagged_1s)

write.dta(heads, "individual_exp_state_nat_lagged_1_spouse.dta")

#################################################################################
## Part II: generate 1-year lagged state-level exp for lambda = 3

heads = read.dta("individual_for_exp_state_lagged_1_spouse.dta")
rate = UE$UE_rate
year = heads$year
age = heads$age
mark = heads$mark
gsa = heads$GSA
exp_state_5_lagged_1 = numeric()

lambda = 3
for (i in 1:length(year)) {
  if (mark[i] == 0) {
    exp_state_5_lagged_1[i] = NA
  }
  else if (year[i] < 1999) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 2:6) {
      location = gsa[i-j]
      unemp_year = year[i-j]
      k = unemp_year - 1974
      # state unemployment data starts in 1976
      year_unemp = UE_state[, k]
      numer = numer + (age[i-j]^lambda)*year_unemp[location]
    }
    exp_state_5_lagged_1[i] = numer/denom
  }
  # After 1997 is 1999 (no 1998 row)
  else if (year[i] == 1999) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:5) {
      location = gsa[i-j]
      unemp_year = year[i-j]
      k = unemp_year - 1974
      year_unemp = UE_state[, k]
      numer = numer + (age[i-j]^lambda)*year_unemp[location]
    }
    exp_state_5_lagged_1[i] = numer/denom
  }
  # next year in data series after 1999 is 2001
  # experience measure for year 2001 with one lag uses data from years 95 96 97 98 99, need to impute 98 data
  else if (year[i] == 2001) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:4) {
      location = gsa[i-j]
      unemp_year = year[i-j]
      k = unemp_year - 1974
      year_unemp = UE_state[, k]
      numer = numer + (age[i-j]^lambda)*year_unemp[location]
    }
    # use 1997 location for 1998
    location = gsa[i-2]
    year_unemp = UE_state[, 24] #year 1998
    numer = numer + (age[i]-3)^lambda *year_unemp[location]
    # LSS add
    exp_state_5_lagged_1[i] = numer/denom
  }
  # years 2003 onwards draw from consistent biannual data
  else {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    # year-2 location for year t-2
    location = gsa[i-1]
    k = year[i] - 1976
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-2)^lambda *year_unemp[location]
    # year-4 location for years t-3 and t-4
    location = gsa[i-2] 
    k = year[i] - 1977
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-3)^lambda *year_unemp[location]
    k = year[i] - 1978
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-4)^lambda *year_unemp[location]
    # year-6 location for years t-5 and t-6
    location = gsa[i-3]
    k = year[i] - 1979
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-5)^lambda *year_unemp[location]
    k = year[i] - 1980
    year_unemp = UE_state[, k]
    numer = numer + (age[i]-6)^lambda *year_unemp[location]
    exp_state_5_lagged_1[i] = numer/denom
  }
  print(i)
}
heads = cbind(heads, exp_state_5_lagged_1)

# generate state-level and national-level blended exp
exp_state_nat_lagged_l3 = apply(heads, 1, function(x) {
  # needs to have mark = 1
  if (x[4] == 0) {
    exp_state_nat_lagged_l3 = NA
  }
  # if 7 years old, then the lagged five years is the entire experience
  else if (x[3] == 7) {
    exp_state_nat_lagged_l3 = x[6]
  }
  else {
    current_age = x[3]
    # only up to years age-2 goes into current experience measure
    m = 1:(current_age-2)
    denom = sum(m^lambda)
    n = (current_age-6):(current_age-2)
    numer = sum(n^lambda)*x[6]
    current_year = x[2]
    for (i in 1:(current_age-7)) {
      unemp_year = current_year - (current_age - i)
      k = unemp_year - 1889
      numer = numer + i^lambda *rate[k]
    }
    exp_state_nat_lagged_l3 = numer/denom
  }
  return(exp_state_nat_lagged_l3)
})
heads = cbind(heads, exp_state_nat_lagged_l3)

write.dta(heads, "individual_exp_state_nat_lagged_3_spouse.dta")

###############################################################################  
## Part III: generate lagged 1 year personal unemployment experience 
## using self-reported employment status for lambda=1
personal = read.dta("individual_for_exp_personal_lagged_1_spouse.dta")
rate = UE$UE_rate
year = personal$year
age = personal$age
mark = personal$mark
emp1 = personal$EMP1
emp2 = personal$EMP2
exp_personal = numeric()
exp_personal2 = numeric()
exp_personal_nat = numeric()
exp_personal_nat2 = numeric()

lambda = 1

for (i in 1:length(year)) {
  if (mark[i] == 0) {
    exp_personal[i] = NA
  }
  else if (year[i] < 1998) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 2:6) {
      emp = emp1[i-j]
      numer = numer + (age[i-j]^lambda)*emp
    }
    exp_personal[i] = numer/denom
  }
  else if (year[i] == 1999) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:5) {
      emp = emp1[i-j]
      numer = numer + (age[i-j]^lambda)*emp
    }
    exp_personal[i] = numer/denom
  }
  else if (year[i] == 2001) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:3) {
      emp = emp1[i-j]
      numer = numer + (age[i-j]^lambda)*emp
    }
    # use previous year to impute for following year (1997 for 1998)
    emp = emp1[i-2]
    numer = numer + (age[i]-3)^lambda *emp
    exp_personal[i] = numer/denom
  }
  # years 2003 onwards draw from consistent biannual data
  else {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    emp = emp1[i-1]
    numer = numer + (age[i]-2)^lambda *emp
    emp = emp1[i-2]
    numer = numer + (age[i]-3)^lambda *emp
    numer = numer + (age[i]-4)^lambda *emp
    emp = emp1[i-3]
    numer = numer + (age[i]-5)^lambda *emp
    numer = numer + (age[i]-6)^lambda *emp
    exp_personal[i] = numer/denom
  }
  print(i)
}
personal = cbind(personal, exp_personal)


## combine national experience with personal experiences
exp_personal_nat = apply(personal, 1, function(x) {
  if (x[6] == 0) {
    exp_personal_nat = NA
  }
  else if (x[3] == 7) {
    exp_personal_nat = x[7]*100
  }
  else {
    current_age = x[3]
    m = 1:(current_age-2)
    denom = sum(m^lambda)
    n = (current_age-6):(current_age-2)
    numer = sum(n^lambda)*x[7]*100
    current_year = x[2]
    for (i in 1:(current_age-7)) {
      unemp_year = current_year - (current_age - i)
      k = unemp_year - 1889
      numer = numer + i^lambda *rate[k]
    }
    exp_personal_nat = numer/denom
  }
  return(exp_personal_nat)
})
exp_personal_lagged_1 = exp_personal_nat
personal = cbind(personal, exp_personal_lagged_1)
###
exp_personal_nat2 = apply(personal, 1, function(x) {
  if (x[6] == 0) {
    exp_personal_nat2 = NA
  }
  else if (x[3] == 7) {
    exp_personal_nat2 = x[8]*100
  }
  else {
    current_age = x[3]
    m = 1:(current_age-2)
    denom = sum(m^lambda)
    n = (current_age-6):(current_age-2)
    numer = sum(n^lambda)*x[8]*100
    current_year = x[2]
    for (i in 1:(current_age-7)) {
      unemp_year = current_year - (current_age - i)
      k = unemp_year - 1889
      numer = numer + i^lambda *rate[k]
    }
    exp_personal_nat2 = numer/denom
  }
  return(exp_personal_nat2)
})
personal = cbind(personal, exp_personal_nat2)

write.dta(personal, "individual_exp_personal_lagged_1_spouse.dta")

#################################################################################    
## Part IV: generate lagged 1 year personal unemployment experience 
## using self-reported employment status for lambda=3
personal = read.dta("individual_for_exp_personal_lagged_1_spouse.dta")
rate = UE$UE_rate
year = personal$year
age = personal$age
mark = personal$mark
emp1 = personal$EMP1
emp2 = personal$EMP2
exp_personal = numeric()
exp_personal2 = numeric()
exp_personal_nat = numeric()
exp_personal_nat2 = numeric()

lambda = 3

for (i in 1:length(year)) {
  if (mark[i] == 0) {
    exp_personal[i] = NA
  }
  else if (year[i] < 1998) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 2:6) {
      emp = emp1[i-j]
      numer = numer + (age[i-j]^lambda)*emp
    }
    exp_personal[i] = numer/denom
  }
  else if (year[i] == 1999) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:5) {
      emp = emp1[i-j]
      numer = numer + (age[i-j]^lambda)*emp
    }
    exp_personal[i] = numer/denom
  }
  else if (year[i] == 2001) {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    for (j in 1:3) {
      emp = emp1[i-j]
      numer = numer + (age[i-j]^lambda)*emp
    }
    # use previous year to impute for following year (1997 for 1998)
    emp = emp1[i-2]
    numer = numer + (age[i]-3)^lambda *emp
    exp_personal[i] = numer/denom
  }
  # years 2003 onwards draw from consistent biannual data
  else {
    x = (age[i]-6):(age[i]-2)
    denom = sum(x^lambda)
    numer = 0
    emp = emp1[i-1]
    numer = numer + (age[i]-2)^lambda *emp
    emp = emp1[i-2]
    numer = numer + (age[i]-3)^lambda *emp
    numer = numer + (age[i]-4)^lambda *emp
    emp = emp1[i-3]
    numer = numer + (age[i]-5)^lambda *emp
    numer = numer + (age[i]-6)^lambda *emp
    exp_personal[i] = numer/denom
  }
  print(i)
}
personal = cbind(personal, exp_personal)

## combine national experience with personal experiences
exp_personal_nat = apply(personal, 1, function(x) {
  if (x[6] == 0) {
    exp_personal_nat = NA
  }
  else if (x[3] == 7) {
    exp_personal_nat = x[7]*100
  }
  else {
    current_age = x[3]
    m = 1:(current_age-2)
    denom = sum(m^lambda)
    n = (current_age-6):(current_age-2)
    numer = sum(n^lambda)*x[7]*100
    current_year = x[2]
    for (i in 1:(current_age-7)) {
      unemp_year = current_year - (current_age - i)
      k = unemp_year - 1889
      numer = numer + i^lambda *rate[k]
    }
    exp_personal_nat = numer/denom
  }
  return(exp_personal_nat)
})
exp_personal_nat_l3 = exp_personal_nat
personal = cbind(personal, exp_personal_nat_l3)
###
exp_personal_nat2 = apply(personal, 1, function(x) {
  if (x[6] == 0) {
    exp_personal_nat2 = NA
  }
  else if (x[3] == 7) {
    exp_personal_nat2 = x[8]*100
  }
  else {
    current_age = x[3]
    m = 1:(current_age-2)
    denom = sum(m^lambda)
    n = (current_age-6):(current_age-2)
    numer = sum(n^lambda)*x[8]*100
    current_year = x[2]
    for (i in 1:(current_age-7)) {
      unemp_year = current_year - (current_age - i)
      k = unemp_year - 1889
      numer = numer + i^lambda *rate[k]
    }
    exp_personal_nat2 = numer/denom
  }
  return(exp_personal_nat2)
})
personal = cbind(personal, exp_personal_nat2)

write.dta(personal, "individual_exp_personal_lagged_3_spouse.dta")

