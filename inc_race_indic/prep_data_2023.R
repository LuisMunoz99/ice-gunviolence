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


# Useful functions
transf_census <- function(census_data) {
  census_data %>% select(-moe) %>% 
    pivot_wider(names_from = variable, values_from = estimate) %>% 
    rename(total_pop = B01003_001,
           persons_below_povertyline = B17001_002,
           white = B02001_002,
           black = B02001_003) %>% 
    mutate(perct_below_povertyline = persons_below_povertyline/total_pop*100, 
           perct_whites = white/total_pop*100) %>% 
    filter(total_pop > 60)
}


# Import 
files <- list(input = "input/census_tracts_RIP",
              output = "output/all_data_rip_2022")

#Census API
census_api_key("4d6a8c0f9ecef96e8a10a8c31829fe76f60b8b42",
               overwrite=TRUE)

Sys.getenv("CENSUS_API_KEY")



# Import data -----------------------------------------------------------------------
df_orig <- get_acs(
  geography = "tract",
  year = 2021,
  variables = c("B01003_001","B17001_002","B02001_002","B02001_003"), 
  state = "PR")


PR <- get_acs(
  geography = "state",
  year = 2021,
  variables = c("B01003_001","B17001_002","B02001_002","B02001_003"), 
  state = "PR") %>% transf_census



df <- df_orig

# Vars from Census 
# B01003_001 = Poblacion total
# B17001_002 = Personas bajo el nivel de pobreza
# B02001_002 = Personas blancas 
# B02001_003 = Personas negras alone 


#Census tracts from the residence of victims of lethal police use of force
tramo_RIP <- read_csv(files$input) 

tramo_RIP <-tramo_RIP %>% mutate(GEOID = as.character(GEOID))



# Merging
all_data_rip <- df %>% transf_census %>%
  left_join(tramo_RIP, by = c("GEOID" = "GEOID"))


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