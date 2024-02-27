# Authors:     LM
# Maintainers: LM
# Date: 26-feb-23

## Merging census data with SF points 
# ===========================================

# -- libs ---
if(!require(pacman))install.packages("pacman")
p_load(fread,
       here,
       dplyr,
       sf)

# args {{{
args <- list(input1 = here(""),  # Ice import
             input2 = here(""),  # SF import 
             output = here("")) # Output ICE with SF 
# }}}



# -- Import ---
sf_child_firearm <- fread(args$input1)
ice_data <- fread(args$input)



# -- Export ---
out <- left_join(sf_child_firearm,ice_data, by = GEOID) 

fread(out, args$output)








