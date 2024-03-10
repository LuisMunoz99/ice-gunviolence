# Authors:     LM
# Maintainers: LM
# Date: 24-feb-24
# ===========================================


# Manual geocodification was imported
# Script will convert lat and log to SF and geocode using census 

# libs
if(!require(pacman))install.packages("pacman")
p_load(data.table,
       here,
       sf,
       tidycensus,
       dplyr, 
       tidyr)



# args {{{
args <- list(input = here("geocode/transform-cords/import/output/geocodingCF-manual-done.csv"), 
             output =  here("geocode/transform-cords/export/output/geocoded-coords.csv"))

# }}}

# -- Import ---
child_firearm <- fread(args$input)

PR_tract <- get_acs(
  geography = "tract",
  variables = c("B01003_001"), # dummy var to get geometry 
  state = "PR",
  year = 2022,
  geometry = TRUE
) %>%
  st_transform(6440)



# -- Clealing ---


child_firearm <- child_firearm %>%
  mutate(full_name = paste(Name, LastName, sep = " ")) %>% 
  select(-ControlNumber, -firearm, -minors, -Name, -LastName) %>% 
  filter(!is.na(latitute) | !is.na(longitude))


# Converting into simple features
child_firearm_sf <- child_firearm %>%
  st_as_sf(coords = c("longitude", "latitute"), crs = 4326) %>%
  st_transform(6440) 




# Combining sf to census
out <- st_join(
  child_firearm_sf,
  PR_tract
) 



# Assuming your dataframe is named child_firearm
out <- out %>%
  group_by(GEOID) %>%
  mutate(RIP = n()) %>%
  ungroup() %>% distinct(GEOID, .keep_all = TRUE)





# -- Output ---
fwrite(out, args$output)






