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

# Copy a Nuxt app's static output to the dist sub-folder. The preset is pinned to
# 'static' (nuxt.config + env), so output is .output/public; the .vercel/output
# fallbacks keep this working even if a platform preset ever sneaks back in.
copy_app() {  # $1 = app dir name, $2 = destination
  local base="apps/$1"
  if   [ -d "$base/.output/public" ];                then cp -R "$base/.output/public"           "$2"
  elif [ -d "$base/.vercel/output/static/$1" ];      then cp -R "$base/.vercel/output/static/$1" "$2"
  elif [ -d "$base/.vercel/output/static" ];         then cp -R "$base/.vercel/output/static"    "$2"
  else echo "ERROR: no build output found for $1 (.output/public missing)" >&2; exit 1
  fi
}

echo "▸ [1/3] Building Nuxt web apps (sub-path base URLs)…"
NITRO_PRESET=static NUXT_APP_BASE_URL=/distributor/ pnpm --filter @gys/distributor generate
NITRO_PRESET=static NUXT_APP_BASE_URL=/internal/  pnpm --filter @gys/internal  generate
copy_app distributor "$DIST/distributor"
copy_app internal    "$DIST/internal"

echo "▸ [2/3] Mobile buyer app (Flutter web, base-href /mobile/)…"
# Vercel has no Flutter SDK, so the compiled mobile web build is committed at
# mobile/web-build/ and used as-is. CanvasKit is bundled locally (no CDN) so the
# deployed app loads reliably on any network. When Flutter IS available (local
# runs), rebuild the committed copy first.
if command -v flutter >/dev/null 2>&1; then
  echo "  Flutter found — rebuilding mobile/web-build…"
  rm -rf mobile/build/web
  if ( cd mobile && flutter pub get && flutter build web --release --no-web-resources-cdn --base-href /mobile/ ); then
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
