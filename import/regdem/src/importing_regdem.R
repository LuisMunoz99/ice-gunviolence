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
       readxl,
       stringr)


args <- list(input1 = here("import/regdem/input/regdem_2021_agosto2022.xlsx"), 
             input2 = here("import/regdem/input/regdem_2022.xlsx"),
             output = here("import/regdem/output/regdem2021-2022.csv"))


# --- Import data --- 
reg21 <- read_excel(args$input1)
reg22 <- read_excel(args$input2)


# --- Cleaning ---

# Verify columns names similarity for binding downstream
if (identical(colnames(reg21), colnames(reg22))) {
  print("Column names are identical.")
} else {
  print("Column names are not identical.")
}

## We are good to bind both datasets 

## Control number column should represent unique cases
## Based on this column I will determine missingness and duplication 

# Verify NA values
if (any(is.na(c(reg21$ControlNumber, reg22$ControlNumber)))) {
  print("There are NA values in the 'ControlNumber' column in either reg21 or reg22.")
} else {
  print("There are no NA values in the 'ControlNumber' column in either reg21 or reg22.")
}


# Verify duplicates in control numbers
if (any(duplicated(c(reg21$ControlNumber, reg22$ControlNumber)))) {
  print("There are Duplicated values in the 'ControlNumber' column in either reg21 or reg22.")
} else {
  print("There are no Duplicated values in the 'ControlNumber' column in either reg21 or reg22.")
}


# Implement changes
reg21 <- reg21 %>% 
  distinct(ControlNumber, .keep_all = TRUE)

## I verified the incident and it seams an error of only one duplicate.
## By using distinct() I will preserve only one of both incidents 

reg22 %>% 
  mutate(dupli = ifelse(duplicated(ControlNumber) | duplicated(ControlNumber, fromLast = TRUE), 1, 0)) %>% 
  filter(dupli == 1) %>% 
  select(-dupli) %>% 
  print()

reg22 <- reg22 %>% 
  distinct(ControlNumber, .keep_all = TRUE)

## This allows for the fist ocurrence and any other to be recognized when a duplicate
## After review the 3 incidents have a single duplicate for them 
## By using distinct() I will preserve only one of both incidents 


# Summary stats for each dataset
summary(reg21)
summary(reg22)

summary(reg21$DateOfDeath_Date)
summary(reg22$DateOfDeath_Date)


# Verifying changes 
if (any(duplicated(c(reg21$ControlNumber, reg22$ControlNumber)))) {
  stop("Error: Duplicated values found in 'ControlNumber' column in either reg21 or reg22.")
} else {
  print("Problem solved")
}



# Selecting variables
reg21 <- reg21 %>% select(DateOfDeath_Date:InscriptionYear,Name:SecondLastName,
                          Age:BirthDate_Year,ResidencePlaceAddress1:ResidencePlaceAddressZip,
                          'DeathCause_I (ID)','DeathCause_I (Desription)',-Volumen) %>%
  mutate(database = "regdem_2021_agosto2022.xlsx") # Create new variable for reference 


reg22 <- reg22 %>% select(DateOfDeath_Date:InscriptionYear,Name:SecondLastName,
                          Age:BirthDate_Year,ResidencePlaceAddress1:ResidencePlaceAddressZip,
                          'DeathCause_I (ID)','DeathCause_I (Desription)',-Volumen) %>%
  mutate(database = "regdem_2022.xlsx")


# Binding datasets for 2021 and 2022
regdem21_22 <- reg21 %>% rbind(reg22)

#  Conserving deaths only above 1 year old
regdem21_22 <- regdem21_22 %>% filter(AgeUnit != "Days") %>% 
  filter(Age != 0) 



## STR
regdem21_22 <- regdem21_22 %>%
  mutate(
    DateOfDeath_Date = as.Date(DateOfDeath_Date, format = "%m/%d/%y"),
    DeathNumber = as.character(DeathNumber),
    CertificateNumber = as.character(CertificateNumber),
    ControlNumber = as.factor(ControlNumber),
    InscriptionYear = as.integer(InscriptionYear),
    Name = as.character(Name),
    MiddleName = as.character(MiddleName),
    LastName = as.character(LastName),
    SecondLastName = as.character(SecondLastName),
    Age = as.integer(Age),
    AgeUnit = as.character(AgeUnit),
    BirthDate = as.Date(BirthDate,  format = "%m/%d/%y"),
    BirthDate_Year = as.integer(BirthDate_Year),
    ResidencePlaceAddress1 = as.character(ResidencePlaceAddress1),
    ResidencePlaceAddress2 = as.character(ResidencePlaceAddress2),
    ResidencePlaceAddress3 = as.character(ResidencePlaceAddress3),
    ResidencePlaceAddressZip = as.character(ResidencePlaceAddressZip),
    `DeathCause_I (ID)` = as.character(`DeathCause_I (ID)`),
    `DeathCause_I (Desription)` = as.character(`DeathCause_I (Desription)`),
    database = as.factor(database)
  )


# Indicator 
#  ICD10 codes related to firearm and Over 1 year old 
regdem21_22 <- regdem21_22 %>%
  mutate(
    minors = ifelse(Age >= 1 & Age <= 19, 1, 0),
    firearm = ifelse(str_detect(`DeathCause_I (Desription)`, "(?i)^fire"), 1, 0)
  )


# --- Export ---

write.csv(regdem21_22, args$output, row.names = FALSE)



## Done

