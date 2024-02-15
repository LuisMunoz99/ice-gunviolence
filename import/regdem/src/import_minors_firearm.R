# Authors:     LM
# Maintainers: LM
# Date: 21-Jan-24
# =========================================

# Importing deaths due to firearm 2022 
# source = Death Registry database


# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, here, data.table, stringr)


args <- list(input = here("spatial_analysis/ice/import/input/regdem_2020_2021.csv"), 
             output = here("spatial_analysis/ice/import/output/minors_firearm_2021.csv"))


# --- Import data --- 
df_orig <- fread(args$input)
df <- df_orig 

# --- Cleaning ---
head(df_orig)
str(df_orig)


# Select - Year, age, cause of death 1
df <- df %>% select(DateOfDeath_Date:InscriptionYear,Name:SecondLastName,
                    Age:BirthDate_Year,ResidencePlaceAddress1:ResidencePlaceAddressZip,
                    'DeathCause_I (ID)','DeathCause_I (Desription)',-Volumen)

str(df)
summary(df)


df <- df %>%
  mutate(                       # Dates
    DateOfDeath_Date = as.Date(DateOfDeath_Date, format = "%m/%d/%y"),
    BirthDate = as.Date(BirthDate,  format = "%m/%d/%y"))

summary(df$DateOfDeath_Date) # Deaths after october 2021 are missing 



# Filtering age
df_2021_minors <- df %>% filter(InscriptionYear == 2021) %>% 
  filter(AgeUnit == "Years") %>% 
  filter(Age >= 1 & Age <= 19)



# Filtering ICD10 codes related to firearm 
df_2021_minors_firearm <- df_2021_minors %>%
  mutate(death_cause_desc = tolower('DeathCause_I (Desription)')) %>% 
  filter(str_detect(`DeathCause_I (Desription)`, "firearm"))


# --- Export ---

write.csv(df, args$output, row.names = FALSE)




  