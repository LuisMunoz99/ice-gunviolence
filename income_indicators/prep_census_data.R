# Introduction ------------------------------------------------------------------------------
# 
# Se utilizaron los tramos censales de Puerto Rico para calcular tasas 
# por millon de personas para encuentros fatales en personas con un ingreso 
# por hogar menor,igual o mayor al promedio de Puerto Rico para el 2019. 
#
#
# Autor:  LMN 
# Fecha:  28-10-2021
# Organizacion: Kilometro Cero 


# Set up ----------------------------------------------------------------------

#Load packages
if(!require(pacman))install.packages("pacman")
p_load(tidyverse, tidycensus, dplyr, googlesheets4,here)


files <- list(input = ("1OdVYsbx5rrEp3nCZ7TNjaWOtmRF7oTZNZ1prN1A2SFU"),
              output = here::here("lethal_uf/eco_analysis/cleaning_data/output/clean_census_csv"))

#Census API
census_api_key("4d6a8c0f9ecef96e8a10a8c31829fe76f60b8b42",
               overwrite=TRUE)

Sys.getenv("CENSUS_API_KEY")



# Import data -----------------------------------------------------------------------
df_orig <- get_acs(
  geography = "tract",
  variables = c("B01003_001","B17001_002","B02001_002","B02001_003"), 
  state = "PR")

#Vars catalog (reference)
V19 <- load_variables(2019, "acs5") 

# Vars from Census 
# B01003_001 = Poblacion total
# B17001_002 = Personas bajo el nivel de pobreza
# B02001_002 = Personas blancas 
# B02001_003 = Personas negras alone 

df <- df_orig %>% mutate_all(na_if,"")

#Census tracts from the residence of victims of lethal police use of force
tramo_RIP <- read_sheet(files$input)

tramo_RIP <- tramo_RIP %>% mutate_all(na_if,"") %>% filter(!is.na(census_tract)) %>%
                           select(-c("No_info_total","No_info_disparo","year")) %>% slice(1:60)

# Functions  -------------------------------------------------------------------

# Transformacion de Datos
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

# Test - transf_census
#test_in1 <- df_orig[5:8, ] #Census Tract 9564, Adjuntas Municipio, Puerto Rico
#expected_out1 <- 

# Output -----------------------------------------------------------------------

clean <- df_orig %>% transf_census %>%
                      left_join(tramo_RIP, by = c("NAME" = "census_tract"))



write.csv(clean, file = files$output)


#Done