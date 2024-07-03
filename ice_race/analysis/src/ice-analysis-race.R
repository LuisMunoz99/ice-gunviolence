# Authors:     LM
# Maintainers: LM
# Date: 26-feb-24
# ===========================================

# this code need the dataset from 
# Merged --> with this dataset the analysis can be finished 


# -- libs ---
if(!require(pacman))install.packages("pacman")
p_load(dplyr,
       data.table,
       here,
       tidycensus,
       sf,
       tidyr)

# args {{{
args <- list(input = here("ice_race/merge/output/iceRace-geo-final.csv"),
             output = here(""))

# Import ICE data (new task to merge)fre
ice_race <- fread(args$input)

  
## Conclusion
# At this point, Q1 (0-7808) is basically measured with the first category after estimating 7808 from 10,0000 income pop
# Q5 (49300-828000) would be the lower limit of the adjusted category of household income $45k-49,999 
# and then we must add the other income cats. This cats would be hhinc49300 + hhinc10-hhinc16.
  
# Tengo que pensar mejor las cantidades totales de poblacion por tramo censal
# PORQUE TIENE que reflejar los ajusted de los intervalos 

# Verificar porque hhinc_total 


# Black vs White
# 1. Calculate ICE 
# calculate the ICE for racialized economic segregation

ice_race <- ice_race %>% 
  mutate(people_deprived = black,
         people_afluent = white,
         ICErace = (people_deprived - people_afluent) / 
      pop_total)



# 2. Divide ICE measures into Quintiles 
ice_race <- ice_race %>%
  arrange(ICErace) %>%  # Ensure data is sorted by ICE
  mutate(ICEquintile = ntile(ICErace, 5))  # Divide into quintiles




# 3. Calculate mortality rates for each group of quintiles of ICE (Q1,Q2,Q3,Q4,Q5)

ice_race %>%
  group_by(ICEquintile) %>% 
  summarise(child_rip = sum(RIP),
            total_pop = sum(pop_total),    # Aqui uso la poblacion del tramo censal
            rate = (child_rip / total_pop) * 100000)



# POC vs white
# 1. Calculate ICE 
# calculate the ICE for racialized economic segregation

ice_race_poc <- ice_race %>% 
  mutate(
    people_deprived  = POC,
    people_afluent = white,
    ICEracePOC = 
      (people_deprived - people_afluent) / 
      pop_total)



# 2. Divide ICE measures into Quintiles 
ice_race_poc <- ice_race_poc %>%
  arrange(ICEracePOC) %>%  # Ensure data is sorted by ICE
  mutate(ICEquintile = ntile(ICEracePOC, 5))  # Divide into quintiles




# 3. Calculate mortality rates for each group of quintiles of ICE (Q1,Q2,Q3,Q4,Q5)

ice_race_poc %>%
  group_by(ICEquintile) %>% 
  summarise(child_rip = sum(RIP),
            total_pop = sum(pop_total),    # Aqui uso la poblacion del tramo censal
            rate = (child_rip / total_pop) * 100000)


ice_race_poc %>%
  group_by(ICEquintile) %>% 
  filter(!is.na(ICEquintile)) %>% 
  summarise(child_rip = sum(RIP),
            total_pop = sum(pop_total),    
            rate = round((child_rip / total_pop) * 100000, 2)) %>%
  kable("html", caption = "Ice Race (white vs non-white)") %>%
  kable_styling(full_width = FALSE, bootstrap_options = c("condensed", "striped", "hover"))



## Voy a añadir 3 años con una distribucion uniforme y ver como eso funciona , esos tengo que dividirlos entre la cantidad de años????
## Agrupar los quintiles?????/



ice_adjusted_quintiles_combined %>%
  mutate(ICEquintile = rename())
  group_by(ICEquintile) %>% 
  filter(!is.na(ICEquintile)) %>% 
  summarise(child_rip = sum(RIP),
            total_pop = sum(pop_total),    
            rate = round((child_rip / total_pop) * 100000, 2)) %>%
  kable("html", caption = "Ice Race (white vs non-white)") %>%
  kable_styling(full_width = FALSE, bootstrap_options = c("condensed", "striped", "hover"))


  
  
# Define the data
deaths <- c(18, 36, 20)
population <- c(1367995, 1306465, 597863)

# Calculate mortality rates
mortality_rate <- deaths / population * 100000  # Multiply by 1000 to get per 1000 population

# Create variables
quintile <- c("1-2", "3-4", "5")
deaths <- deaths
population <- population
mortality_rate <- mortality_rate

# Create a data frame
data_race <- data.frame(quintile, deaths, population, mortality_rate)

# Print the data frame
print(data_race)

# Define the data
deaths <- c(19, 33, 22)
population <- c(1419967, 1359925, 490128)

# Calculate mortality rates
mortality_rate <- deaths / population * 100000  # Multiply by 1000 to get per 1000 population

# Create variables
quintile <- c("1-2", "3-4", "5")
deaths <- deaths
population <- population
mortality_rate <- mortality_rate

# Create a data frame
data_income <- data.frame(quintile, deaths, population, mortality_rate)

# Print the data frame
print(data_income)


  
  
  

