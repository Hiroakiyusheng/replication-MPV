######################################################################
# Content: generate unemployment experience measures for heads of household from PSID.
# Input files: 1. "individual_for_exp_state_lagged_1.dta"
#              2. "individual_for_exp_personal_lagged_1.dta""
#              3. "../../raw/state_UE_1976_2017.dta"
#              4. "../../raw/nat_UE_1890_2017.dta"
# Output files: 1. "individual_exp_state_nat_lagged_1.dta"
#               2. "individual_exp_state_nat_lagged_1_lambda3"
#               3. "individual_exp_personal_lagged_1.dta"
#               4. "individual_exp_personal_lagged_1_lambda3" 
#               5. "individual_exp_state_nat_lagged_1g.dta"
#               6. "individual_exp_state_nat_lagged_3g.dta"
#               7. "individual_exp_personal_lagged_1g.dta"
#               8. "individual_exp_personal_lagged_3g.dta"
######################################################################
setwd("../../data/PSID")
#install.packages("foreign")
library(foreign)

#################################################################################  
## Part I: generate 1-year lagged state-level exp for lambda = 1
  heads = read.dta("individual_for_exp_state_lagged_1.dta")
  UE_state = read.dta("../../raw/state_UE_1976_2017.dta")
  UE = read.dta("../../raw/nat_UE_1890_2017.dta")
  rate = UE$UE_rate
  year = heads$year
  age = heads$age
  mark = heads$mark
  gsa = heads$GSA
  exp_state_5_lagged_1 = numeric()

  lambda = 1
# lambda = 3
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

# generate state-level and national-level combined exp measure
  exp_state_nat_lagged_1 = apply(heads, 1, function(x) {
    # needs to have mark = 1
    if (x[4] == 0) {
      exp_state_nat_lagged_1 = NA
    }
    # if 7 years old, then the lagged five years is the entire experience
    else if (x[3] == 7) {
      exp_state_nat_lagged_1 = x[6]
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
      exp_state_nat_lagged_1 = numer/denom
    }
    return(exp_state_nat_lagged_1)
  })
  heads = cbind(heads, exp_state_nat_lagged_1)
  
  write.dta(heads, "individual_exp_state_nat_lagged_1.dta")

  #################################################################################
  ## Part II: generate 1-year lagged state-level exp for lambda = 3
  heads = read.dta("individual_for_exp_state_lagged_1.dta")
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
  exp_state_nat_lagged_1 = apply(heads, 1, function(x) {
    # needs to have mark = 1
    if (x[4] == 0) {
      exp_state_nat_lagged_1 = NA
    }
    # if 7 years old, then the lagged five years is the entire experience
    else if (x[3] == 7) {
      exp_state_nat_lagged_1 = x[6]
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
      exp_state_nat_lagged_1 = numer/denom
    }
    return(exp_state_nat_lagged_1)
  })
  exp_state_nat_lagged_l3 = exp_state_nat_lagged_1
  
  heads = cbind(heads, exp_state_nat_lagged_l3)
  
  write.dta(heads, "individual_exp_state_nat_lagged_1_lambda3.dta")
  
###############################################################################  
## Part III: generate lagged 1 year personal unemployment experience 
## using self-reported employment status for lambda=1
  personal = read.dta("individual_for_exp_personal_lagged_1.dta")
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
  # lambda = 3
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
  
  # use "emp2" instead of "emp1"
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_personal2[i] = NA
    }
    else if (year[i] < 1998) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 2:6) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 1999) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:5) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 2001) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:4) { # jrk changed this from 1:3 - I think this was a bug
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      # use previous year to impute for following year (1997 for 1998)
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      emp = emp2[i-1]
      numer = numer + (age[i]-2)^lambda *emp
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      numer = numer + (age[i]-4)^lambda *emp
      emp = emp2[i-3]
      numer = numer + (age[i]-5)^lambda *emp
      numer = numer + (age[i]-6)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    print(i)
  }
  personal = cbind(personal, exp_personal2)
  
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
      # x[7] is exp_personal from above
      # Here we take it, multiply back by its normalization denominator,
      # and scale it by 100 to get percentage points which are comparable to national `rate` below.
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
  personal = cbind(personal, exp_personal_nat)
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

  write.dta(personal, "individual_exp_personal_lagged_1.dta")

