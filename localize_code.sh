#!/bin/bash

# This script helps update your Swift code to use localization

echo "Real Estate App Localization Helper"
echo "=================================="
echo ""
echo "This script will help you update your Swift code to use localization."
echo ""

# Check if the directory exists
if [ ! -d "RealEstate" ]; then
    echo "Error: RealEstate directory not found."
    exit 1
fi

# Create a backup directory
backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

echo "Creating backup of your files in $backup_dir..."

# Copy all Swift files to the backup directory
find RealEstate -name "*.swift" -exec cp {} "$backup_dir/" \;

echo "Backup created successfully."
echo ""
echo "Updating Swift files to use localization..."

# Function to update a file with localization
update_file() {
    file=$1
    echo "Processing $file..."
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Process the file
    awk '
    # Replace Text("Some text") with Text("some_key".localized)
    /Text\(\"[^\"]+\"\)/ {
        # Extract the text
        match($0, /Text\(\"([^\"]+)\"\)/, arr)
        if (arr[1]) {
            # Convert to snake_case for key
            key = tolower(arr[1])
            gsub(/[ -]/, "_", key)
            gsub(/[^a-z0-9_]/, "", key)
            
            # Replace in the line
            gsub(/Text\(\"[^\"]+\"\)/, "Text(\"" key "\".localized)", $0)
        }
    }
    
    # Replace Button("Some text") with Button("some_key".localized)
    /Button\(\"[^\"]+\"\)/ {
        # Extract the text
        match($0, /Button\(\"([^\"]+)\"\)/, arr)
        if (arr[1]) {
            # Convert to snake_case for key
            key = tolower(arr[1])
            gsub(/[ -]/, "_", key)
            gsub(/[^a-z0-9_]/, "", key)
            
            # Replace in the line
            gsub(/Button\(\"[^\"]+\"\)/, "Button(\"" key "\".localized)", $0)
        }
    }
    
    # Replace Label("Some text", systemImage: "icon") with Label("some_key".localized, systemImage: "icon")
    /Label\(\"[^\"]+\", systemImage:/ {
        # Extract the text
        match($0, /Label\(\"([^\"]+)\", systemImage:/, arr)
        if (arr[1]) {
            # Convert to snake_case for key
            key = tolower(arr[1])
            gsub(/[ -]/, "_", key)
            gsub(/[^a-z0-9_]/, "", key)
            
            # Replace in the line
            gsub(/Label\(\"[^\"]+\", systemImage:/, "Label(\"" key "\".localized, systemImage:", $0)
        }
    }
    
    # Replace NavigationView { ... }.navigationTitle("Some title") with NavigationView { ... }.navigationTitle("some_key".localized)
    /\.navigationTitle\(\"[^\"]+\"\)/ {
        # Extract the text
        match($0, /\.navigationTitle\(\"([^\"]+)\"\)/, arr)
        if (arr[1]) {
            # Convert to snake_case for key
            key = tolower(arr[1])
            gsub(/[ -]/, "_", key)
            gsub(/[^a-z0-9_]/, "", key)
            
            # Replace in the line
            gsub(/\.navigationTitle\(\"[^\"]+\"\)/, ".navigationTitle(\"" key "\".localized)", $0)
        }
    }
    
    # Print the line
    print $0
    ' "$file" > "$temp_file"
    
    # Replace the original file with the processed file
    mv "$temp_file" "$file"
}

# Find all Swift files and update them
find RealEstate -name "*.swift" -exec bash -c "update_file {}" \;

echo ""
echo "Files updated successfully!"
echo ""
echo "Next steps:"
echo "1. Review the updated files to ensure the localization keys make sense"
echo "2. Add any missing keys to your Localizable.strings files"
echo "3. Test your app in both English and French"
echo ""
echo "If you need to restore the original files, they are available in the $backup_dir directory." 