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

echo "▸ [2/3] Mobile buyer app (Flutter web, base-href /mobile/)…"
# Vercel has no Flutter SDK, so the mobile web build is committed at
# mobile/web-build/ and used as-is. When Flutter IS available (local runs),
# rebuild it fresh first so the committed copy stays current.
if command -v flutter >/dev/null 2>&1; then
  echo "  Flutter found — rebuilding mobile/web-build…"
  rm -rf mobile/build/web
  if ( cd mobile && flutter pub get && flutter build web --release --base-href /mobile/ ); then
    rm -rf mobile/build/web/canvaskit   # CanvasKit is loaded from the gstatic CDN; drop the unused ~37MB local copy
    rm -rf mobile/web-build
    cp -R mobile/build/web mobile/web-build
    find mobile/web-build \( -name "*.symbols" -o -name "* [0-9].*" -o -name "* [0-9]" \) -delete 2>/dev/null || true
    rm -rf mobile/build/web   # transient; local `pnpm preview` rebuilds its own (base /) copy
    echo "  ✓ refreshed mobile/web-build ($(du -sh mobile/web-build | cut -f1))"
  else
    echo "  ⚠ flutter build failed — falling back to committed mobile/web-build"
  fi
else
  echo "  Flutter not on PATH (e.g. Vercel) — using committed mobile/web-build"
fi

if [ -d mobile/web-build ]; then
  cp -R mobile/web-build "$DIST/mobile"
  echo "  ✓ mobile → dist/mobile"
else
  echo "  ⚠ mobile/web-build missing — deploying web apps without the mobile app."
fi

echo "▸ [3/3] Landing page"
cp scripts/landing.html "$DIST/index.html"

# Strip iCloud-Drive "<name> 2.<ext>" duplicate artifacts that can bloat output.
find "$DIST" \( -name "* [0-9].*" -o -name "* [0-9]" \) -delete 2>/dev/null || true

echo "✓ dist/ contents:"
ls -1 "$DIST"
