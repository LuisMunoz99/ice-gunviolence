# Authors:     LM
# Maintainers: LM
# Date: 6-Feb-24
# =========================================

# Importing demographic registry databases
# source = Death Registry database


# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       data.table,
       stringr)


args <- list(input1 = here("import/regdem/input/regdem_2021_agosto2022.xlsx"), 
             input2 = here("import/regdem/input/regdem_2022.xlsx"),
             output = here("import/regdem/output/regdem2021-2022-child.csv"))


# --- Import data --- 
reg21 <- fread(args$input1)
reg22 <- fread(args$input2)

# --- Cleaning ---


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



# Bind 
out <- rbind(reg21,reg22)
 


# --- Export ---

write.csv(df, args$output, row.names = FALSE)




