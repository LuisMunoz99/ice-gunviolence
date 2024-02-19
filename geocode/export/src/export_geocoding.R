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


args <- list(input = here("import/regdem/output/regdem2021-2022.csv"),
             output = here("geocode/export/output/geocoding_minors.xlsx"))


# --- Import data --- 
regdem <- fread(args$input)



# --- Cleaning --- 

## SEPARATE THEM IN DIFFERENT YEAR EACH SHEET
child_fire_21 <- regdem %>% filter(year_info == 2021) %>% 
  select(year_info,ControlNumber,Name, LastName,
         'DeathCause_I (ID)','DeathCause_I (Desription)',
         firearm,minors,
         ResidencePlaceAddress1:ResidencePlaceAddressZip) %>% 
  filter(minors == 1 & firearm == 1) %>% 
  mutate(longitude = NULL,
         latitute = NULL)



child_fire_22  <- regdem %>% filter(year_info == 2022) %>% 
  select(year_info,ControlNumber,Name, LastName,
         'DeathCause_I (ID)','DeathCause_I (Desription)',
         firearm,minors,
         ResidencePlaceAddress1:ResidencePlaceAddressZip) %>% 
  filter(minors == 1 & firearm == 1) %>% 
  mutate(longitude = NULL,
         latitute = NULL)

## Adding empty variables for manual data entry 


## Cleaning variables
child_fire_21 <- child_fire_21 %>% 
  mutate_all(~tolower(.)) %>%
  mutate_all(~str_replace_all(., "\\s+", "")) %>%
  mutate_all(~str_replace_all(., "[^a-zA-Z0-9]", ""))

child_fire_22 <- child_fire_22 %>% 
  mutate_all(~tolower(.)) %>%
  mutate_all(~str_replace_all(., "\\s+", "")) %>%
  mutate_all(~str_replace_all(., "[^a-zA-Z0-9]", "")) 


## The first mutate_all(~tolower(.)), it means "apply the tolower function to each column of the data frame."
## The second mutate_all removes extra spaces with str_replace_all using "\\s+" regex.
## The third mutate_all removes special characters using str_replace_all with "[^a-zA-Z0-9]" regex.




# --- Output --- 
write.xlsx(list("2021" = child_fire_21, "2022" = child_fire_22), 
           file = args$output, 
           sheetNames = c("2021", "2022"))


## DONE
