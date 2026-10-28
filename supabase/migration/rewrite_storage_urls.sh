#!/usr/bin/env bash
#
# Rewrite old-project storage URLs in the NEW database's rows.
#
# Required:
#   NEW_DB_URL        Postgres connection string for the NEW project.
#   OLD_PROJECT_REF   Old project ref (the part before .supabase.co).
#   NEW_PROJECT_REF   New project ref.
#
# Example:
#   OLD_PROJECT_REF=jokvxdrxswytjjhxuhvk \
#   NEW_PROJECT_REF=abcdefghijklmnop \
#   NEW_DB_URL='postgresql://...' \
#   ./supabase/migration/rewrite_storage_urls.sh

set -euo pipefail

: "${NEW_DB_URL:?Set NEW_DB_URL to the new Postgres connection string}"
: "${OLD_PROJECT_REF:?Set OLD_PROJECT_REF (e.g. jokvxdrxswytjjhxuhvk)}"
: "${NEW_PROJECT_REF:?Set NEW_PROJECT_REF}"

if [[ "$OLD_PROJECT_REF" == "$NEW_PROJECT_REF" ]]; then
  echo "OLD_PROJECT_REF and NEW_PROJECT_REF are the same; nothing to do."
  exit 0
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OLD_URL="https://${OLD_PROJECT_REF}.supabase.co"
NEW_URL="https://${NEW_PROJECT_REF}.supabase.co"

echo "==> Rewriting $OLD_URL -> $NEW_URL"

if psql --version >/dev/null 2>&1; then
  psql "$NEW_DB_URL" \
    --variable ON_ERROR_STOP=1 \
    --variable old_url="$OLD_URL" \
    --variable new_url="$NEW_URL" \
    --file "$ROOT_DIR/rewrite_storage_urls.sql"
else
  if ! docker info >/dev/null 2>&1; then
    echo "ERROR: psql is not installed and Docker is not running." >&2
    exit 1
  fi

  DOCKER_DB_URL="${NEW_DB_URL//127.0.0.1/host.docker.internal}"
  DOCKER_DB_URL="${DOCKER_DB_URL//localhost/host.docker.internal}"

  docker run --rm -i \
    --add-host=host.docker.internal:host-gateway \
    -v "$ROOT_DIR:/migration:ro" \
    postgres:17 \
    psql "$DOCKER_DB_URL" \
    --variable ON_ERROR_STOP=1 \
    --variable old_url="$OLD_URL" \
    --variable new_url="$NEW_URL" \
    --file /migration/rewrite_storage_urls.sql
fi
