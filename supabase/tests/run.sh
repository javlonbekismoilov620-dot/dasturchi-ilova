#!/usr/bin/env bash
# Resets the local database (migrations + seed) and runs the backend E2E suite.
set -euo pipefail
cd "$(dirname "$0")/../.."
npx supabase db reset >/dev/null
node --test --test-concurrency=1 supabase/tests/*.test.mjs