#################################################################################    
## Part IV: generate lagged 1 year personal unemployment experience 
## using self-reported employment status for lambda=3
  personal = read.dta("individual_for_exp_personal_lagged_1.dta")
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
  
  # use "emp2" instead of "emp1"
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_personal2[i] = NA
    }
    else if (year[i] < 1998) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 2:6) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 1999) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:5) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 2001) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:4) { # jrk changed this from 1:3 - I think this was a bug
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      # use previous year to impute for following year (1997 for 1998)
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      emp = emp2[i-1]
      numer = numer + (age[i]-2)^lambda *emp
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      numer = numer + (age[i]-4)^lambda *emp
      emp = emp2[i-3]
      numer = numer + (age[i]-5)^lambda *emp
      numer = numer + (age[i]-6)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    print(i)
  }
  personal = cbind(personal, exp_personal2)
  
  ## combine national experience with personal experiences
  # Formula7 in the "exp_formula.docx" file
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
  personal = cbind(personal, exp_personal_nat)
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
  exp_personal_nat_l3 = exp_personal_nat2
  personal = cbind(personal, exp_personal_nat_l3)
  
  write.dta(personal, "individual_exp_personal_lagged_1_lambda3.dta")

#################################################################################  
## Part V: generate 1-year lagged state-level exp for lambda = 1, 
## fills the gap years of the (biennial) PSID by assuming that families stay 
## in the same state and have the same employment status as in the prior year
  heads = read.dta("individual_for_exp_state_lagged_1.dta")
  rate = UE$UE_rate
  year = heads$year
  age = heads$age
  mark = heads$mark
  gsa = heads$GSA
  exp_state_5_lagged_1g = numeric()
  
  lambda = 1
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_state_5_lagged_1g[i] = NA
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
      exp_state_5_lagged_1g[i] = numer/denom
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
      exp_state_5_lagged_1g[i] = numer/denom
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
      unemp1 = year_unemp[location]
      location = gsa[i-1]
      unemp2 = year_unemp[location]
      numer = numer + (age[i]-3)^lambda *0.5*(unemp1 + unemp2)
      # LSS add
      exp_state_5_lagged_1g[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      
      # t-2
      # year-2 location (for year t-2)
      location = gsa[i-1]
      k = year[i] - 1976
      year_unemp = UE_state[, k]
      numer = numer + (age[i]-2)^lambda *year_unemp[location]
      
      # t-3
      k = year[i] - 1977
      year_unemp = UE_state[, k]
      unemp1 = year_unemp[location]
      # year-4 location (for years t-3 and t-4)
      location = gsa[i-2] 
      unemp2 = year_unemp[location]
      numer = numer + (age[i]-3)^lambda *0.5*(unemp1 + unemp2)
      
      # t-4
      k = year[i] - 1978
      year_unemp = UE_state[, k]
      numer = numer + (age[i]-4)^lambda *year_unemp[location]
      
      # t-5
      k = year[i] - 1979
      year_unemp = UE_state[, k]
      unemp1 = year_unemp[location]
      # year-6 location (for years t-5 and t-6)
      location = gsa[i-3]
      unemp2 = year_unemp[location]
      numer = numer + (age[i]-5)^lambda *0.5*(unemp1 + unemp2)
      
      # t-6
      k = year[i] - 1980
      year_unemp = UE_state[, k]
      numer = numer + (age[i]-6)^lambda *year_unemp[location]
      exp_state_5_lagged_1g[i] = numer/denom
    }
    print(i)
  }
  heads = cbind(heads, exp_state_5_lagged_1g)
  
  # generate state-level and national-level blended exp
  exp_state_nat_lagged_1g = apply(heads, 1, function(x) {
    # needs to have mark = 1
    if (x[4] == 0) {
      exp_state_nat_lagged_1g = NA
    }
    # if 7 years old, then the lagged five years is the entire experience
    else if (x[3] == 7) {
      exp_state_nat_lagged_1g = x[6]
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
      exp_state_nat_lagged_1g = numer/denom
    }
    return(exp_state_nat_lagged_1g)
  })
  heads = cbind(heads, exp_state_nat_lagged_1g)
  
  write.dta(heads, "individual_exp_state_nat_lagged_1g.dta")
  

