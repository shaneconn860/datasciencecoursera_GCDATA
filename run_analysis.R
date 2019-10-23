#Download the file and Unzip it

filename <- course.zip

if (!file.exists(filename)){
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, filename, method="curl")
}

if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

#Merge the training and the test sets to create one data set

features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
features_info <- read.table("UCI HAR Dataset/features_info.txt", col.names = c("n","functions_info"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")


x <- rbind(x_train, x_test)
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)
new_data <- cbind(subject, y, x)

#Inspect combined data file using dplyr

library(dplyr)
View(new_data)

#Extract only the measurements on the mean and standard deviation for each measurement

data1 <- new_data %>% select(subject, code, contains("mean"), contains("std"))

#Use descriptive activity names to name the activities in the data set
data1$code <- activities[data1$code, 2]

#Appropriately label the data set with descriptive variable names

names(data1)[2] = "activity"
names(data1)<-gsub("Acc", "Accelerometer", names(data1))
names(data1)<-gsub("Gyro", "Gyroscope", names(data1))
names(data1)<-gsub("BodyBody", "Body", names(data1))
names(data1)<-gsub("Mag", "Magnitude", names(data1))
names(data1)<-gsub("^t", "Time", names(data1))
names(data1)<-gsub("^f", "Frequency", names(data1))
names(data1)<-gsub("tBody", "TimeBody", names(data1))
names(data1)<-gsub("-mean()", "Mean", names(data1), ignore.case = TRUE)
names(data1)<-gsub("-std()", "STD", names(data1), ignore.case = TRUE)
names(data1)<-gsub("-freq()", "Frequency", names(data1), ignore.case = TRUE)
names(data1)<-gsub("angle", "Angle", names(data1))
names(data1)<-gsub("gravity", "Gravity", names(data1))

#Create a second, independent tidy data set with the average of each variable for each activity and each subject.

new_data2 <- data1 %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(new_data2, "new_data2.txt", row.name=FALSE)



str(new_data2)
View(new_data2)