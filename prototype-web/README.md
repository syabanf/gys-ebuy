# GYS E-Ordering — Web Prototype (Phase 0)

Clickable UI prototype for the GYS E-Ordering Platform's two web surfaces. **Mocked data, no backend.**

## Apps
- `apps/distributor` — Distributor web (manage orders, stock, pricing)
- `apps/internal` — GYS Internal web (buyer approvals, central catalog, distributor mgmt, dashboards)

## Packages
- `packages/ui` — shared Vue 3 components (shadcn-vue / Reka UI primitives)
- `packages/tailwind-preset` — GYS brand tokens (colors sourced from garudayamatosteel.com)

## Run

```bash
pnpm install
```

### Fastest — static build (best for demos), all 3 apps in one command

```bash
# Build the Buyer mobile app for web once (CanvasKit bundled locally):
( cd ../prototype-mobile && flutter build web --release --no-web-resources-cdn )

pnpm preview          # generates web apps, then serves all three
# → distributor   http://localhost:4000
# → internal      http://localhost:4001
# → buyer mobile  http://localhost:4002  (Flutter Web)
```

Each app's topbar has an **app switcher** (▦ icon) to jump between the three — handy for demos.
Re-run `pnpm preview` after web changes; rebuild Flutter web after mobile changes.
`pnpm preview:serve` skips the build and just serves what's already built.

### Development — hot reload

```bash
pnpm dev              # runs BOTH apps concurrently (distributor :3000, internal :3001)
# or individually:
pnpm dev:distributor  # http://localhost:3000
pnpm dev:internal     # http://localhost:3001
```

The **first** page load after `pnpm dev` is slower (one-time Vite dependency optimization), then it's fast.

> ⚠️ Run only **one** dev server per app. A leftover `pnpm dev` from a previous run will
> thrash a new one and make everything crawl. Clear stragglers with:
> `pkill -f "gys-epurchase/prototype-web"`

## Demo credentials (mocked)
- **Distributor** — `budi.mitrabaja` or `sri.suryalogam`, any password
- **Internal** — `andi.sales` (Sales) or `rina.it` (IT Admin), any password

## Notes
- Nuxt pinned to 3.14.1592 + Vite 5.4.11 (newer combos hit a workspace bug on this machine's Node).
- Tailwind config is `.cjs` (not `.ts`) to avoid an `import.meta` error in the production CSS build under Node 26.
- SPA mode (`ssr: false`) with a branded loading template so first paint is never blank.

## Status
Phase 0 — both web surfaces scaffolded and runnable. See `/Users/syabanf/.claude/plans/users-syabanf-downloads-e-ordering-plat-splendid-dusk.md` for the full plan.
