# GYS E-Ordering Platform — Greenfield Project

B2B e-ordering platform for PT Garuda Yamato Steel (GYS), connecting buyers (fabricators, contractors, retailers, sub-distributors) with GYS distributors.

**Phase 0 (current): UI prototype** — clickable, fully-mocked prototypes for stakeholder review before backend / integration work begins. No real backend, no real auth; all data is mocked and all copy is in Bahasa Indonesia.

## Layout

The repository root **is** the Nuxt web monorepo (pnpm + Turborepo); the Flutter buyer app lives under `mobile/`.

```
gys-ebuy/                # repo root = web monorepo
├── apps/
│   ├── distributor/       Distributor portal
│   └── internal/          GYS Internal console (Sales & IT)
├── packages/ui/         Shared @gys/ui library + Tailwind brand preset
├── mocks/               Shared JSON fixtures
├── package.json         pnpm + Turborepo workspace root
└── mobile/              Flutter (web) — Buyer mobile app
```

## Prerequisites

- **Node.js** ≥ 20 and **pnpm** ≥ 9 (`npm i -g pnpm`)
- **Flutter** stable (Dart 3.x) — only needed for the mobile app

## Quick start — demo (one command per surface)

The demo serves the **built/static** output of all three apps on fixed ports.
Generated build output (`.output/`, `build/web/`) is **not** committed, so build the
mobile app once first; `pnpm preview` regenerates the web output automatically.

```bash
# 1) Build the Flutter buyer app for web (run once; build output isn't committed).
cd mobile
flutter pub get
flutter build web --release --no-web-resources-cdn
cd ..

# 2) From the repo root: build + serve all three apps with one command.
pnpm install
pnpm preview
```

Then open:

| App | URL |
|---|---|
| Distributor portal | http://localhost:4000 |
| GYS Internal console | http://localhost:4001 |
| Buyer mobile (Flutter web) | http://localhost:4002 |

> On a desktop browser the mobile app renders inside a phone frame; on a narrow
> screen it goes full-screen. Every app has an **app switcher** (▦ in the topbar /
> app bar) to jump between the three surfaces during a demo.

## Deploy to Vercel (single root)

One Vercel project serves everything from one root. `scripts/build-vercel.sh`
builds all three apps into `dist/` under sub-paths and adds a landing page:

| Path | App |
|---|---|
| `/` | Landing page (links to the three apps) |
| `/distributor/` | Distributor portal (Nuxt SPA) |
| `/internal/` | GYS Internal console (Nuxt SPA) |
| `/mobile/` | Buyer mobile (Flutter web) |

Cross-app links auto-switch to these sub-paths when deployed (they use localhost
ports only for the local demo). Config lives in `vercel.json` (build command,
`outputDirectory: dist`, SPA-fallback rewrites).

**Deploy:** import the GitHub repo in the Vercel dashboard (zero extra config —
it reads `vercel.json`), or run `vercel --prod` from the repo root. The Vercel
build is **Node-only** (Nuxt apps build in CI); the Flutter app does not build on
Vercel — its compiled web output is committed at `mobile/web-build/` (~33 MB;
CanvasKit is bundled locally so it loads on any network — no external CDN) and
copied into `dist/mobile`. So no Flutter SDK is needed on Vercel.

**After changing the mobile app**, refresh the committed build (needs Flutter
locally) and commit it:

```bash
bash scripts/build-vercel.sh   # rebuilds mobile/web-build/ + dist/ (uses local Flutter)
git add mobile/web-build && git commit -m "chore: refresh mobile web build"
```

**Preview the exact production build locally:**

```bash
bash scripts/build-vercel.sh   # builds dist/
npx serve dist                 # open http://localhost:3000
```

## Development mode (hot reload)

```bash
# Web — Distributor on :3000, Internal on :3001 (from the repo root)
pnpm install
pnpm dev               # runs both apps concurrently

# Mobile — runs in Chrome with hot reload
cd mobile
flutter pub get
flutter run -d chrome
```

## Demo login (mocked — any password works)

Each login screen has a **“Login Cepat (Demo)”** section: one click signs you in as a
role, no typing needed.

- **Distributor web** — 4 distributors (e.g. `budi.mitrabaja` · Jakarta, `sri.suryalogam` · Surabaya)
- **GYS Internal web** — Sales (`andi.sales`, `dimas.sales`) and IT Admin (`rina.it`, `eko.it`)
- **Buyer mobile** — buyer personas (Kontraktor / Fabrikator / Retail)

## Stack mirrors the production target (locked by project brief)

| Surface | Phase 0 (this repo) | Phase 2 (production) |
|---|---|---|
| Buyer mobile | Flutter + go_router + ChangeNotifier + mocks | Flutter + go_router + BLoC + Clean Architecture |
| Distributor web | Nuxt 3 (SPA) + Tailwind + Pinia + mocks | Same + real backend |
| GYS Internal web | Nuxt 3 (SPA) + Tailwind + Pinia + mocks | Same + real backend + LDAP |
| Backend | (none — mocked) | Laravel 11 _or_ Go + PostgreSQL + Redis + Docker |

Brand color sourced from the live site at garudayamatosteel.com (~`#137A40`).
