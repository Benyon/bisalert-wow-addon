#!/bin/bash

# Create a temporary folder
temp_folder="temp_$(date +%s)"  # Creates a unique temp folder name based on timestamp
mkdir "$temp_folder"

# Download the latest Ace3 files into the temporary folder
curl -L -o "$temp_folder/ace3.zip" https://www.wowace.com/projects/ace3/files/latest

# Delete the existing Libs folder if it exists
rm -rf Libs

# Create a new Libs folder
mkdir Libs

# Unzip the ace3 folder's contents directly into the Libs folder
unzip -o "$temp_folder/ace3.zip" -d "Libs"

# Delete the temporary folder
rm -rf "$temp_folder"

# Delete any files in the Libs folder that aren't directories
find Libs -maxdepth 1 -type f -delete

# Move it to the top level
mv Libs/Ace3/* Libs/ && rmdir Libs/Ace3