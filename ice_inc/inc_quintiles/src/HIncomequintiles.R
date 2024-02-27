# Authors:     LM
# Maintainers: LM
# Date: 24-feb-24
# ===========================================

# Calculating quintiles for Puerto Rico 
# Based on previous PUMS import

# -- libs ---
if(!require(pacman))install.packages("pacman")
p_load(dplyr,
       here,
       tidycensus,
       tidyr,
       knitr)

# args {{{
args <- list(input = here("ice_inc/import/output/pumsHIncome.csv"),
             output = here("ice_inc/inc_quintiles/output/HIquintiles22.csv"))

# -- import ---

pums_inc <- fread(args$input)


# -- Quintiles ---

pums_inc <- pums_inc %>% mutate(HINCP = sort(HINCP))

quintiles <- quantile(pums_inc$HINCP, probs = seq(0, 1, 1/5))
print(quintiles)


# -- Export ---

quintiles
quintiles_df <- data.frame(
  Quintile = c("1st Quintile (0% - 20%)", 
               "2nd Quintile (20% - 40%)",
               "3rd Quintile (40% - 60%)",
               "4th Quintile (60% - 80%)",
               "5th Quintile (80% - 100%)"),
  `cut point` = quintiles[-1]  # Exclude the first value
)

# Export the table of quintiles to a text file
write.csv(quintiles_df, args$output)


#DONE




