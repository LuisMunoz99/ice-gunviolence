# Authors:     LM
# Maintainers: LM
# Date: 19-Feb-24
# =========================================

# Creating indicators for specific table of cases of interest from regdem task
# source = Death Registry database


# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       data.table,
       openxlsx,
       stringr)


args <- list(input = here("import/regdem/output/regdem2021-2022.csv"),
             output = here("geocode/import/output/regdem_CF.csv"))


# --- Import data --- 
regdem <- fread(args$input)



# --- Cleaning --- 

# Indicator 
#  ICD10 codes related to firearm and Over 1 year old 

regdem <- regdem %>%
  mutate_all(~tolower(.)) %>% 
  mutate(
    minors = ifelse(Age >= 1 & Age <= 19, 1, 0),
    firearm = ifelse(str_detect(`DeathCause_I (Desription)`, "firearm"), 1, 0)
  )

table(regdem$firearm)
table(regdem$minors)




# --- Output --- 
regdem_cf <- regdem %>% filter(minors == 1 & firearm == 1)


fwrite(regdem_cf, args$out)


## DONE
