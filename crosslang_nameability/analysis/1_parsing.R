library(tidyverse)
library(here)

## Chinese data

file_names <- list.files(here("data","chinese"),pattern=".csv")

all_data=data.frame()

for (file in file_names) {
  temp <- read.csv(paste0(here("data","chinese"),"/",file))
  all_data <- bind_rows(all_data,temp)
              
}

write.csv(all_data,here("processed_data","vcs_naming_chinese_all_data.csv"),row.names=F)

## Arabic data

file_names <- list.files(here("data","arabic"),pattern=".csv")

all_data=data.frame()

for (file in file_names) {
  temp <- read.csv(paste0(here("data","arabic"),"/",file))
  temp$nameing_response <- as.character(temp$nameing_response)
  all_data <- bind_rows(all_data,temp)
  
}

write.csv(all_data,here("processed_data","vcs_naming_arabic_all_data.csv"),row.names=F)


