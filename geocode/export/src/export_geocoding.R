# Authors:     LM
# Maintainers: LM
# Date: 18-Feb-24
# =========================================

# Exporting cases of interest for geocoding 
# source = Death Registry database


# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       readxl,
       stringr)


args <- list(input = here("import/regdem/output/regdem2021-2022.csv"),
             output = here("geocode/export/output/geocoding_minors.xlsx")
)


# --- Import data --- 
regdem <- read_excel(args$input1)


## SEPARATE THEM IN DIFFERENT YEAR EACH SHEET

## Export only columns of interest


## PUT EVERYTHING TO LOWER
# CLEAN ANY SPECIAL CASES
# CREATE BLACK variables called - longitude and latitude
