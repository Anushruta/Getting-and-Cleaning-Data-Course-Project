library (data.table)
library (dplyr)
library(stats)

#Download and combine files 
subject_test <- fread("test/subject_test.txt", header= FALSE)

X_test <- fread ("test/X_test.txt", header = FALSE)

Y_test <- fread ("test/y_test.txt", header= FALSE)

partiallycombinedtest <- cbind (Y_test, X_test)

fullycombinedtest <- cbind (subject_test, partiallycombinedtest)

subject_train <- fread("train/subject_train.txt", header= FALSE)

X_train <- fread ("train/X_train.txt", header = FALSE)

Y_train <- fread ("train/y_train.txt", header= FALSE)

partiallycombinedtrain <- cbind (Y_train, X_train)

fullycombinedtrain <- cbind (subject_train, partiallycombinedtrain)

complete_humanactivity_dataset <- rbind(fullycombinedtest, fullycombinedtrain)

activity_labels <- read.table("activity_labels.txt", col.names = c("activityID", "activityName"))

features <- fread("features.txt")

#Match combined dataset with variable names from features.txt 
names(complete_humanactivity_dataset)[3:563] <- as.character (features$V2)

#Give descriptive names to columns 1 and 2 
names (complete_humanactivity_dataset)[1:2]<- c("subject", "activity")

#Rename the activities 
complete_humanactivity_dataset$activity<- gsub ("1", "Walking", complete_humanactivity_dataset$activity)

complete_humanactivity_dataset$activity<- gsub ("2", "Walking_Upstairs", complete_humanactivity_dataset$activity)                        

complete_humanactivity_dataset$activity<- gsub ("3", "Walking_Downstairs", complete_humanactivity_dataset$activity) 

complete_humanactivity_dataset$activity<- gsub ("4", "Sitting", complete_humanactivity_dataset$activity)

complete_humanactivity_dataset$activity<- gsub ("5", "Standing", complete_humanactivity_dataset$activity) 

complete_humanactivity_dataset$activity<- gsub ("6", "Laying", complete_humanactivity_dataset$activity) 

#Extract mean and std measurements 
Mean_std_complete_humanactivity_dataset<- complete_humanactivity_dataset[ , grep(".*mean\\(\\)|.*std\\(\\)", names(complete_humanactivity_dataset)), with=FALSE]

#Create dataset by combining subject and activity columns with mean and std measurements 
final_humanactivity_dataset <- cbind(complete_humanactivity_dataset[,1:2], Mean_std_complete_humanactivity_dataset)

#Give variables descriptive labels 
names(final_humanactivity_dataset) <- gsub("-mean.+-", "Mean", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("^t", "Time", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("Acc", "Accelerator", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("-std.+-", "Std", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("f", "Frequency", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("Mag", "Magnitude", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("Gyro", "Gyroscope", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("-mean.+", "Mean", names(final_humanactivity_dataset))

names(final_humanactivity_dataset) <- gsub("-std.+", "Std", names(final_humanactivity_dataset))

#Create independent tidy data set with the average of each variable for each activity and each subject.
avg_final_humanactivity_dataset <- melt(final_humanactivity_dataset, id.vars = c('activity', 'subject'))

tidy_dataset <- dcast(avg_final_humanactivity_dataset,subject + activity ~ variable, mean)

#Create text file 
write.table(tidy_dataset, "./tidy dataset.txt", quote = FALSE, row.names = FALSE)
