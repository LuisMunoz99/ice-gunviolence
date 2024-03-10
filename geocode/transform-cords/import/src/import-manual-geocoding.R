# Authors:     LM
# Maintainers: LM
# Date: 7-Mar-24
# =========================================


# Importing manual geocoding of deaths of minors with firearm


# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       data.table,
       readxl)


args <- list(input = here("geocode/transform-cords/import/input/geocodingCF-done.xlsx"),
             output = here("geocode/transform-cords/import/output/geocodingCF-manual-done.csv"))


# --- Import data --- 
child_firearm <- list()

all_sheets <- excel_sheets(args$input)


for (ind in all_sheets) {
  child_firearm[[ind]] <- read_excel(args$input, sheet = ind)
}




# --- Cleaning  --- 

cf2021 <- child_firearm$`2021`
cf2022 <- child_firearm$`2022`

out <- rbind(cf2021,cf2022)


# --- Output --- 
fwrite(out, args$out)


## DONE
