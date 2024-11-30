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

# Decrypt all encrypted files in the specified path with the given format
find "$TARGET_PATH" -type f -name "*.enc.$FILE_FORMAT" | while read -r file; do
  echo "Decrypting $file..."
  sops -d "$file" > "${file%.enc.$FILE_FORMAT}.$FILE_FORMAT" && rm "$file"
  echo "Decrypted file saved as ${file%.enc.$FILE_FORMAT}.$FILE_FORMAT"
done

echo "Decryption completed successfully."