#################################################################################  
## Part VI: generate 1-year lagged state-level exp for lambda = 3, 
## fills the gap years of the (biennial) PSID by assuming that families stay 
## in the same state and have the same employment status as in the prior year  
  heads = read.dta("individual_for_exp_state_lagged_1.dta")
  rate = UE$UE_rate
  year = heads$year
  age = heads$age
  mark = heads$mark
  gsa = heads$GSA
  exp_state_5_lagged_1g = numeric()
  
  lambda = 3
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_state_5_lagged_1g[i] = NA
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
      exp_state_5_lagged_1g[i] = numer/denom
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
      exp_state_5_lagged_1g[i] = numer/denom
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
      unemp1 = year_unemp[location]
      location = gsa[i-1]
      unemp2 = year_unemp[location]
      numer = numer + (age[i]-3)^lambda *0.5*(unemp1 + unemp2)
      # LSS add
      exp_state_5_lagged_1g[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      
      # t-2
      # year-2 location (for year t-2)
      location = gsa[i-1]
      k = year[i] - 1976
      year_unemp = UE_state[, k]
      numer = numer + (age[i]-2)^lambda *year_unemp[location]
      
      # t-3
      k = year[i] - 1977
      year_unemp = UE_state[, k]
      unemp1 = year_unemp[location]
      # year-4 location (for years t-3 and t-4)
      location = gsa[i-2] 
      unemp2 = year_unemp[location]
      numer = numer + (age[i]-3)^lambda *0.5*(unemp1 + unemp2)
      
      # t-4
      k = year[i] - 1978
      year_unemp = UE_state[, k]
      numer = numer + (age[i]-4)^lambda *year_unemp[location]
      
      # t-5
      k = year[i] - 1979
      year_unemp = UE_state[, k]
      unemp1 = year_unemp[location]
      # year-6 location (for years t-5 and t-6)
      location = gsa[i-3]
      unemp2 = year_unemp[location]
      numer = numer + (age[i]-5)^lambda *0.5*(unemp1 + unemp2)
      
      # t-6
      k = year[i] - 1980
      year_unemp = UE_state[, k]
      numer = numer + (age[i]-6)^lambda *year_unemp[location]
      exp_state_5_lagged_1g[i] = numer/denom
    }
    print(i)
  }
  heads = cbind(heads, exp_state_5_lagged_1g)
  
  # generate state-level and national-level blended exp
  exp_state_nat_lagged_3g = apply(heads, 1, function(x) {
    # needs to have mark = 1
    if (x[4] == 0) {
      exp_state_nat_lagged_3g = NA
    }
    # if 7 years old, then the lagged five years is the entire experience
    else if (x[3] == 7) {
      exp_state_nat_lagged_3g = x[6]
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
      exp_state_nat_lagged_3g = numer/denom
    }
    return(exp_state_nat_lagged_3g)
  })
  heads = cbind(heads, exp_state_nat_lagged_3g)
  
  write.dta(heads, "individual_exp_state_nat_lagged_3g.dta")
  
#################################################################################    
## Part VII: generate lagged 1 year personal unemployment experience 
## using self-reported employment status for lambda=1, fill in gap years
  personal = read.dta("individual_for_exp_personal_lagged_1.dta")
  rate = UE$UE_rate
  year = personal$year
  age = personal$age
  mark = personal$mark
  emp1 = personal$EMP1
  emp2 = personal$EMP2
  exp_personalg = numeric()
  exp_personal2 = numeric()
  exp_personal_nat = numeric()
  exp_personal_nat2 = numeric()
  

  lambda = 1
  
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_personalg[i] = NA
    }
    else if (year[i] < 1998) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 2:6) {
        emp = emp1[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personalg[i] = numer/denom
    }
    else if (year[i] == 1999) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:5) {
        emp = emp1[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personalg[i] = numer/denom
    }
    else if (year[i] == 2001) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:4) {
        emp = emp1[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      # use previous year to impute for following year (1997 for 1998)
      emp = 0.5*(emp1[i-2]+emp1[i-1])
      numer = numer + (age[i]-3)^lambda *emp
      exp_personalg[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      emp = emp1[i-1]
      numer = numer + (age[i]-2)^lambda *emp
      emp = 0.5*(emp1[i-2]+emp1[i-1])
      numer = numer + (age[i]-3)^lambda *emp
      emp = emp1[i-2]
      numer = numer + (age[i]-4)^lambda *emp
      emp = 0.5*(emp1[i-3]+emp1[i-2])
      numer = numer + (age[i]-5)^lambda *emp
      emp = emp1[i-3]
      numer = numer + (age[i]-6)^lambda *emp
      exp_personalg[i] = numer/denom
    }
    print(i)
  }
  personal = cbind(personal, exp_personalg)
  
  # use "emp2" instead of "emp1"
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_personal2[i] = NA
    }
    else if (year[i] < 1998) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 2:6) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 1999) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:5) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 2001) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:3) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      # use previous year to impute for following year (1997 for 1998)
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      emp = emp2[i-1]
      numer = numer + (age[i]-2)^lambda *emp
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      numer = numer + (age[i]-4)^lambda *emp
      emp = emp2[i-3]
      numer = numer + (age[i]-5)^lambda *emp
      numer = numer + (age[i]-6)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    print(i)
  }
  personal = cbind(personal, exp_personal2)
  
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
  exp_personal_nat_1g = exp_personal_nat
  personal = cbind(personal, exp_personal_nat_1g)
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
  
  write.dta(personal, "individual_exp_personal_lagged_1g.dta")
  
