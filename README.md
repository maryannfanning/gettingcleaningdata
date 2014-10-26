gettingcleaningdata
===================

course project for getting and cleaning data

script takes the data from a wearables study conducted by UCI and cleans the dataset. The program takes the following steps:
1) creates a directory and downloads and unzips the dataset into the directory
2) merges the text files into a single dataset, using the features table as the column names
3) extracts the columns relating to standard deviations, means, and activity type
4) converts activity types to be human readable
5) renames the activity column to be clearly named
