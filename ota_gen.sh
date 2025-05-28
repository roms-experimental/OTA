#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <signed_target_files.zip> <ota_zip_url>"
    exit 1
fi

TARGET_FILES="$1"
OTA_URL="$2"

# Check files
if [ ! -f "$TARGET_FILES" ]; then
    echo "Target files zip not found: $TARGET_FILES"
    exit 1
fi

# Extract datetime
DATETIME=$(unzip -p "$TARGET_FILES" META-INF/com/android/metadata | grep 'post-timestamp' | cut -d= -f2)

# Get OTA filename from URL
FILENAME=$(basename "$TARGET_FILES")

# Extract version
VERSION=$(echo "$FILENAME" | sed -n 's/^lineage-\([0-9]*\.[0-9]*\)-.*/\1/p')

# Calculate SHA256 id
ID=$(sha256sum "$TARGET_FILES" | awk '{print $1}')

# Get file size in bytes
SIZE=$(stat -c %s "$TARGET_FILES")

# Output JSON
cat <<EOF
{
  "response": [
    {
      "datetime": $DATETIME,
      "filename": "$FILENAME",
      "id": "$ID",
      "romtype": "UNOFFICIAL",
      "size": $SIZE,
      "url": "$OTA_URL",
      "version": "$VERSION"
    }
  ]
}
EOF
