# Authors:     LM
# Maintainers: LM
# Date: 19-Feb-24
# =========================================

# Exporting cases of interest for geocoding 
# source = Death Registry database


# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       data.table,
       openxlsx,
       stringr)


args <- list(input = here("geocode/import/output/regdem_CF.csv"),
             output = here("geocode/manual_rev/output/geocoding_CF.xlsx"))


# --- Import data --- 
regdem <- fread(args$input)



# --- Cleaning --- 

## SEPARATE THEM IN DIFFERENT YEAR EACH SHEET
child_fire_21 <- regdem %>% filter(year_info == 2021) %>% 
  select(year_info,ControlNumber,Name, LastName,
         'DeathCause_I (ID)','DeathCause_I (Desription)',
         firearm,minors,
         ResidencePlaceAddress1:ResidencePlaceAddressZip) %>% 
  mutate(longitude = NA,
         latitute = NA)



child_fire_22  <- regdem %>% filter(year_info == 2022) %>% 
  select(year_info,ControlNumber,Name, LastName,
         'DeathCause_I (ID)','DeathCause_I (Desription)',
         firearm,minors,
         ResidencePlaceAddress1:ResidencePlaceAddressZip) %>% 
  mutate(longitude = NA,
         latitute = NA)

## Adding empty variables for manual data entry 


## Cleaning variables, not removing anys special characters because these 
## variables are going to be manually reviewed. 

child_fire_21 <- child_fire_21 %>% 
  mutate_all(~tolower(.)) %>%
  mutate_all(~str_squish(.))

child_fire_22 <- child_fire_22 %>% 
  mutate_all(~tolower(.)) %>%
  mutate_all(~str_squish(.))




## The first mutate_all(~tolower(.)), it means "apply the tolower function to each column of the data frame."
## Could use mutate_all to remove special characters using str_replace_all with "[^a-zA-Z0-9]" regex.




# --- Output --- 
write.xlsx(list("2021" = child_fire_21, "2022" = child_fire_22), 
           file = args$output, 
           sheetNames = c("2021", "2022"))


## DONE
