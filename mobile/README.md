# GYS E-Ordering — Buyer Mobile Prototype (Phase 0)

Flutter clickable prototype for the Buyer mobile app. **Mocked data, no backend.**

## Stack
- Flutter (Dart 3.x), Material 3
- `go_router` for navigation
- `intl` for IDR currency / Bahasa Indonesia date formatting
- Mock data: `assets/mocks/*.json`
- State: simple `ChangeNotifier` for cart (BLoC will land in Phase 2)

## Run

```bash
flutter pub get
flutter run               # auto-picks any connected device or simulator
flutter run -d chrome     # web target if enabled
```

## Build for stakeholder distribution

```bash
flutter build apk --release   # Firebase App Distribution
flutter build ipa --release   # TestFlight
```

## Hero flows implemented
- Splash → Login → Register (3-step) → KYC Pending
- Catalog browse (search + category filter)
- Product detail (qty picker, add-to-cart)
- Cart → Checkout (shipment choice: GYS direct vs Distributor)
- Payment method picker → mock success
- Order confirmation → Order history → Order detail with status timeline
- Profile

## What's intentionally NOT here
- Real auth, real payment, real backend
- BLoC + Clean Architecture (rebuilt properly in Phase 2)
- Push notifications, offline cache, biometric unlock

See `/Users/syabanf/.claude/plans/users-syabanf-downloads-e-ordering-plat-splendid-dusk.md` for the full plan.
