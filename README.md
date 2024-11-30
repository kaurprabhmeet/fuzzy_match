# Fuzzy Match Village Names

## Purpose
This script is designed to match village names from a survey dataset to a [GIS dataset](https://data.humdata.org/dataset/pakistan-settlement) using fuzzy matching. It utilizes the Jaro-Winkler distance metric to find the closest match between village and union council (UC) names in order to get a geo-referenced dataset at the village-level. 
A version of this script was published as a post on [CSAE Coders Corner - Matching](https://github.com/csae-coders-corner/Matching).
*Note:* For publication, the script has been anonymised.
## Date Created

30/11/2023

## Date Modified

15/12/2023

## Overview

1. **Fuzzy String Matching:**
   - The script defines a function `find_closest_match()` that calculates the string distance (using Jaro-Winkler) between a given name and a set of candidate names.
   - The script first matches UC names and then matches village names based on the closest UC match.

2. **Evaluate Match Quality:**
   - The script also evaluates the match quality by computing the error rate for both UC and village matches. O

## Input Files

- **GIS Data** (`geocoded_villages.shp`): Geographic data containing village and UC information.
- **Dataset** (`All_Data_for_Matches.dta`): The dataset with UC and village names that need to be matched.

## Output

- **Matched Data Output** (`matched_data_output.xlsx`): The final dataset with matched UC and village names, along with match distances.

