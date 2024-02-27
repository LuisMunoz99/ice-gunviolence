# Introduction ------------------------------------------------------------------------------
# Updating racial and poverty spatial analysis
# ACS data 2017-2021
# Authors:     LM
# Maintainers: LM
# Date: 18-Oct-23
# ===========================================


# Set up ----------------------------------------------------------------------

#Load packages
if(!require(pacman))install.packages("pacman")
p_load(tidyverse, tidycensus, dplyr, googlesheets4,here)




# Import 
files <- list(input = "input/census_tracts_RIP",
              output = "output/all_data_rip_2022")

#Census API

#Cen

# Indicators
# Useful functions
# Poverty and racial clasification of census tracts
all_data_rip <- all_data_rip %>% mutate(
    poverty_status = ifelse(perct_below_povertyline < 42.3,
                            "not poor neighborhood",
                            "poor neighborhood"),
    racial_composition = ifelse(perct_whites >= 51.1,
                                "predominantly white neighborhood", 
                                "racially diverse neighborhood"))
  





write.csv(all_data_rip, file = files$output)


#Done