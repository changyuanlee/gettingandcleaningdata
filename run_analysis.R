library(dplyr)

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "UCI HAR Dataset.zip"

if (!file.exists(fileName)) {
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "UCI HAR Dataset.zip", mode = "wb")
}

folder <- "UCI HAR Dataset"

if (!file.exists(folder)) {
        unzip("UCI HAR Dataset.zip")
}

trainingSubjects <- read.table(file.path(folder, "train", "subject_train.txt"))
trainingSet <- read.table(file.path(folder, "train", "X_train.txt"))
trainingLabels <- read.table(file.path(folder, "train", "y_train.txt"))

testSubjects <- read.table(file.path(folder, "test", "subject_test.txt"))
testSet <- read.table(file.path(folder, "test", "X_test.txt"))
testLabels <- read.table(file.path(folder, "test", "y_test.txt"))

features <- read.table(file.path(folder, "features.txt"), as.is = TRUE)
activities <- read.table(file.path(folder, "activity_labels.txt"))
colnames(activities) <- c("ActivityId", "Activity")

combinedTable <- rbind(
        cbind(trainingSubjects, trainingSet, trainingLabels),
        cbind(testSubjects, testSet, testLabels)
)

colnames(combinedTable) <- c("Subject", features[, 2], "Activity")

extractColumns <- grepl("Subject|Activity|mean|std", colnames(combinedTable))
combinedTable <- combinedTable[, extractColumns]

combinedTable$Activity <- factor(combinedTable$Activity, levels = activities[, 1], labels = activities[, 2])

columnNames <- colnames(combinedTable)
columnNames <- gsub("[\\(\\)-]", "", columnNames)
columnNames <- gsub("^f", "frequencyDomain", columnNames)
columnNames <- gsub("^t", "timeDomain", columnNames)
columnNames <- gsub("Acc", "Accelerometer", columnNames)
columnNames <- gsub("Gyro", "Gyroscope", columnNames)
columnNames <- gsub("Mag", "Magnitude", columnNames)
columnNames <- gsub("Freq", "Frequency", columnNames)
columnNames <- gsub("mean", "Mean", columnNames)
columnNames <- gsub("std", "StandardDeviation", columnNames)
columnNames <- gsub("BodyBody", "Body", columnNames)
colnames(combinedTable) <- columnNames

tableMeans <- combinedTable %>% 
        group_by(Subject, Activity) %>%
        summarise_all(funs(mean))

write.table(tableMeans, "tidy_data.txt", row.names = FALSE, 
            quote = FALSE)
