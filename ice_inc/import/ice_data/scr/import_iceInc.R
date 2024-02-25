# Authors:     LM
# Maintainers: LM
# Date: 12-Feb-24

# Importing data from census 
# ref: https://www.census.gov/topics/income-poverty/poverty/guidance/poverty-measures.html
# =========================================

# Importing census data for ICE income indicators
# to analyze firearm deaths in minors 

### Things to do here, we have just to import all variables involving income
## After that we will downstream the imputations for quitiles 

### ADAPT THIS FOR ONLY INCOME BUT we need to establish quintiles first 
# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       data.table,
       tidycensus)


# --- import --- 
var_dic <- load_variables(2021, "acs5") # Importing all variables in census

# Variables corresponding to ICE measure
ice_vars <-
  tibble::tribble(
    ~name,          ~shortname,      ~desc,
    "B19001_001",  'hhinc_total',   "total population for household income estimates",
    "B19001A_002", 'hhinc_w_1',     "white n.h. pop with household income <$10k",
    "B19001A_003", 'hhinc_w_2',     "white n.h. pop with household income $10k-14 999k",
    "B19001A_004", 'hhinc_w_3',     "white n.h. pop with household income $15k-19 999k",
    "B19001A_005", 'hhinc_w_4',     "white n.h. pop with household income $20k-24 999k",
    "B19001A_014", 'hhinc_w_5',     "white n.h. pop with household income $100 000 to $124 999",
    "B19001A_015", 'hhinc_w_6',     "white n.h. pop with household income $125k-149 999k",
    "B19001A_016", 'hhinc_w_7',     "white n.h. pop with household income $150k-199 999k",
    "B19001A_017", 'hhinc_w_8',     "white n.h. pop with household income $196k+",
    "B19001_002",  'hhinc_total_1', "total pop with household income <$10k",
    "B19001_003",  'hhinc_total_2', "total pop with household income $10k-14 999k",
    "B19001_004",  'hhinc_total_3', "total pop with household income $15k-19 999k",
    "B19001_005",  'hhinc_total_4', "total pop with household income $20k-24 999k"
  )


# Joining vars with information in census var dictionary
ice_vars_dic <- ice_vars %>% left_join(var_dic, by = "name")




# -- libs ---
if(!require(pacman))install.packages("pacman")
p_load(dplyr,
       here,
       tidycensus,
       sf,
       tidyr)

# args {{{
args <- list(output =
               here(""))


# -- import ---
ice_inc <- get_acs(
  geography = "tract",
  variables = ice_vars$code
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


ice_inc_geom <- ice_inc %>% select(GEOID) %>% unique()

# remove geometry data so we can use pivot_wider
ice_inc <- ice_inc %>% st_drop_geometry()


ice_inc <- ice_inc %>% select(-moe) %>% 
  pivot_wider(names_from = variable, values_from = estimate) %>% 
  rename(total_pop = B01003_001,
         persons_below_povertyline = B17001_002,
         white = B02001_002,
         black = B02001_003)

# Remove all census tracts with low pop
ice_inc <- ice_inc %>% 
  filter(total_pop > 60)

# Returning geography data
out <- ice_inc %>% left_join(ice_inc_geometry)


# -- Output ---

write.csv(out, args$output) 

#Done