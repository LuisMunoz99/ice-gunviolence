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
       sf,
       tidyr)

# args {{{
args <- list(input = here("ice_inc/import/PUMS_inc/input/psam_h72.csv"),
             output = here("ice_inc/import/PUMS_inc/output/pumsHIncome.csv"))

# Import ICE data (new task to merge)
ice_inc<- 

  
# save the geommetry data separately
ice_inc_geometry <- ICEraceinc %>% select(GEOID) %>% unique()



# 1. Calculate ICE 
# calculate the ICE for racialized economic segregation
ice_inc <- ice_inc %>% 
  mutate(
    people_deprived  = 
      (hhinc_total_1 + hhinc_total_2 + hhinc_total_3 + hhinc_total_4) - 
      (hhinc_w_1 + hhinc_w_2 + hhinc_w_3 + hhinc_w_4),
    
    
    # sum up the white non-hispanic high income counts
    people_afluent = 
      (hhinc_w_5 + hhinc_w_6 + hhinc_w_7 + hhinc_w_8),
    
    
    # calculate the index of concentration at the extremes for economic segregation
    # (high income vs. low income)
    
    ICEinc = 
      (people_deprived - people_afluent) / 
      hhinc_total. # REVISAR CUAL ES ESTA BAR EN EL IMPORT DE ICE 
  )

# now we can merge our spatial geometry data back in
ICEraceinc <- ICEraceinc_geometry %>% 
  left_join(ICEraceinc %>% select(GEOID, ICEraceinc))


# 2. Divide ICE measures into Quintiles 
ice_quintiles <- ice_inc %>%
  arrange(ICEinc) %>%  # Ensure data is sorted by ICE
  mutate(quintile = ntile(ICE_inc, 5))  # Divide into quintiles




# 3. Calculate mortality rates for each group of quintiles of ICE (Q1,Q2,Q3,Q4,Q5)

ice_inc %>%
  group_by(quintiles) %>% 
  summarise(child_rip = sum(child_mortality),
            total_pop = sum(total_pop),
            rate = (child_rip / total_pop) * 1000000)








