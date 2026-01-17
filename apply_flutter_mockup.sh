#!/bin/bash

# Function to process a single file
process_file() {
    local file="$1"
    
    # Skip if already has flutter_mockup
    if grep -q "flutter_mockup" "$file"; then
        echo "Skipped (already has flutter_mockup): $file"
        return
    fi
    
    # Add import after last import line
    sed -i '/^import /a\import '\''package:flutter_mockup/flutter_mockup.dart'\'';' "$file"
    
    # Remove duplicate imports (keep only first flutter_mockup import)
    awk '!seen[$0]++ || !/flutter_mockup/' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    
    echo "Processed: $file"
}

# Export function for use with find
export -f process_file

# Find all view files and process them
find lib/app/modules -name "*_view.dart" -type f -exec bash -c 'process_file "$0"' {} \;

echo "Import addition complete. Now wrapping Scaffolds..."

# Now we need to wrap Scaffold returns with FlutterMockup
# This is complex, so we'll do it with a Python script instead
