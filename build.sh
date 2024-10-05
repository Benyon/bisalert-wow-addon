#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Initialize variables, flag_o is for --o flag
flag_o=false
files_to_remove=(
    ".git"
    ".gitignore"
    "build.sh"
    "updateLibs.sh"
    ".vscode"
    "flowrc.json"
)
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"
YELLOW="\e[33m"

# Parse options
while getopts ":o" opt; do
  case $opt in
    o)
      flag_o=true
      ;;
    *)
      echo "Usage: $0 -o"
      exit 1
      ;;
  esac
done

# Check for long options (like --o)
shift $((OPTIND -1)) # Shift to remove processed options
if [[ "$1" == "--o" ]]; then
  flag_o=true
fi

# Function to log errors
error_handler() {
    local exit_code=$?  # Capture the exit status
    echo -e "${RED}Error occurred at line $1 while executing: ${BASH_COMMAND}${RESET}"
    echo -e "${RED}Exit status: $exit_code${RESET}"  # Log the exit status
}

# Cleanup: Remove unnecessary files
clear_left_over_files() {
    echo -e "${GREEN}Cleaning up unnecessary files...${RESET}"
    for file in "${files_to_remove[@]}"; do
        if [[ -e "$file" ]]; then  # Check if the file exists before attempting to remove it
            rm -rf "$target_addon_dir\\$file"
            echo -e "${YELLOW}Cleaned up: $file${RESET}"
        else
            echo -e "${RED}Skipped (not found): $file${RESET}"
        fi
    done
    echo -e "${GREEN}Cleanup completed.${RESET}"
}

# Trap errors and call error_handler function
trap 'error_handler $LINENO' ERR

# Variables
result=${PWD##*/}  # Get the current directory name

# Paths
wow_addon_dir="D:\World of Warcraft\_retail_\Interface\AddOns"
target_addon_dir="$wow_addon_dir\BisAlert"

# Cleanup: Remove old addon
echo -e "${GREEN}Clearing old addon...${RESET}"
rm -rf "$target_addon_dir"
echo -e "${GREEN}Old addon cleared.${RESET}"

# Copy new addon
echo -e "${GREEN}Copying new addon to Addons folder...${RESET}"
cp -r "../$result" "$wow_addon_dir"
echo -e "${GREEN}Addon copied to Addons folder.${RESET}"

# Rename copied addon
echo -e "${GREEN}Renaming addon...${RESET}"
mv "$wow_addon_dir\\$result" "$target_addon_dir"
echo -e "${GREEN}Addon renamed.${RESET}"

# Clean up
clear_left_over_files

# Zipping up a copy for upload
echo -e "${GREEN}Zipping up addon folder...${RESET}"
if [[ -e "./dist" ]]; then 
    rm -rf "./dist"
fi
mkdir "./dist"
zip -r "$wow_addon_dir\\BisAlert.zip" "$target_addon_dir"
mv "$wow_addon_dir\\BisAlert.zip" "./dist/BisAlert.zip"
echo -e "${GREEN}Addon zipped up.${RESET}"

# TODO: Zip up folder for dist
# mkdir /dist

# Open the folder to confirm if you haven't turned it off
if ! $flag_o
then
    explorer "$target_addon_dir" || true
fi