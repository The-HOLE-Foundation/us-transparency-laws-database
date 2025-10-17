#!/bin/bash

# Batch import all remaining jurisdictions from files to Neon database
# Working backwards alphabetically as requested

export DATABASE_URL_UNPOOLED="postgresql://neondb_owner:npg_BvEIth7j8lfG@ep-dark-smoke-adkcd3h4.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require"

echo "🔄 Batch Import: All Remaining Jurisdictions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Counter
total=0
imported=0
skipped=0
failed=0

# Process all state files (alphabetically backwards)
for file in $(find data/jurisdictions/states -name "rights.json" | sort -r); do
  state_name=$(basename $(dirname "$file"))
  state_id=$(echo "$state_name" | tr '-' '_')

  # Check if already in database
  count=$(node -e "
import('pg').then(async ({ Client }) => {
  const client = new Client({
    connectionString: '$DATABASE_URL_UNPOOLED',
    ssl: { rejectUnauthorized: false }
  });
  await client.connect();
  const result = await client.query('SELECT COUNT(*) FROM rights_of_access WHERE jurisdiction_id = \$1', ['$state_id']);
  console.log(result.rows[0].count);
  await client.end();
});
" 2>&1 | tail -1)

  total=$((total + 1))

  if [ "$count" -gt "0" ]; then
    echo "⏭️  Skipping $state_name ($count rights already in database)"
    skipped=$((skipped + 1))
    continue
  fi

  echo "🔄 Processing: $state_name"

  # Convert and import
  node scripts/convert-file-to-db-format.js "$file" "/tmp/${state_id}-db-format.json" 2>&1 | grep "Converted"

  if node scripts/import-rights-to-neon.js "/tmp/${state_id}-db-format.json" 2>&1 | grep -q "Import complete"; then
    echo "   ✅ Imported successfully"
    imported=$((imported + 1))
  else
    echo "   ❌ Import failed"
    failed=$((failed + 1))
  fi

  echo ""
done

# Process federal
echo "🔄 Processing: federal"
if [ -f "data/jurisdictions/federal/rights.json" ]; then
  node scripts/convert-file-to-db-format.js "data/jurisdictions/federal/rights.json" "/tmp/federal-db-format.json" 2>&1 | grep "Converted"
  if node scripts/import-rights-to-neon.js "/tmp/federal-db-format.json" 2>&1 | grep -q "Import complete"; then
    echo "   ✅ Imported successfully"
    imported=$((imported + 1))
  else
    echo "   ❌ Import failed"
    failed=$((failed + 1))
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Batch Import Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   Total processed: $total"
echo "   Imported: $imported"
echo "   Skipped (already in DB): $skipped"
echo "   Failed: $failed"
echo ""
echo "🔄 Running progress check..."
echo ""
node scripts/check-rights-progress.js
