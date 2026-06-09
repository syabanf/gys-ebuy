# GYS E-Ordering Platform — Greenfield Project

B2B e-ordering platform for PT Garuda Yamato Steel (GYS), connecting buyers (fabricators, contractors, retailers, sub-distributors) with GYS distributors.

**Phase 0 (current): UI prototype** for stakeholder review before backend / integration work begins. See the full plan at `/Users/syabanf/.claude/plans/users-syabanf-downloads-e-ordering-plat-splendid-dusk.md`.

## Layout

```
gys-epurchase/
├── prototype-web/        # pnpm workspace — Distributor + GYS Internal Nuxt apps
│   ├── apps/distributor/   → http://localhost:3000
│   └── apps/internal/      → http://localhost:3001
├── prototype-mobile/     # Flutter app — Buyer mobile
└── prototype-design/     # Figma references and exported assets
```

## Run all three prototypes

```bash
# Web (Distributor on :3000, Internal on :3001)
cd prototype-web
pnpm install
pnpm dev:distributor   # in one terminal
pnpm dev:internal      # in another terminal

# Mobile
cd prototype-mobile
flutter pub get
flutter run
```

## Demo credentials (mocked, no real auth)

- **Distributor web** — username `budi.mitrabaja` (or `sri.suryalogam`), any password
- **GYS Internal web** — username `andi.sales` (Sales) or `rina.it` (IT Admin), any password
- **Buyer mobile** — any phone/password proceeds to the home shell

## Stack mirrors the production target (locked by PDF)

| Surface | Phase 0 | Phase 2 (production) |
|---|---|---|
| Buyer mobile | Flutter + go_router + setState/ChangeNotifier | Flutter + go_router + BLoC + Clean Architecture |
| Distributor web | Nuxt 3 + Tailwind + Pinia + mocks | Same + real backend |
| GYS Internal web | Nuxt 3 + Tailwind + Pinia + mocks | Same + real backend + LDAP |
| Backend | (none) | Laravel 11 OR Go + PostgreSQL + Redis + Docker |

Brand color sourced from the live site at garudayamatosteel.com (~`#137A40`). Eyedropper exact hex in Phase 0 week 1.
