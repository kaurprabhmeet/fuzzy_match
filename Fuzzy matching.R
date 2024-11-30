###########################################
# Purpose:          Fuzzy Match Village Names

# Author:           Prabhmeet Kaur Matta

# Date Created:     30/11/2023

# Date Modified:    15/12/2023
###########################################
# Clear the global workspace
rm(list=ls())

# Get the username
username <- Sys.getenv("USER")

# Get the user's operating system
os <- Sys.info()["sysname"]

# Set the working directory based on username
if (os == "Windows") {
  working_dir <- file.path("C:/Users", username, "Documents/Research/Project")
}  else if (os == "Darwin") {
  working_dir <- file.path("/Users", username, "Research/Project")
} else {
  working_dir <- "~/research_project"
}

# Set the working directory
setwd(working_dir)

# Print the working directory
print(getwd())

# Load and install packages 
installation_needed  <- TRUE
loading_needed <- TRUE
package_list <- c('foreign', 'xtable', 'plm','gmm', 'AER','stargazer','readstata13', 
                  'dplyr', 'readxl', 'tidyr', 'sf', 'stringdist', 'openxlsx')

if(loading_needed){lapply(package_list, require, character.only = TRUE)}

###########################################
# Load all data (District dataset matching)
###########################################
# GIS joined layer
gis_join <- file.path(working_dir, "data/geocoded_villages.shp")
gis_data <- st_read(gis_join)

# New Data including all UCs
new_dataset <- file.path(working_dir, "Processed/All_Data_for_Matches.dta")
new_dataset <- read.dta13(new_dataset)

# Function to find the closest match and its distance
find_closest_match <- function(name, candidate_names) {
  distances <- stringdist::stringdistmatrix(name, candidate_names, method = "jw")
  
  min_index <- which.min(distances)
  
  closest_match <- candidate_names[min_index]
  match_distance <- distances[min_index]
  
  return(list(match = closest_match, distance = match_distance))
}

# Preprocessing and filtering
gis_data <- gis_data %>%
  filter(district == "A" | district == "B" | district == "C") 

# Data cleaning steps
gis_data$uc <- trimws(gis_data$uc)
gis_data$tehsil <- trimws(gis_data$tehsil)
gis_data$uc <- toupper(gis_data$uc)
gis_data$tehsil <- toupper(gis_data$tehsil)
gis_data$village <- toupper(gis_data$village)
gis_data$village <- trimws(gis_data$village)

# Matching process
new_dataset$Closest_uc <- character(nrow(new_dataset))
new_dataset$MatchDistance_uc <- numeric(nrow(new_dataset))


# Loop through each row
for (i in 1:nrow(new_dataset)) {
  # Current village and tehsi
  current_uc <- new_datasetp$uc_name[i]
  current_tehsil <- new_dataset$tehsil_name[i]
  
  # Subset geo_sindh by the current tehsil
  gis_subset <- gis_data[gis_data$tehsil == current_tehsil, ]
  
  # # Find the closest match and its distance
  match_info <- find_closest_match(current_uc, unique(gis_subset$uc))
  new_dataset$Closest_uc[i] <- match_info$match
  new_dataset$MatchDistance_uc[i] <- match_info$distance
}

# loading datset with the remaining tehsils as well:
new_dataset$Closest_village <- character(nrow(new_dataset))
new_dataset$MatchDistance_village <- numeric(nrow(new_dataset))

# Loop through each row with the matched UC
for (i in 1:nrow(new_dataset)) {
  # Current village and UC
  current_uc <- new_dataset$Closest_uc[i]
  current_village <- new_dataset$village[i]
  
  # Subset by the current uc
  gis_subset <- gis_data[gis_data$uc == current_uc, ]
  
  # # Find the closest match and its distance
  match_info2 <- find_closest_match(current_village, unique(gis_subset$village))
  new_dataset$Closest_village[i] <- match_info2$match
  new_dataset$MatchDistance_village[i] <- match_info2$distance
}

new_dataset <- arrange(new_dataset, MatchDistance_uc)


expl = new_dataset %>%
  dplyr::select( uc, Closest_uc, MatchDistance_uc)

good = expl %>%
  filter(MatchDistance_uc <= .25) 

# Error rate
ran = sample_n(good[, 1:2], 50) # error rate = 0


expl2 = new_dataset %>%
  dplyr::select(village, Closest_village, MatchDistance_village)

good = expl2 %>%
  filter(MatchDistance_village <= .25) 

# Error rate
ran = sample_n(good[, 1:2], 50) # error rate = 1/50 approx 2%, change threshold and no change, good to do


# Output processing
write.xlsx(new_dataset, "matched_data_output.xlsx")

