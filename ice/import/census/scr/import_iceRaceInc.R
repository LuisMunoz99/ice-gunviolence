# Authors:     LM
# Maintainers: LM
# Date: 12-Feb-24

# Importing data from census 
# ref: https://www.census.gov/topics/income-poverty/poverty/guidance/poverty-measures.html
# =========================================

# --- libs --- 
if(!require(pacman))install.packages("pacman")
p_load(dplyr, 
       here,
       data.table,
       tidycensus)


# --- import --- 
var_dic <- load_variables(2021, "acs5") # Importing all variables in census

# Variables corresponding to ICE measure
ice_vars <-
  tibble::tribble(
    ~name,          ~shortname,      ~desc,
    "B19001_001",  'hhinc_total',   "total population for household income estimates",
    "B19001A_002", 'hhinc_w_1',     "white n.h. pop with household income <$10k",
    "B19001A_003", 'hhinc_w_2',     "white n.h. pop with household income $10k-14 999k",
    "B19001A_004", 'hhinc_w_3',     "white n.h. pop with household income $15k-19 999k",
    "B19001A_005", 'hhinc_w_4',     "white n.h. pop with household income $20k-24 999k",
    "B19001A_014", 'hhinc_w_5',     "white n.h. pop with household income $100 000 to $124 999",
    "B19001A_015", 'hhinc_w_6',     "white n.h. pop with household income $125k-149 999k",
    "B19001A_016", 'hhinc_w_7',     "white n.h. pop with household income $150k-199 999k",
    "B19001A_017", 'hhinc_w_8',     "white n.h. pop with household income $196k+",
    "B19001_002",  'hhinc_total_1', "total pop with household income <$10k",
    "B19001_003",  'hhinc_total_2', "total pop with household income $10k-14 999k",
    "B19001_004",  'hhinc_total_3', "total pop with household income $15k-19 999k",
    "B19001_005",  'hhinc_total_4', "total pop with household income $20k-24 999k"
  )


# Joining vars with information in census var dictionary
ice_vars_dic <- ice_vars %>% left_join(var_dic, by = "name")

# fetch data from the american community survey API (or application programming interface)
ICEraceinc <- get_acs(
  geography = 'tract',
  state = 'MA',
  county = '025',
  geometry = TRUE,
  year = 2019,
  variables = variables_dict$var)

# save the geommetry data separately
ICEraceinc_geometry <- ICEraceinc %>% select(GEOID) %>% unique()

# remove geometry data so we can use pivot_wider
ICEraceinc <- ICEraceinc %>% sf::st_drop_geometry()

# pivot to a wide format for renaming, dropping the margin of error data
ICEraceinc <- ICEraceinc %>% select(-moe) %>% 
  pivot_wider(names_from = variable, values_from = estimate)

# rename the columns using our rename_vars
# 
# first we create a named vector, rename_vars, which has elements that are the
# acs variables we request and convenient, human readable names.
# 
# then we use rename_vars with the rename function from dplyr. 
# typically the rename function takes a syntax as follows: 
#   data %>% rename(newname1 = oldname1, newname2 = oldname2, ...)
# but in our case, we already have a named vector (rename_vars) that we 
# want to use, and so to use the rename_vars named vector inside rename
# we use the injection-operator `!!`.  you can learn more about the injection
# operator by running ?`!!` in your R console. 
rename_vars <- setNames(variables_dict$var, variables_dict$shortname)
ICEraceinc <- ICEraceinc %>% rename(!!rename_vars)

# calculate the ICE for racialized economic segregation
ICEraceinc <- ICEraceinc %>% 
  mutate(
    # we calculate the people of color low income counts as the overall 
    # low income counts minus the white non-hispanic low income counts
    people_of_color_low_income = 
      (hhinc_total_1 + hhinc_total_2 + hhinc_total_3 + hhinc_total_4) - 
      (hhinc_w_1 + hhinc_w_2 + hhinc_w_3 + hhinc_w_4),
    # sum up the white non-hispanic high income counts
    white_non_hispanic_high_income = 
      (hhinc_w_5 + hhinc_w_6 + hhinc_w_7 + hhinc_w_8),
    # calculate the index of concentration at the extremes for racialized 
    # economic segregation (high income white non-hispanic vs. low income 
    # people of color)
    ICEraceinc = 
      (white_non_hispanic_high_income - people_of_color_low_income) / 
      hhinc_total
  )

# now we can merge our spatial geometry data back in
ICEraceinc <- ICEraceinc_geometry %>% 
  left_join(ICEraceinc %>% select(GEOID, ICEraceinc))

# visualize our data - 
# here we use a divergent color palette since the ICEraceinc measure 
# is divergent in nature
ggplot(ICEraceinc, aes(fill = ICEraceinc)) +
  geom_sf() +
  scale_fill_distiller(palette = 'BrBG') +
  labs(fill = "ICE for Racialized Economic Segregation:\nWhite non-Hispanic (High Income) vs.\nPeople of Color (Low Income)") +
  ggtitle(
    "Index of Concentration at the Extremes, Racialized Economic Segregation",
    paste0("Suffolk County, MA\n",
           "Based on American Community Survey 2015-2019 Estimates")
  ) 