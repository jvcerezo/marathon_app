# Bakas

> Bakas (Filipino for "trace" or "footprint") prepares a complete beginner for
> their first marathon within 365 days, with a personalized training plan and
> every session recorded via GPS. Every run leaves a bakas.

## What the app does

1. **Onboard** the user: age, gender, height, weight, current fitness, optional
   recent run, days-per-week, target race date.
2. **Estimate current VDOT** (Jack Daniels' VO2max proxy) from those inputs,
   using the recent-run formula when available and a demographic fallback
   otherwise.
3. **Generate a 52-week plan** scaled to the user's starting fitness:
   foundation → base → build → peak → taper. Each week mixes easy runs, a long
   run, optional tempo or interval work, and rest days.
4. **Record runs via phone GPS**: 1 Hz sampling, outlier rejection, Kalman
   smoother, auto-pause, foreground-service-backed background recording.
5. **Match each run** against the day's prescribed session and mark it hit,
   partial, or missed.
6. **Show progress**: streak, weekly mileage, plan adherence, and a
   continuously-recalculated marathon-time prediction.

## Architecture

```
lib/
├── core/
│   ├── database/        Drift SQLite schema + database
│   ├── format/          Pace/distance/duration formatters
│   ├── math/            Haversine, polyline encode/decode + simplification
│   ├── providers/       Riverpod providers for repositories and services
│   ├── routing/         go_router config
│   └── theme/           Material 3 theme
└── features/
    ├── adherence/       Match completed runs to scheduled sessions
    ├── fitness/         VDOT calc, race-time prediction, training paces
    ├── home/            Today screen
    ├── onboarding/      5-step setup flow
    ├── plan/            Plan engine, models, calendar screen
    ├── profile/         User profile model + repository
    ├── progress/        Streaks, weekly mileage, predictions
    ├── recording/       GPS pipeline + recording screen
    ├── runs/            Completed runs history + detail screens
    └── shell/           Bottom navigation shell
```

Domain models are plain Dart classes. Drift generates row classes with
`...Row` suffix (e.g. `UserProfileRow`) so they don't clash with domain types.

## Tech stack

- Flutter (Dart 3.11) — single codebase
- Riverpod — state and DI
- drift — local SQLite, codegen
- go_router — routing
- geolocator — GPS stream + Android foreground service
- flutter_map + OpenStreetMap tiles — free map rendering
- fl_chart — weekly mileage bar chart

## GPS pipeline

```
geolocator stream → OutlierFilter → LocationSmoother → RunRecorder
                                                          └──► persist every 10s (drift)
```

- **OutlierFilter** drops samples worse than 30 m accuracy and any sample that
  would imply > 15 m/s instantaneous speed.
- **LocationSmoother** runs independent 1D Kalman filters on lat and lon,
  trusting newer measurements more when their reported accuracy is high.
- **RunRecorder** computes distance via Haversine, auto-pauses below 0.5 m/s
  for 10 s, and broadcasts cleaned samples on a stream.
- **RecordingService** subscribes, buffers samples, and flushes to SQLite
  every 10 s so a crash mid-run loses at most 10 s of data.

The polyline gets simplified with Douglas-Peucker (4 m tolerance) and
encoded (Google polyline format) at run finalization for compact rendering.

## Training plan generation

The 52-week plan is phased:

| Phase      | Weeks   | Volume curve    | Long run       | Quality work          |
|------------|---------|-----------------|----------------|-----------------------|
| Foundation | 1-12    | 12 → 28 km      | 4 → 11 km      | None                  |
| Base       | 13-24   | 28 → 44 km      | 10 → 18 km     | Tempo only            |
| Build      | 25-36   | 44 → 55 km      | 16 → 26 km     | Tempo + intervals     |
| Peak       | 37-48   | 55 → 64 km      | 24 → 32 km     | Marathon-pace tempo   |
| Taper      | 49-52   | 50 / 35 / 22 / race | 26 / 18 / 12 / 42.2 | Sharpen        |

Every fourth week (except taper) is a 25% cutback for recovery. Volume is
scaled by a per-fitness-level factor:

- `none`: 0.65×, `beginner`: 0.8×, `recreational`: 1.0×, `intermediate`: 1.15×

## Running the project

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Known MVP gaps

- iOS not configured (Android-only scaffold).
- Watch integration (Wear OS / Apple Watch) not built.
- Cloud sync deliberately deferred — local-first by principle.
- Plan editor (skip a week, shift sessions) not implemented.
- Settings screen not implemented.
- Crash recovery: orphaned-run sweep is wired in `RunsRepository` but not
  surfaced in UI.

