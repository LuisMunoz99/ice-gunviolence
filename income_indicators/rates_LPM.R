# Introduction ------------------------------------------------------------------------------
# 
# Se utilizaron los tramos censales de Puerto Rico para calcular tasas 
# por millon de personas para encuentros fatales en personas con un ingreso 
# por hogar menor,igual o mayor al promedio de Puerto Rico para el 2019. 
#
#
# Autor:  LMN 
# Fecha:  28-10-2021
# Organizacion: Kilometro Cero  
# src path: ~git/Police-Violence/eco_analysis/mortality_rates/src/rates_LPM.R


# Set up ----------------------------------------------------------------------

#Load packages
if(!require(pacman))install.packages("pacman")
p_load(dplyr, here, flextable)


files <- list(input = here::here("lethal_uf/eco_analysis/cleaning_data/output/clean_census_csv"),
              output = here::here("lethal_uf/eco_analysis/mortality_rates/output/mortality_rates_LPM.pdf"))


# Function ---------------------------------------------------------------------

# State of poverty and racial composition of censustracts based on PR average
indicators <- function(census_cleaned) {
  census_cleaned %>% mutate(
    poverty_status = ifelse(perct_below_povertyline < 43.5,
                            "not poor neighborhood",
                            "poor neighborhood"),
    racial_composition = ifelse(perct_whites >= 65.9,
                                "predominantly white neighborhood", 
                                "racially diverse neighborhood"))
 
}

# Test - Indicadores
perct_below_povertyline <- c(46,43,56)
perct_whites <- c(66,89,2)
test_in2 <- data.frame(perct_below_povertyline,perct_whites)

poverty_status <- c("poor neighborhood", "not poor neighborhood", 
                    "poor neighborhood")
racial_composition <- c("predominantly white neighborhood","predominantly white neighborhood",
                        "racially diverse neighborhood")
expected_out2 <- data.frame(perct_below_povertyline, perct_whites,
                            poverty_status,racial_composition)


stopifnot(all(indicators(test_in2) %in% expected_out2))



# Importing data ---------------------------------------------------------------
df <- read_csv(files$input)



# Analysis ---------------------------------------------------------------------

df <- df %>% indicators()

# Rates
totals <- df %>% summarise(num = sum(freq, na.rm = TRUE),
                           denom = sum(total_pop, na.rm = TRUE))

rate_poverty <- df %>% group_by(poverty_status) %>% 
  summarise(num = (sum(freq, na.rm = TRUE)+(sum(freq, na.rm = TRUE)/totals$num*8))/7, # Imputation = Missing cases = 8
            denom = sum(total_pop, na.rm = TRUE)) %>%                                 # 7 years of analysis
  mutate(rate = num/denom*1000000) %>% filter(!is.na(rate)) %>% rename("neighborhood" = poverty_status)

rate_race <- df %>% group_by(racial_composition) %>% 
  summarise(num = (sum(freq, na.rm = TRUE)+(sum(freq, na.rm = TRUE)/totals$num*10))/7, # Imputation = Missing cases = 10
            denom = sum(total_pop, na.rm = TRUE)) %>%                                 # 7 years of analysis
  mutate(rate = num/denom*1000000) %>% filter(!is.na(rate)) %>% rename("neighborhood" = racial_composition)


rates <- rbind(rate_poverty,rate_race)

# Export 
pdf(files$output)

flextable(rates)

dev.off() 

#done