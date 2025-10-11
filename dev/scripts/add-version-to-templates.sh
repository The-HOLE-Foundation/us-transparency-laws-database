#!/bin/bash
# Add version numbers to all template files
# Renames: agencies-TEMPLATE.json → agencies-TEMPLATE-v0.12.json

VERSION="v0.12"

echo "Adding version $VERSION to all template files..."
echo ""

# Rename agencies templates
find data/states -name "agencies-TEMPLATE.json" | while read file; do
  dir=$(dirname "$file")
  newfile="$dir/agencies-TEMPLATE-$VERSION.json"
  mv "$file" "$newfile"
  echo "✓ Renamed: $file → $newfile"
done

echo ""
echo "All templates now versioned with $VERSION"
echo ""
echo "Benefits:"
echo "  - Clear which data model version"
echo "  - Can have multiple template versions coexist"
echo "  - Easy to identify deprecated templates"
