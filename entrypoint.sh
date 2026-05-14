#!/bin/sh
set -e
echo "[MIGRATE] Applying schema..."
node /app/startup.mjs
echo "[MIGRATE] Done."
exec node dist/index.cjs
