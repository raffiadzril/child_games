#!/usr/bin/env bash
#
# Print row counts and RLS policies so the old and new databases can be compared.
#
# Usage:
#   DB_URL="$OLD_DB_URL" ./supabase/migration/verify.sh > /tmp/old-counts.txt
#   DB_URL="$NEW_DB_URL" ./supabase/migration/verify.sh > /tmp/new-counts.txt
#   diff -u /tmp/old-counts.txt /tmp/new-counts.txt

set -euo pipefail

: "${DB_URL:?Set DB_URL to the database you want to inspect}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if psql --version >/dev/null 2>&1; then
  psql "$DB_URL" \
    --variable ON_ERROR_STOP=1 \
    --file "$ROOT_DIR/verify.sql"
else
  if ! docker info >/dev/null 2>&1; then
    echo "ERROR: psql is not installed and Docker is not running." >&2
    exit 1
  fi

  DOCKER_DB_URL="${DB_URL//127.0.0.1/host.docker.internal}"
  DOCKER_DB_URL="${DOCKER_DB_URL//localhost/host.docker.internal}"

  docker run --rm -i \
    --add-host=host.docker.internal:host-gateway \
    -v "$ROOT_DIR:/migration:ro" \
    postgres:17 \
    psql "$DOCKER_DB_URL" \
    --variable ON_ERROR_STOP=1 \
    --file /migration/verify.sql
fi
