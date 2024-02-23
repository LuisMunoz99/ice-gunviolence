# Updating racial and poverty spatial analysis
# Authors:     LM
# Maintainers: LM
# Date: 22-feb-24
# ===========================================

# libs
if(!require(pacman))install.packages("pacman")
p_load(argparse,
       tidyverse,
       sf,
       tidycensus,
       dplyr, 
       arrow,
       googlesheets4,
       tidyr)


# Useful function 


# args {{{
args <- list(input = here("geocode/coords/src")
# }}}

# Deaths data import -----------------------------------------------------

# Importing Banco de victimas fatales interno 
df_orig <- read_sheet(args$input, sheet = "Geocodificacion")


df <- df_orig %>% select(Nom,FechaRIP,latitud,longitud,`Census tract`) %>% 
  rename(longitude = longitud,
         latitude = latitud) %>% filter(!is.na(longitude))



# Converting the coordinates into simple features objects
df_coords <- df %>%
  st_as_sf(coords = c("longitude", "latitude"),
           crs = 4326) %>% st_transform(6440)


# Importing geometry census data

PR_tract <- get_acs(
  geography = "tract",
  variables = c("B01003_001"),
  state = "PR",
  year = 2021,
  geometry = TRUE
) %>%
  st_transform(6440)


# Merging data 
census_tracts_RIP <- st_join(
  df_coords,
  PR_tract
) 


census_tracts_RIP <- census_tracts_RIP %>%
  group_by(GEOID,NAME) %>%
  summarise(NomList = list(Nom), Count = n()) %>% 
  mutate(NomList = as.character(NomList))




# Output
write.csv(census_tracts_RIP, "input/census_tracts_RIP.csv", row.names = FALSE)







