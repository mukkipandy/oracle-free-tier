#!/bin/bash

# Cross-platform script to create keys directory
# This script handles the case where the path might be a file instead of a directory

KEY_SAVE_PATH="$1"

if [ -z "$KEY_SAVE_PATH" ]; then
    echo "Error: No key save path provided"
    exit 1
fi

# Remove file if it exists with the same name as our directory
if [ -f "$KEY_SAVE_PATH" ]; then
    echo "Removing file with same name as directory: $KEY_SAVE_PATH"
    rm -f "$KEY_SAVE_PATH"
fi

# Create directory if it doesn't exist
if [ ! -d "$KEY_SAVE_PATH" ]; then
    echo "Creating directory: $KEY_SAVE_PATH"
    mkdir -p "$KEY_SAVE_PATH"
else
    echo "Directory already exists: $KEY_SAVE_PATH"
fi

# Verify directory was created successfully
if [ -d "$KEY_SAVE_PATH" ]; then
    echo "Directory created/verified successfully: $KEY_SAVE_PATH"
    exit 0
else
    echo "Error: Failed to create directory: $KEY_SAVE_PATH"
    exit 1
fi