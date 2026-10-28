#!/usr/bin/env bash
#
# Read-only export of the old Supabase database.
#
# Required:
#   OLD_DB_URL  Postgres connection string for the OLD project.
#
# Optional:
#   DUMP_DIR    Output directory (default: ./supabase/migration/dump)
#
# This script never writes to the old database. It only runs pg_dump.

set -euo pipefail

: "${OLD_DB_URL:?Set OLD_DB_URL to the old Postgres connection string}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DUMP_DIR="${DUMP_DIR:-$ROOT_DIR/dump}"

mkdir -p "$DUMP_DIR"

if command -v supabase >/dev/null 2>&1; then
  SUPABASE=(supabase)
else
  SUPABASE=(npx --yes supabase@latest)
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker is not running. 'supabase db dump' runs pg_dump in a container." >&2
  exit 1
fi

echo "==> Dumping roles (no passwords)..."
"${SUPABASE[@]}" db dump \
  --db-url "$OLD_DB_URL" \
  -f "$DUMP_DIR/roles.sql" \
  --role-only

echo "==> Dumping schema (DDL)..."
"${SUPABASE[@]}" db dump \
  --db-url "$OLD_DB_URL" \
  -f "$DUMP_DIR/schema.sql"

echo "==> Dumping public data (rows, including challenges/questions/options)..."
"${SUPABASE[@]}" db dump \
  --db-url "$OLD_DB_URL" \
  -f "$DUMP_DIR/data.sql" \
  --use-copy \
  --data-only \
  --schema public

echo "==> Writing checksums..."
(
  cd "$DUMP_DIR"
  sha256sum roles.sql schema.sql data.sql > SHA256SUMS
)

echo
echo "==> Done. Files:"
ls -lh "$DUMP_DIR"

echo
echo "Next:"
echo "  export NEW_DB_URL='postgresql://postgres.<new-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres'"
echo "  ./supabase/migration/restore_new.sh"
