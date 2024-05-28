#!/bin/bash

# Check if a filepath is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>" # provide help message if no filename provided
    exit 1
fi

# Input filepath is first command line argument
input_file="$1"

# Get the folder name from the input filepath
input_dir=$(dirname "$input_file")
# Get the filename from the input filepath
input_filename=$(basename "$input_file")

# Assmeble the output filepath
output_file="${input_dir}/head100k.${input_filename}"

# Extract the first 100,000 lines and save to the new file
head -n 100000 "$input_file" > "$output_file"


