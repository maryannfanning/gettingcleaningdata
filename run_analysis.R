#Script requires the following packages: car, tools

if(!file.exists("./gcd_project")){dir.create("./gcd_project")}
fileUrl1 = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl1,destfile="./gcd_project/wearables.zip")

unzip("./gcd_project/wearables.zip", exdir = "./gcd_project/wearables_data.csv")

dateDownloaded <- date()
dateDownloaded

list.files("./gcd_project/wearables_data/UCI HAR Dataset")

features <- read.table("./gcd_project/wearables_data/UCI HAR Dataset/features.txt", stringsAsFactors=FALSE, header=FALSE)


col_names <- features[,2]
#sets up names for columns in data frame

test_data <- read.table("./gcd_project/wearables_data/UCI HAR Dataset/test/X_test.txt", header=FALSE)
ncol(test_data)
nrow(test_data)
#used to explore data in test_dataset

names(test_data) <- col_names
names(test_data)
ncol(test_data)
test_data$data_type <- "test"
#adds col to test_data so it can be identified when merged with train

training_data <- read.table("./gcd_project/wearables_data/UCI HAR Dataset/train/X_train.txt",header=FALSE)
ncol(training_data)

names(training_data) <- col_names
names(training_data)
ncol(training_data)
#used to explore train dataset

training_data$data_type <- "train"
#adds col to training_data so it can be identified when merged with test
ncol(training_data)
nrow(training_data)


merged_training_test <- rbind(test_data,training_data)
names(merged_training_test)
#sets up a single table with both datasets included

library(tools)


#function to add all the remaining datasets onto one table where appropriate
complete_data <- function(directory, data_frame, original_file){
  dir_list <- list.files(directory)
  new_df = data.frame()
  new_names = c()
  for(item in dir_list){
    if(file_ext(item)=="txt"){
      data_location <- paste(directory, item, sep="/")
      prepped_item <- read.csv(data_location, header=FALSE)
      if(item != original_file){
        if(ncol(new_df)==0){
          new_df <- prepped_item
          new_names <- c(item)
        }
        else{
        new_df <- cbind(new_df, prepped_item)
        new_names <- cbind(new_names, item)
        }
        
      }
    }
    else{
      sub_dir <- paste(directory, item, sep="/")
      sub_dir_list <- list.files(sub_dir)
      for(sub_file in sub_dir_list){
        sub_file_location <- paste(sub_dir, sub_file, sep="/")
        prepped_sub_file <- read.csv(sub_file_location, header = FALSE)
        if(ncol(new_df) == 0){
          new_df <- prepped_sub_file
          new_names <- c(sub_file)
        }
        else{
        new_df <- cbind(new_df, prepped_sub_file)
        new_names <- cbind(new_names, sub_file)
        }
      }
    }
  }
  names(new_df) = new_names
  data_frame <- cbind(data_frame, new_df)
  return(data_frame)
}

test_data_draft <- complete_data("./gcd_project/wearables_data/UCI HAR Dataset/test", test_data, "X_test.txt")
#adds test related cols to the dataset

training_data_draft <- complete_data("./gcd_project/wearables_data/UCI HAR Dataset/train", training_data, "X_train.txt")
#adds training related cols to the dataset

names(training_data_draft) <- names(test_data_draft)
#ensures that both datasets have consistent naming conventions - please note for this project we did not
#need to rely on some of the training/test specific dataframes

merged_data <- rbind(test_data_draft, training_data_draft)
nrow(merged_data)
ncol(merged_data)
#merge and check to make sure everything merged correctly

#function filters for averages and std columns
data_with_averages <- function(data_set){
  data_names <- names(data_set)
  new_data <- data.frame(matrix(ncol=0, nrow = nrow(data_set)))
  num_cols <- ncol(data_set)
  new_names <- c()
  for(x in 1:num_cols){
  if(grepl("mean", data_names[x]) == TRUE){
    new_data <- cbind(new_data, data_set[, x])
    new_names <- cbind(new_names, data_names[x])
  }
  if(grepl("std", data_names[x]) == TRUE){
    new_data <- cbind(new_data, data_set[, x])
    new_names <- cbind(new_names, data_names[x])
  }
  }
  new_data <- cbind(new_data, data_set$y_test.txt)
  new_names <- cbind(new_names, "y_test.txt")
  names(new_data) <- new_names
  return(new_data)
}

#section to filter dataset and confirm everything was filtered correctly
means <- data_with_averages(merged_data)
ncol(means)
nrow(means)
names(means)
head(means)

#confirms unique values for activities
unique(means$y_test.txt)

#replaces values for activities in human readable form
library(car)

activities <- recode(means$y_test.txt, '1="walking"; 2="walking upstairs"; 3="walking downstairs"; 4="sitting"; 5="standing";6="laying"')

#checks that activities transferred correctly
head(activities)
head(means$y_test.txt)
tail(activities)
tail(means$y_test.txt)

#replaces column with activities information
means$y_test.txt <- activities
head(means$y_test.txt)

#renames col to be "activities"
names(means)[ncol(means)] <- "activities"

#checks everything was renamed correctly
names(means)

#saves dataframe to the project directory
write.table(means, file="./gcd_project/run_analysis.txt", sep="\t", row.name=FALSE)

