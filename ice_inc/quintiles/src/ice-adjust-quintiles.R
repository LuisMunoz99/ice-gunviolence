# Authors:     LM
# Maintainers: LM
# Date: 24-feb-24
# ===========================================

# Adjusting census household income data
# Based on upstream measure of incomes 
# src: ice_inc/quintiles/src/HI-income-quintiles.R

## Que asumiremos distribucion uniforme? interpolar?


# -- libs ---
if(!require(pacman))install.packages("pacman")
p_load(dplyr,
       data.table,
       here)

# args {{{
args <- list(input1 = here("ice_inc/import/output/IceCensus.csv"),
             input2 = here("ice_inc/quintiles/output/HIquintiles22.csv"),
             hand = here("ice_inc/import/notes/IceIncVarsDic.txt"))


# -- Import ---
income_data <- fread(args$input1)
quintiles <- fread(args$input2)
desc_vars <- read.table(args$hand, sep = "\t", header = TRUE)



print(quintiles)
print(desc_vars)

# -- Adjust income vars ---

## Assuming uniform distribution 

## Quintile 1 (1st Quintile (0% - 20%) = 7808) 


## Quintiles 5 ()




# 1. Adjust quintiles based on PUMS data




# 2. Export ice con sus nuevos quintiles filtrando solo los que nos interesan
# -- Export ---


