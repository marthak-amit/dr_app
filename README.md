# MediQ — Doctor Appointment App (clickable prototype)

High-fidelity Flutter prototype of a doctor-appointment app for **patients** and **doctors**.
Everything is mocked locally (no backend, works fully offline). *MediQ is a placeholder name* — change it in
`lib/core/utils/app_config.dart` (plus `android/app/src/main/AndroidManifest.xml` label and `ios/Runner/Info.plist`).

- Flutter (stable) · Dart 3 · Material 3 · Riverpod · go_router · flutter_animate · fl_chart · lottie · shimmer · flutter_svg · smooth_page_indicator · table_calendar · intl
- Light + dark themes · Plus Jakarta Sans (bundled, no network fetch) · 8-pt spacing grid · coral accent on a teal brand

## Run

```bash
flutter pub get
flutter run                 # any Android / iOS device or emulator
flutter build apk --release # → build/app/outputs/flutter-apk/app-release.apk
flutter analyze             # must stay clean
flutter test                # route smoke test: pumps every screen at 360dp and 430dp wide, fails on overflow
```

Login: any 10-digit phone number and **any 6-digit OTP** are accepted.

## Screens

**Patient app**
1. Splash → Onboarding (3 slides) → Login (phone + OTP) → Profile setup
2. Home (greeting, search, live-queue card, upcoming appointment, specialties, top doctors, health tip)
3. Search & filter (specialty, rating, fee, distance, available today, gender, language, sort)
4. Doctor list → Doctor detail (hero photo, stats, about, clinic map snapshot, reviews, In-clinic / Video toggle)
5. Booking flow (date strip + slots → family member → symptoms → summary & coupon → payment UPI / Card / Pay at clinic) → success (Lottie, add to calendar)
6. Live queue tracker (token, position, wait estimate, doctor status — shared with doctor mode)
7. Appointments (Upcoming / Completed / Cancelled, reschedule & cancel sheets, detail page)
8. Video consult (connecting → call UI, timer, mute / camera / chat / end, summary)
9. Prescriptions (list → detail, signature, "Download PDF")
10. Medicine reminders (timeline, mark taken, add reminder)
11. Health vault (folders, mock file picker upload, preview with zoom)
12. Lab tests (packages, cart, home-collection slot picker)
13. Vitals (BP / sugar / weight charts + add entry)
14. Chat with clinic
15. Notifications
16. Profile (family members, payment methods, language, settings, dark mode, logout, **Switch to Doctor view**)

**Doctor mode** (Profile → *Switch to Doctor view*)
Dashboard · Queue control (Call next / Skip / Done — updates the patient's live queue) · Patient detail · Rx builder (→ "Send to patient" appears in the patient's prescriptions) · Weekly schedule (block slots, mark leave)

## Project structure

```
lib/
  core/        theme (colors, typography, spacing, radius), router, shared widgets, utils
  data/        models/ · mock/ (typed mock data) · repositories/ (Riverpod providers)
  features/<feature>/presentation/{screens,widgets,providers}
assets/        images (doctors, clinics, illustrations) · icons (SVG) · lottie · fonts
```

Reusable widgets (`lib/core/widgets/`): `AppButton`, `DoctorCard`, `SlotChip`, `SectionHeader`, `AppBottomSheet`, `EmptyState`, `ErrorState`, `ShimmerList`, `AppCard`, `AppTextField`, `showAppSnack` …

## Swapping the mock data for a real API

All screens read data **only** through Riverpod providers in `lib/data/repositories/providers.dart`
(`doctorsProvider`, `appointmentsProvider`, `slotsProvider`, `prescriptionsProvider`, `queueProvider`, …).
Mock data lives in `lib/data/mock/*.dart` and fake latency comes from `fakeLatency()`.

1. Create an API client (dio / http) and DTO → model mappers next to the models in `lib/data/models/`.
2. Replace the body of each provider's `build()` / `FutureProvider` (they currently `await fakeLatency()` and return mock lists) with a repository call, e.g.
   ```dart
   final doctorsProvider = FutureProvider<List<Doctor>>((ref) => ref.watch(doctorRepoProvider).fetchDoctors());
   ```
3. Mutations (`AppointmentsNotifier.add/cancel/reschedule`, `RemindersNotifier.toggle`, `PrescriptionsNotifier.add`, …) are already the single write path — make them call the API and then update `state`.
4. `QueueNotifier` is the live queue; swap for a WebSocket / Firestore stream (`StreamProvider`) feeding the same `QueueState`.
5. Slots: replace `generateSlots()` in `lib/data/repositories/slot_generator.dart` with the real availability endpoint.
6. Auth: `sessionProvider` holds the logged-in profile; wire OTP verification into `SessionNotifier.login`.

## Assets & licensing

All assets are generated locally and bundled: doctor portraits are illustrated avatars (DiceBear *Avataaars*, free licence), icons are Lucide (ISC), clinic art and onboarding illustrations were composed for this prototype, and the Lottie animations are hand-authored. All names, clinics, phone numbers and addresses are fictional.

## Downloads & screenshots

- **Install this on almost every phone (2017+):** [`releases/MediQ-arm64-v8a.apk`](releases/MediQ-arm64-v8a.apk) (22 MB). Older 32-bit phones: [`releases/MediQ-armeabi-v7a.apk`](releases/MediQ-armeabi-v7a.apk).
- Requires Android 7.0+. Signed with a real release key (v2 + v3 signature), 16 KB page-aligned, R8-shrunk.
- If Android says *App not installed*: uninstall any older MediQ first (earlier builds used a different signing key), then allow *Install unknown apps* for the app you open the APK from.
- Screenshots of every screen (390×844 @2x, light + dark): [`screenshots/`](screenshots/) — start with the `overview_*.png` contact sheets.
- iOS: open `ios/` in Xcode on a Mac (`flutter build ios`).

## Release signing

`android/app/build.gradle.kts` signs release builds with `android/key.properties` + `android/app/mediq-release.jks` (both git-ignored).
Create your own with:

```bash
keytool -genkeypair -keystore android/app/mediq-release.jks -alias mediq -keyalg RSA -keysize 2048 -validity 10000
# android/key.properties: storePassword=… keyPassword=… keyAlias=mediq storeFile=mediq-release.jks
flutter build apk --release --split-per-abi   # per-ABI APKs
flutter build appbundle --release             # Play Store .aab
```