#################################################################################    
## Part VIII: generate lagged 1 year personal unemployment experience 
## using self-reported employment status for lambda=3, fill in gap years
  personal = read.dta("individual_for_exp_personal_lagged_1.dta")
  rate = UE$UE_rate
  year = personal$year
  age = personal$age
  mark = personal$mark
  emp1 = personal$EMP1
  emp2 = personal$EMP2
  exp_personalg = numeric()
  exp_personal2 = numeric()
  exp_personal_nat = numeric()
  exp_personal_nat2 = numeric()
  
  lambda = 3
  
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_personalg[i] = NA
    }
    else if (year[i] < 1998) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 2:6) {
        emp = emp1[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personalg[i] = numer/denom
    }
    else if (year[i] == 1999) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:5) {
        emp = emp1[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personalg[i] = numer/denom
    }
    else if (year[i] == 2001) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:4) {
        emp = emp1[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      # use previous year to impute for following year (1997 for 1998)
      emp = 0.5*(emp1[i-2]+emp1[i-1])
      numer = numer + (age[i]-3)^lambda *emp
      exp_personalg[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      emp = emp1[i-1]
      numer = numer + (age[i]-2)^lambda *emp
      emp = 0.5*(emp1[i-2]+emp1[i-1])
      numer = numer + (age[i]-3)^lambda *emp
      emp = emp1[i-2]
      numer = numer + (age[i]-4)^lambda *emp
      emp = 0.5*(emp1[i-3]+emp1[i-2])
      numer = numer + (age[i]-5)^lambda *emp
      emp = emp1[i-3]
      numer = numer + (age[i]-6)^lambda *emp
      exp_personalg[i] = numer/denom
    }
    print(i)
  }
  personal = cbind(personal, exp_personalg)
  
  # use "emp2" instead of "emp1"
  for (i in 1:length(year)) {
    if (mark[i] == 0) {
      exp_personal2[i] = NA
    }
    else if (year[i] < 1998) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 2:6) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 1999) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:5) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      exp_personal2[i] = numer/denom
    }
    else if (year[i] == 2001) {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      for (j in 1:3) {
        emp = emp2[i-j]
        numer = numer + (age[i-j]^lambda)*emp
      }
      # use previous year to impute for following year (1997 for 1998)
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    # years 2003 onwards draw from consistent biannual data
    else {
      x = (age[i]-6):(age[i]-2)
      denom = sum(x^lambda)
      numer = 0
      emp = emp2[i-1]
      numer = numer + (age[i]-2)^lambda *emp
      emp = emp2[i-2]
      numer = numer + (age[i]-3)^lambda *emp
      numer = numer + (age[i]-4)^lambda *emp
      emp = emp2[i-3]
      numer = numer + (age[i]-5)^lambda *emp
      numer = numer + (age[i]-6)^lambda *emp
      exp_personal2[i] = numer/denom
    }
    print(i)
  }
  personal = cbind(personal, exp_personal2)
  
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
  exp_personal_nat_3g = exp_personal_nat
  personal = cbind(personal, exp_personal_nat_3g)
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
  
  write.dta(personal, "individual_exp_personal_lagged_3g.dta")
  
  