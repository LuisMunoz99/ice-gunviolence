# Authors:     LM
# Maintainers: LM
# Date: 6-Feb-24
# =========================================

# Importing demographic registry databases
# source = Death Registry database
# Purpose = set variables types and create indicators of interest 


# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       data.table,
       readxl,
       stringr,
       lubridate)



args <- list(input1 = here("import/input/regdem_2015-2020.xlsx"),
             input2 = here("import/input/regdem2020.xlsx"),
             input3 = here("import/output/regdem2021-2022.csv"),
             output = here("import/output/"))

# 2021 AND 2022 were processed before (explaning .csv) 

# --- Import data --- 
reg15_20 <- read_excel(args$input1) 
regdem20 <- read_excel(args$input2)
regdem21_22 <- fread(args$input3)

# --- Cleaning ---

# Initialize an empty list to store data frames for each year
regdem <- list()

# Iterate over unique years in the 'InscriptionYear' column

# Adding 2015-2019
# Excluding 2020 because it does not have all the cases for the year 

for (ind in unique(reg15_20$InscriptionYear)) {
  if (ind != 2020) {
    # Filter the data for the current year
    year_data <- filter(reg15_20, InscriptionYear == ind)
    
    # Store the filtered data in the list
    regdem[[as.character(ind)]] <- year_data
  } 
}

# Adding 2020 from another dataset 
# Includes 2021 cases but those will be omitted 

regdem$'2020' <- filter(regdem20, InscriptionYear == 2020)


# Adding 2021-2023 
for (ind in unique(regdem21_22 $InscriptionYear)) {
    year_data <- filter(regdem21_22, InscriptionYear == ind)
    regdem[[as.character(ind)]] <- year_data
  } 





# --- Export ---




colnames <- c("Name", "LastName", "SecondLastName", "Age", "AgeUnit", "DeathNumber","InscriptionYear","ResidencePlaceAddress1", "ResidencePlaceAddress2",
              "ResidencePlaceAddress3", "ResidencePlaceAddressZip",
              "DeathCause_I (ID)", "DeathCause_I (Desription)", "DeathDate")
for (i in seq_along(regdem)) {
  write.csv(regdem[[i]], 
            file = paste0(args$output, "regdem", names(regdem)[i], ".csv"), 
            row.names = FALSE)
}



#

