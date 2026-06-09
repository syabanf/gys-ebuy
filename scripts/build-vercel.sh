#!/usr/bin/env bash
# Build all three GYS apps into a single ./dist for one-root deployment (Vercel).
#   /            -> landing page
#   /distributor -> Nuxt SPA  (base /distributor/)
#   /internal    -> Nuxt SPA  (base /internal/)
#   /mobile      -> Flutter web (base /mobile/)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
DIST="$ROOT/dist"

echo "▸ Cleaning dist/"
rm -rf "$DIST"
mkdir -p "$DIST"

echo "▸ [1/3] Building Nuxt web apps (sub-path base URLs)…"
NUXT_APP_BASE_URL=/distributor/ pnpm --filter @gys/distributor generate
NUXT_APP_BASE_URL=/internal/  pnpm --filter @gys/internal  generate
cp -R apps/distributor/.output/public "$DIST/distributor"
cp -R apps/internal/.output/public    "$DIST/internal"

echo "▸ [2/3] Building Flutter buyer app (web, base-href /mobile/)…"
if ! command -v flutter >/dev/null 2>&1; then
  echo "  flutter not on PATH — installing Flutter stable for this build…"
  if [ ! -x "$ROOT/.flutter-sdk/bin/flutter" ]; then
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$ROOT/.flutter-sdk"
  fi
  export PATH="$ROOT/.flutter-sdk/bin:$PATH"
  flutter --version || true
fi

rm -rf mobile/build/web   # ensure a clean output (no stale/duplicate artifacts)
if ( cd mobile && flutter pub get && flutter build web --release --no-web-resources-cdn --base-href /mobile/ ); then
  cp -R mobile/build/web "$DIST/mobile"
  echo "  ✓ mobile built"
else
  echo "  ⚠ Flutter build failed — deploying web apps without the mobile app."
fi

echo "▸ [3/3] Landing page"
cp scripts/landing.html "$DIST/index.html"

# Strip iCloud-Drive "<name> 2.<ext>" duplicate artifacts that can bloat output.
find "$DIST" \( -name "* [0-9].*" -o -name "* [0-9]" \) -delete 2>/dev/null || true

echo "✓ dist/ contents:"
ls -1 "$DIST"
