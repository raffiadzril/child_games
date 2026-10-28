#!/usr/bin/env bash
#
# Restore the dump produced by export_old.sh into the NEW Supabase project.
#
# Required:
#   NEW_DB_URL  Postgres connection string for the NEW project.
#
# Optional:
#   DUMP_DIR    Directory containing roles.sql, schema.sql, data.sql
#   FORCE=1     Allow restoring into a database that already has public tables
#
# The new project must be empty. The script uses one transaction: if anything
# fails, the whole restore is rolled back.

set -euo pipefail

: "${NEW_DB_URL:?Set NEW_DB_URL to the new Postgres connection string}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DUMP_DIR="${DUMP_DIR:-$ROOT_DIR/dump}"

if [[ "${OLD_DB_URL:-}" == "$NEW_DB_URL" ]]; then
  echo "ERROR: NEW_DB_URL is the same as OLD_DB_URL. Refusing to restore into the old project." >&2
  exit 1
fi

for file in roles.sql schema.sql data.sql; do
  if [[ ! -f "$DUMP_DIR/$file" ]]; then
    echo "ERROR: missing $DUMP_DIR/$file. Run export_old.sh first." >&2
    exit 1
  fi
done

# Supabase's managed `postgres` role cannot modify the reserved `supabase_admin`
# role. That line only sets a statement_timeout, so filter it out.
ROLES_FILE_NAME="roles.sql"
if grep -q '^ALTER ROLE "supabase_admin"' "$DUMP_DIR/roles.sql"; then
  echo "==> Filtering Supabase-managed role from roles.sql..."
  grep -v '^ALTER ROLE "supabase_admin"' \
    "$DUMP_DIR/roles.sql" > "$DUMP_DIR/roles.restore.sql"
  ROLES_FILE_NAME="roles.restore.sql"
fi

if psql --version >/dev/null 2>&1; then
  PSQL_MODE=local
  FILE_DIR="$DUMP_DIR"
  TARGET_DB_URL="$NEW_DB_URL"
else
  PSQL_MODE=docker
  FILE_DIR="/dump"
  # Inside a container, 127.0.0.1/localhost is the container itself, not the host.
  TARGET_DB_URL="${NEW_DB_URL//127.0.0.1/host.docker.internal}"
  TARGET_DB_URL="${TARGET_DB_URL//localhost/host.docker.internal}"
  if ! docker info >/dev/null 2>&1; then
    echo "ERROR: psql is not installed and Docker is not running." >&2
    echo "       Install postgresql-client or start Docker." >&2
    exit 1
  fi
fi

run_psql() {
  if [[ "$PSQL_MODE" == "local" ]]; then
    psql "$TARGET_DB_URL" "$@"
  else
    docker run --rm -i \
      --add-host=host.docker.internal:host-gateway \
      -v "$DUMP_DIR:/dump:ro" \
      postgres:17 \
      psql "$TARGET_DB_URL" "$@"
  fi
}

echo "==> Checking target database is empty..."
existing_tables="$(
  run_psql --tuples-only --no-align \
    --command "select count(*) from information_schema.tables where table_schema = 'public' and table_type = 'BASE TABLE';"
)"

if [[ "$existing_tables" != "0" && "${FORCE:-0}" != "1" ]]; then
  echo "ERROR: the target already has $existing_tables public table(s)." >&2
  echo "       Create a fresh project, or re-run with FORCE=1 if you are sure." >&2
  exit 1
fi

echo "==> Restoring roles, schema, and data into the new project..."
echo "    (triggers are disabled during the data load)"

run_psql \
  --single-transaction \
  --variable ON_ERROR_STOP=1 \
  --file "$FILE_DIR/$ROLES_FILE_NAME" \
  --file "$FILE_DIR/schema.sql" \
  --command 'SET session_replication_role = replica' \
  --file "$FILE_DIR/data.sql"

echo
echo "==> Restore finished."
echo
echo "Verify with:"
echo "  DB_URL=\"\$NEW_DB_URL\" ./supabase/migration/verify.sh"
