library(data.table)
rm(list = ls())

#### Set the working directory; modify this to accommodate your local environment.
setwd("C://Users//clydick//Desktop//Coursera//Getting and Cleaning Data//Week 4 Final//")

#### As of 1/5/2017, this was the URL for obtaining the Samsung dataset which we will make tidy
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
localfile <- file.path(getwd(), "Dataset.zip")
download.file(url, localfile)
unzip(localfile)


## 1. Merges the training and the test sets to create one data set.
##### Get all of the filenames ready to load as tables.
x_test_file <- "UCI HAR Dataset//test//X_test.txt"
y_test_file <- "UCI HAR Dataset//test//y_test.txt"
sub_test_file <- "UCI HAR Dataset//test//subject_test.txt"
x_train_file <- "UCI HAR Dataset//train//X_train.txt"
y_train_file <- "UCI HAR Dataset//train//y_train.txt"
sub_train_file <- "UCI HAR Dataset//train//subject_train.txt"
features_file <- "UCI HAR Dataset//features.txt"
activity_file <- "UCI HAR Dataset//activity_labels.txt"

##### Perform the action of actually loading the data into tables
####### Using better and more descriptive variable names here. 
x_train <- read.table(x_train_file)
x_test <- read.table(x_test_file)
label_train <- read.table(y_train_file)
label_test <- read.table(y_test_file)
subject_train <- read.table(sub_train_file)
subject_test <- read.table(sub_test_file)
features <- read.table(features_file)
activities <- read.table(activity_file)

##### Combine the relevant training/testing data 
##### using rbind to combine train and test sets for the 'data', 'labels' and 'subjects'
all_data <- rbind(x_train,x_test)
all_labels <- rbind(label_train,label_test)
all_subjects <- rbind(subject_train,subject_test)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
##### First find the columns that contain 'mean(' an 'std(' names within them
mean_features <- grep("mean\\(", features[, 2])
std_features <- grep("std\\(", features[, 2])
all_features <- sort(c(mean_features,std_features))

##### create a new table 'data' that contains a subset of columns with std and mean functions  
data <- all_data[,all_features]
names(data) <- tolower(features[all_features,2])
all_labels[,1] <- activities[all_labels[,1], 2]

## 3. Uses descriptive activity names to name the activities in the data set
##### Name the 'labels' table as 'Activities, and 'subjects' as 'Subject'
names(all_labels) <- "Activities"
names(all_subjects) <- "Subject"

## 4. Appropriately labels the data set with descriptive variable names.
##### Export the combined tidy dataset. 
tidy_data <- cbind(all_subjects, all_labels, data)
write.csv(tidy_data,"tidy_data.csv")


## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
##### We want to group by Subject/Activities 
ids <- c("Subject","Activities")
##### This is the list of measures, and we will use dcast to perform the mean calculation across the dataset
measure_vars <- setdiff(colnames(tidy_data), ids)
AGG_data <- melt(tidy_data, id=ids, measure.vars=measure_vars)
tidy_data_1 <- dcast(AGG_data, Activities + Subject ~ variable, mean)
#write.csv(tidy_data_1,"tidy_data_mean.csv")
write.table(tidy_data_1,"tidy_data_mean_rownames.csv",sep=",",row.name=FALSE)
write.table(tidy_data_1,"tidy_data_mean_rownames.txt",sep=",",row.name=FALSE)


