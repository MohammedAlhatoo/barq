# AGENTS.md — Barq (برق) monorepo

> قواعد Claude Code (وأي مساعد ذكي) بهاد المشروع. اقرأه كامل قبل أي تعديل.
> Rulebook for the AI agent building this repo. Read it fully before changing anything.

## 1. What this project is
Barq is a grocery/delivery platform with **two Flutter apps** sharing one REST API:
- `apps/customer` — the customer app (light theme).
- `apps/driver` — "Barq Captain" driver app (dark theme).

One AI agent (Claude Code) builds everything, phase by phase, following `docs/PLAN.md`.
A team of 4 students reviews every phase, discusses it and must understand the code — so clarity beats cleverness.

API base: `https://masar.toldpath.com/api/v1` · OpenAPI: `docs/api/openapi.json` · Notes: `docs/api/API_NOTES.md`.

## 2. Repo layout
```
apps/customer/            customer app
apps/driver/              driver app
packages/barq_ui/         design system — ALL visuals (colors, fonts, icons, widgets)
packages/barq_core/       API client, auth, config, uploads, polling, status widgets
docs/PLAN.md              the build order (phases) — always work from here
docs/tasks/0N_*.md        detailed specs per area (screens, endpoints, notes)
docs/notes/phase-N.md     Arabic explanation of each finished phase (written by you)
docs/design/screens/      final design PNGs (one per screen) — look at them
docs/design/html/         design source HTML/CSS — exact sizes, colors, texts
docs/design/overlay/      frameless PNGs used by DesignOverlay
docs/api/                 openapi.json, Postman collections, API_NOTES.md
docs/ARCHITECTURE.md      folder structure, state management, barq_core contract
```

## 3. Hard rules
1. **Screens use only `package:barq_ui/barq_ui.dart`.** Never hard-code a color, font, radius, shadow or spacing inside a screen; never re-create a widget that barq_ui has. See `packages/barq_ui/README.md` §4 (CSS → Widget map).
2. If a widget/token is missing: **add it to barq_ui** (right file in `lib/src/widgets/`, export it, add an example to `BarqGallery`), then use it. Never draw it inside a screen.
3. **Never invent API fields.** Check `docs/api/openapi.json` for exact paths, bodies and responses. All requests go through `ApiClient` from barq_core — no other Dio/http client.
4. **The server decides, the app displays:**
   - Prices: show `Money.formatted`; never calculate prices or totals. **Only exception:** `Money.savedAgainst` in `packages/barq_core/lib/src/models/money.dart` gives the difference between two server totals for the "وفّر X" label. Display only: it never affects an amount sent to the server or charged.
   - Order statuses: labels/colors/steps from `GET /app/config` (`ConfigStore.statuses`). Never hard-code status names. **Exception:** `OrderTimelines` in `packages/barq_core/lib/src/status/order_timelines.dart` lists which status keys each screen's timeline shows, plus `offerWaiting` for the active-order bar; labels and colors still come from config.
   - Customer buttons from `available_actions`; driver buttons from `next_action` (`to`, `label`, `requires`, `geofence_meters`, `confirm`). Never hard-code the order flow.
   - Durations (quote expiry, offer TTL, geofence, polling) from responses/config, never constants.
5. **Every screen has loading, empty and error states.** Errors show `ApiException.messageAr`.
6. Arabic first, RTL. All user-visible strings in the app's `.arb` files (Arabic + English).
7. Wrap every screen with `DesignOverlay(image: 'design/<screen>.png', child: …)` and compare with the PNG before calling it done. `design/` is not in the apps' pubspec, so add it back while comparing and never ship it in a release build.
8. **Never commit the project key** (`pk_test_…`). It comes from `--dart-define=BARQ_PROJECT_KEY`.
9. Simple, readable code: small widgets, no clever abstractions, no new packages without asking the user.
10. After each task: `flutter analyze` clean and `dart format .`.

## 4. Business facts (config_version 3 — override older docs)
- `delivery_confirmation = "photo"`: driver photo → `POST /uploads` (purpose `proof_photo`) → `POST /driver/orders/{id}/deliver` with `upload_ids`. **No delivery code/OTP is shown to the customer.**
- Driver login = **phone + password**. Customer login = phone + OTP.
- Payment: `cash_on_delivery` only.
- No push notifications and no Firebase (instructor decision). Notifications are the in-app list from the API.
- Weighed products: `awaiting_pricing` → `priced`; customer approves/rejects the offer before `expires_at`.
- Brand: barq_ui colors (orange `#FF7A21`). Ignore `project.colors` from config.

## 5. How to work
1. Take the next unchecked phase/step from `docs/PLAN.md`. Do **one phase at a time** and stop for review at the end of each phase.
2. For each screen: open the PNG in `docs/design/screens/`, read its section in `docs/design/html/<group>.html`, read its spec in `docs/tasks/`, check endpoints in `openapi.json`.
3. Feature folder layout: `data/` (repository) · `state/` (Cubit) · `ui/` (screen + widgets).
4. Run on the emulator, compare with the design (DesignOverlay / screenshot), fix differences.
5. `flutter analyze` clean → tick the step in `docs/PLAN.md`.
6. **End of phase:** write `docs/notes/phase-N.md` in simple Arabic for the team: what was built, which files, why it is built this way, how data flows, and 3–5 questions the team should be able to answer. Then commit and tell the user the phase is ready for review.

## 6. Code conventions
- State: `flutter_bloc` **Cubit** only. One Cubit per screen/flow. Immutable states.
- Navigation: `go_router` in `lib/app/router.dart`.
- Files `snake_case.dart`, classes `PascalCase`, one public widget per file.
- Models: hand-written `fromJson`, only the fields used.
- No `print` (use `debugPrint`), no commented-out code.
- Branch per phase: `phase-N-name`. Commits: `phase-N: short english description`.
