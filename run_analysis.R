

##Download the original file and store the date
temp<-tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", temp, method="curl")
date_download<-date()
unzip(temp)

# browse the directory created
list.files(getwd())

#browse the files created inthe directory
list.files("./UCI HAR Dataset")

#read the readme file
readme<-readLines("./UCI HAR Dataset/README.txt")
readme

#Read complimentary data
featinfo<-readLines("./UCI HAR Dataset/features_info.txt")
feat<-readLines("./UCI HAR Dataset/features.txt")
actlable<-readLines("./UCI HAR Dataset/activity_labels.txt")
featinfo
feat
actlable

#Preparing the column names to be used.
feat<-gsub(pattern=" ", replacement="-", feat)

#Importing data as text - read.table isn't working. 
trs<-readLines("./UCI HAR Dataset/train/X_train.txt") 
tss<-readLines("./UCI HAR Dataset/test/X_test.txt")

#Replacing the double spacing between some of the 
#columns for single spacing, so it won't produce NA data.
trs<-gsub(pattern="  ", replacement=" ", trs) 
tss<-gsub(pattern="  ", replacement=" ", tss)

#Opening a text connection with the R object and using read.table to get a DB.
con<-textConnection(trs,"") 
con2<-textConnection(tss,"")
trainset<-read.table(con, sep=" ")
testset<-read.table(con2, sep=" ")
close(con)
close(con2)
rm(con, con2, trs, tss)

#creating a group ID replacing a column[,1] filled with NA in the database
trainset[,1]<-"train"
testset[,1]<-"test"

#binding the value sets and naming the columns
SET<-rbind(trainset, testset)
colnames(SET)<-c("group", feat)
rm(testset, trainset)

#reading the cols with subject and activity lables.
trainlab<-read.table("./UCI HAR Dataset/train/y_train.txt")
trainsubj<-read.table("./UCI HAR Dataset/train/subject_train.txt")
testlab<-read.table("./UCI HAR Dataset/test/y_test.txt")
testsubj<-read.table("./UCI HAR Dataset/test/subject_test.txt")

#joint the rows of train and test for activity lables and subjects
LAB<-rbind(trainlab, testlab)
SUBJ<-rbind(trainsubj, testsubj)
colnames(LAB)<-"activ_lables"
colnames(SUBJ)<-"subject_id"
DB<-cbind(SUBJ, LAB, SET)
rm(trainlab, testlab, trainsubj, testsubj, LAB, SET, SUBJ)

#select the columns with mean and std values
colnm<-colnames(DB)
colselect<-grep("mean", colnm, ignore.case=TRUE)
colselect2<-grep("std", colnm, ignore.case=TRUE)
csel<-c(1, 2, colselect, colselect2)
DB2<-DB[, csel]

#Using self explanatory labels to the activ.
DB2$activ_lables<-factor(DB2$activ_lables, labels=actlable)

#create a new DB with the mean value for subject and activity in each variable
new_db<-aggregate(DB2[,c(-1,-2)], by=list(subject_id=DB2$subject_id, activ_lables=DB2$activ_lables), FUN=mean)

#write file
write.table(new_db, "NewDBfile.txt", row.name=FALSE)

