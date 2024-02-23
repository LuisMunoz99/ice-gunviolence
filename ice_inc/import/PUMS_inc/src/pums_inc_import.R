# Authors:     LM
# Maintainers: LM
# Date: 21-feb-24
# ===========================================

# Importing PUMS data for income household 
# to establish quintiles for Puerto Rico 

# -- libs ---
if(!require(pacman))install.packages("pacman")
p_load(dplyr,
       here,
       tidycensus,
       tidyr)

# args {{{
args <- list(output =
               here("ice_inc/import/PUMS_inc/output/PUMS_incomeHH.csv"))

data(pums_variables)


pums_vars_2019 <- pums_variables %>% 
  filter(year == 2019, survey == "acs1")

pums_vars_2019 %>% 
  distinct(var_code, var_label, data_type, level)


pums_vars_2018 %>% 
  distinct(var_code, var_label, data_type, level) %>% 
  filter(level == "housing")


# -- import ---
PUMS_inc <- get_pums(
  geography = "tract",
  variables = c("B01003_001","B17001_002","B02001_002","B02001_003"), 
  state = "PR",
  year = 2022,
  survey = "acs5",
  geometry = TRUE,
  show_call = TRUE)


# Vars from Census 
# B01003_001 = Poblacion total
# B17001_002 = Personas bajo el nivel de pobreza
# B02001_002 = Personas blancas 
# B02001_003 = Personas negras alone 
