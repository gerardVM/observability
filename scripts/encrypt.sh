#!/bin/bash

# Ensure the script exits on errors
set -e

# Check if the required arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <path-to-directory> <file-format>"
  echo "Example: $0 /path/to/files yaml"
  exit 1
fi

# Assign arguments to variables
TARGET_PATH=$1
FILE_FORMAT=$2

# Validate file format
if [[ "$FILE_FORMAT" != "yaml" && "$FILE_FORMAT" != "json" ]]; then
  echo "Error: Invalid file format. Supported formats are 'yaml' and 'json'."
  exit 1
fi

# KMS Key environment variable check
if [ -z "$KMS_KEY" ]; then
  echo "Error: KMS_KEY environment variable is not set."
  exit 1
fi

# Encrypt all files in the specified path with the given format
find "$TARGET_PATH" -type f -name "*.$FILE_FORMAT" | while read -r file; do
  echo "Encrypting $file..."
  sops -e --kms "$KMS_KEY" --input-type "$FILE_FORMAT" "$file" > "${file%.$FILE_FORMAT}.enc.$FILE_FORMAT"
  echo "Encrypted file saved as ${file%.$FILE_FORMAT}.enc.$FILE_FORMAT"
done

echo "Encryption completed successfully."
