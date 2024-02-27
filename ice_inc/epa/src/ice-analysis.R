# Authors:     LM
# Maintainers: LM
# Date: 26-feb-24
# ===========================================

# Analyzing rates of mortality in
# ICE income quintiles 

# -- libs ---
if(!require(pacman))install.packages("pacman")
p_load(dplyr,
       data.table,
       here,
       tidycensus,
       tidyr)

# args {{{
args <- list(input = here("ice_inc/import/PUMS_inc/input/psam_h72.csv"),
             output = here("ice_inc/import/PUMS_inc/output/pumsHIncome.csv"))

# Import ICE data (new task to merge)
ice_census <- 
coords <- 
  
# Import COORD DATA


# 1. Divide ICE measures into Quintiles 
ice_quintiles <- ice_inc %>%
  arrange(ICE) %>%  # Ensure data is sorted by ICE
  mutate(quintile = ntile(ICE, 5))  # Divide into quintiles




# 2. Calculate mortality rates for each group of quintiles of ICE (Q1,Q2,Q3,Q4,Q5)

ice_inc %>%
  group_by(quintiles) %>% 
  summarise(child_rip = sum(child_mortality),
            total_pop = sum(total_pop),
            rate = (child_rip / total_pop) * 1000000)








