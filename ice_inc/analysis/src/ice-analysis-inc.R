# Authors:     LM
# Maintainers: LM
# Date: 26-feb-24
# ===========================================

# this code need the dataset from 
# Merged --> with this dataset the analysis can be finished 
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
args <- list(input = here("ice_inc/merge/output/iceInc-geo-final.csv"),
             output = here(""))

# Import ICE data (new task to merge)fre
ice_inc <- fread(args$input)

  
## Conclusion
# At this point, Q1 (0-7808) is basically measured with the first category after estimating 7808 from 10,0000 income pop
# Q5 (49300-828000) would be the lower limit of the adjusted category of household income $45k-49,999 
# and then we must add the other income cats. This cats would be hhinc49300 + hhinc10-hhinc16.
  
# Tengo que pensar mejor las cantidades totales de poblacion por tramo censal
# PORQUE TIENE que reflejar los ajusted de los intervalos 

# Verificar porque hhinc_total 

# 1. Calculate ICE 
# calculate the ICE for racialized economic segregation
ice_inc <- ice_inc %>% 
  mutate(
    hhinc_total = hhinc_7808+hhinc2+hhinc3+hhinc4+hhinc5+hhinc6+hhinc7+hhinc8+
      hhinc_49300+hhinc10+hhinc11+hhinc12+hhinc13+hhinc14+hhinc15+hhinc16,
    
    people_deprived  = hhinc_7808,
    
    people_afluent = (hhinc_49300 + hhinc10 + hhinc11 + hhinc12 + hhinc13 +
      hhinc14 + hhinc15 + hhinc16),
    ICEinc = 
      (people_afluent - people_deprived) / 
      hhinc_total) 



# 2. Divide ICE measures into Quintiles 
ice_inc <- ice_inc %>%
  arrange(ICEinc) %>%  # Ensure data is sorted by ICE
  mutate(ICEquintile = ntile(ICEinc, 5))  # Divide into quintiles




# 3. Calculate mortality rates for each group of quintiles of ICE (Q1,Q2,Q3,Q4,Q5)

x <- ice_inc %>%
  group_by(ICEquintile) %>% 
  summarise(child_rip = sum(RIP),
            total_pop = sum(pop_total),    
            rate = (child_rip / total_pop) * 100000) %>% 
  mutate(proportion = child_rip / sum(child_rip),
         total_cases_faltantes = 100,
         casos_faltantes = total_cases_faltantes * proportion,
         child_rip_adjusted = casos_faltantes + child_rip,
         rate_adjusted = (child_rip_adjusted / total_pop) * 100000)


ice_inc %>%
  group_by(ICEquintile) %>% 
  filter(!is.na(ICEquintile)) %>% 
  summarise(child_rip = sum(RIP),
            total_pop = sum(pop_total),    
            rate = round((child_rip / total_pop) * 100000, 2)) 





library(gt)

ice_inc <- YOUR_DATASET_HERE  # Make sure to replace YOUR_DATASET_HERE with your actual dataset

gt_table <- gt(ice_inc) %>%
  # Table Title 
  tab_header(
    title = "Mortality Rates by ICE Quintile"
  ) %>%
  # Column Labels
  cols_label(
    Children_who_Died = "Children Who Died",
    Total_Population = "Total Population",
    Mortality_Rate = "Mortality Rate (per 100,000)"
  ) %>%
  # Table Body 
  # Add footnote text to caption
  tab_spanner(
    label = "Column Labels",
    Children_who_Died ~ Mortality_Rate
  ) %>%
  tab_footnote(
    footnote = "Mortality Rate is age-adjusted"
  ) %>%
  # ... rest of the code for table theme remains the same ...
  










#