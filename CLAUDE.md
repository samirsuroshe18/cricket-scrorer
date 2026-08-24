# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`cricket_scorer` — a Flutter cricket scoring app (live scores, teams, ball-by-ball actions, match stats). GetX provides state management, DI, and routing. Dio for networking, Floor (SQLite) for local persistence, Firebase for push notifications, FFmpeg for media compression. Supports English/Hindi/Marathi with remote translation sync, plus light/dark theming.

`auth` and `scoring` are the built features; `home` is a stub. Treat `features/auth/` as the reference implementation for the patterns below, and `features/scoring/` as the newer example — it follows the same layering and is the better template for DTO naming (`*_req.dart` / `*_res.dart`) and for socket-backed state.

### Commands

```bash
flutter pub get

# Run — three flavors via separate entrypoints
flutter run -t lib/main_dev.dart
flutter run -t lib/main_uat.dart
flutter run -t lib/main_prod.dart

# Build (pass both -t and --flavor)
flutter build apk -t lib/main_prod.dart --flavor prod
flutter build ios -t lib/main_prod.dart --flavor prod

flutter analyze                     # must be clean for lib/ before done
flutter test                         # all tests
flutter test test/widget_test.dart   # single file

# Codegen — required after touching any @entity/@dao/@Database (Floor)
# or @JsonSerializable class, else *.g.dart goes stale
dart run build_runner build --delete-conflicting-outputs
```

`flutter analyze` also reports pre-existing errors from the vendored `build/ios/SourcePackages/` cache — ignore those and check only `• lib/` lines:

```bash
flutter analyze 2>&1 | grep -E "• lib/" || echo "lib/ CLEAN"
```

**Formatting**: `lib/` is *not* globally `dart format`-clean (36 of 161 files would be reformatted — only 9 are `*.g.dart`; the rest are mostly `core/services/`, plus assorted older widgets and enums). Never run `dart format lib` — it buries a real change in hundreds of unrelated lines. Format only the files you touched: `dart format <paths…>`.

Android flavors live in `android/app/build.gradle.kts` and must stay in sync with `lib/config/flavors.dart` and the `lib/main_*.dart` entrypoints.

**Device selection for running/testing the app.** Testing on an emulator is completely acceptable. Run `flutter devices` first, then pick in this order: (1) a connected, running physical device wins; (2) otherwise an already-running emulator; (3) if neither is available, **stop and ask the user to start or connect one** — do not proceed without a device. **Never launch, boot, or enable an emulator or simulator yourself** (`flutter emulators --launch`, `xcrun simctl boot`, etc.) — only detect and use one that is already running. The user starts devices on their own schedule.

## Architecture

Clean Architecture, feature-first. Each feature under `lib/features/<feature>/` splits into `data` / `domain` / `presentation`; `lib/core/` holds cross-feature infrastructure; `lib/config/` holds app bootstrap, flavors, theming, routing.

**Layering rule** — feature business logic always flows:

```
Page → Controller → UseCase → Repository → DataSource (ApiService / DAO)
```

Controllers must never touch `ApiClient`, a DAO, or a repository directly.

**The one exception**: app-wide cross-cutting concerns (theme, language/locale, notifications, compression) live in a `core` `GetxService` — `ThemeService`, `LanguageService`, `CompressionService` — which controllers and pages may call directly via `Get.find<T>()`, and which may themselves call usecases internally. Don't use this as precedent for skipping the usecase layer on feature logic.

### Bootstrap sequence

1. `lib/main_{dev,uat,prod}.dart` — preserves the native splash, sets `AppFlavor.setAppFlavor(...)`, calls `InjectionContainer.init(flavorConfig: ...)`, then `AppConfig.setup()`. These three files differ only in flavor.
2. `InjectionContainer.init()` runs `CoreInjection.init()` (all app-wide singletons, `Get.putAsync(..., permanent: true)`) → `GlobalInjection.init()` → one `<Feature>Injection.init()` per feature (`Get.lazyPut(..., fenix: true)`).
3. `AppConfig.setup()` locks portrait orientation and runs `GetMaterialApp`, wired to `AppPages.routes`, `AppTheme.lightTheme`/`darkTheme`, and `LanguageService.appTranslations`.

## Folder Structure & Where New Code Goes

```
lib/
  config/
    flavors.dart, flavor_config.dart      # Flavor enum + per-flavor baseUrl
    environment/app_environment.dart      # raw base URLs
    routes/app_routes.dart                # route path string constants
    routes/app_pages.dart                 # GetPage list (page + binding)
    theme/                                 # AppTheme, custom_themes/, palettes/
  core/
    di/injection/                          # core_injection, global_injection, <feature>_injection
    network/                               # ApiClient, interceptors/, models/
    database/                              # AppDatabase (Floor), converters/
    services/                              # GetxService singletons
    error/cricket_failure.dart             # typed failure hierarchy
    usecase/usecase.dart                   # UseCase<T, P> base contract
    utils/                                 # either_util.dart, validators.dart
    extensions/                            # space_extension, theme_x, app_custom_colors, string_extension
    translations/                          # TranslationKeys + en/hi/mr maps
    global/                                # shared widgets + app-wide feature slices
    constants/
  features/<feature>/
    data/
      <feature>_endpoint.dart              # ALL API paths for this feature
      data_sources/remote/<x>_api_service/ # Dio calls via injected ApiClient
      data_sources/local/DAO/              # Floor DAOs — only if offline needed
      models/request/, models/response/    # DTOs (+ generated .g.dart)
      repositories/<x>_repository_impl.dart
    domain/
      repositories/<x>_repository.dart     # abstract contract
      usecases/<action>.dart
    presentation/
      bindings/<x>_binding.dart
      controllers/<x>_controller.dart
      pages/<x>_screen.dart
      widget/                              # feature-local widgets
```

### Adding a new feature

Create **only the layers you need** — don't scaffold empty folders. For a feature that hits the network with no offline caching, skip `data_sources/local/` and the DAO entirely.

1. `data/<feature>_endpoint.dart` — a plain class with `final String` fields for every API path. One per feature; never inline path strings in the ApiService.
2. `data/data_sources/remote/<x>_api_service/` — takes `ApiClient` + the endpoint class via constructor injection.
3. `data/models/request/` + `data/models/response/` — `@JsonSerializable` DTOs, then run `build_runner`.
4. `domain/repositories/` contract, `data/repositories/` impl.
5. `domain/usecases/<action>.dart` — one class per action.
6. `presentation/bindings/`, `controllers/`, `pages/`.
7. Write `<Feature>Injection.init()` in `core/di/injection/` and call it from `InjectionContainer.init()`.
8. Register the route in `AppRoutes` (path constant) and `AppPages` (page + binding).

A screen with no API of its own can be presentation-only (see `features/home/`) and reuse other features' usecases.

## State Management (GetX)

- **Pages**: `GetView<XController>` + `Obx` around only the widgets that actually react. Access the controller via the inherited `controller` getter. Every page in the codebase follows this — don't reintroduce a `GetBuilder` wrapper around a whole `Scaffold` (no controller calls `update()`, so it only costs rebuilds). Private presentational sub-widgets with no controller stay plain `StatelessWidget` (see `_OtpBox`).
- **Controllers**: `GetxController` holding `Rx`/`RxBool`/`Rx<T?>` state plus injected usecases. Dispose every `TextEditingController` in `onClose()`.
- **Bindings**: only wire the controller's constructor from `Get.find<UseCase>()` — no other logic.
- **Loading state**: no single mandated pattern. `CricketLoaderDialog.show()/hide()` for full-screen blocking actions; a local `isLoading` `RxBool` + `Obx` for inline/button-level spinners. Pick per screen — but note every existing screen uses the dialog, so there's no in-repo example of the local pattern to copy (don't add an `isLoading` field unless a widget actually watches it).
- **Navigation**: GetX named routes only — `Get.toNamed`/`Get.offNamed`/`Get.offAllNamed` with `AppRoutes` constants. Pass data via `arguments:`.

## API / Networking Conventions

- All traffic goes through the shared `ApiClient` (`core/network/api_client_service.dart`) — a single `Dio` instance with `baseUrl` from the active `FlavorConfig`, plus `AuthInterceptor` and (debug-only) `PrettyDioLogger`.
- `ApiClient.get/post/put/delete` return `Future<Either<ApiResponseModel, CricketFailure>>` and **never throw** — errors are normalized internally.
- **`Either<R, F>` (`core/utils/either_util.dart`) is the result type end-to-end**:
  - DataSource → `Either<ApiResponseModel, CricketFailure>`
  - Repository → translates to `Either<CricketResponse<T>, CricketFailure>` (parses `.result.data` into the DTO, forwards `.result.message`)
  - Controller → branches on `.isResult` / `.isFallback`
- Errors map to typed `CricketFailure` subclasses in `ApiClient._handleError` (`CricketNoInternetFailure`, `CricketBadRequestFailure`, `CricketUnauthorizedErrorFailure`, `CricketForbiddenErrorFailure`, `CricketNotFoundErrorFailure`, `CricketServerErrorFailure`, `CricketSomethingWentWrongFailure`). Surface them with `CricketSnackbar.showErrorMessage(response.fallback.message)`.
- Token refresh on 401 is handled centrally in `core/network/interceptors/auth_interceptor.dart` — don't reimplement it per-call.
- `ApiClient.cancelAllRequests()` on logout / teardown.
- File uploads: build `FormData` in the repository impl (see `AuthRepositoryImpl.updateProfile`), not in the controller.

## Offline scoring

**The scoring feature exists; the offline half does not.** `features/scoring/` scores runs, extras and wickets against the live backend, renders server-computed strike, and prompts for the next bowler at over completion — but there is still **no queue and no sync code**, and Floor still holds only `UserDetails`. Everything below therefore still applies to the work that remains. This section records the constraints and the open design so the first person to build it doesn't invent a fourth pattern. Offline tolerance is the highest-risk part of the product and is Phase 1 acceptance criteria, not a later pass; see the workspace [CLAUDE.md](../CLAUDE.md) for the backend side of the contract.

**Where a pending ball queues.** Floor is already the local database (`core/database/app_database.dart`) and is the right home — don't add Hive, Isar, or a raw sqflite table alongside it. Two things follow from the current state: the schema is `@Database(version: 1)` with a single entity (`UserDetails`), so adding a pending-event entity means bumping the version and writing a Floor migration; and the existing DAO lives under a feature (`features/auth/data/data_sources/local/DAO/`), so a scoring queue belongs under the scoring feature's `data/data_sources/local/`, not in `core/`. The backend's `BallEvent` is append-only and ordered by `absoluteBallSeq`, so the local queue is an append-only log replayed in order — not a mutable "current match state" row.

**What triggers a sync attempt.** Nothing in the app can detect this today: there is **no `connectivity_plus` dependency** and **no `WidgetsBindingObserver` / `didChangeAppLifecycleState` anywhere in `lib/`**. All three plausible triggers — connectivity restored, app resumed, manual retry — therefore need new plumbing, and a connectivity package is a dependency decision to confirm before adding. Whatever drives it, the flush belongs in a `GetxService` (the established home for app-wide cross-cutting concerns, alongside `ThemeService` / `LanguageService`), not in a screen controller that dies with its route mid-over.

**How sync state surfaces to the scorer — recommendation, needs confirmation.** A scorer has to trust the app isn't quietly losing their work, so the recommendation is a **persistently visible indicator on the scoring console** — pending-ball count and last-synced state, always on screen rather than a transient snackbar — plus a manual retry affordance. A silent background sync is the riskier choice here: when it fails, the scorer discovers it after the match. This is a **product decision to confirm, not settled** — don't build the silent version by default because it's less UI work.

**Conflict handling is decided: reject-and-alert.** A conflicting write is refused server-side and must be surfaced to the scorer — never resolved client-side by retrying over it or by last-write-wins. This is the concrete reason the indicator above needs to be visible: a rejection with nowhere to appear is indistinguishable from data loss.

Idempotency is **solved** and already used: `ScoreBallReq.idempotencyKey` carries a client-generated UUID v4 per delivery, and replaying a key returns the original result instead of appending a duplicate. A queued ball whose response was lost is therefore safe to retry.

Still unresolved, and not to be decided in client code: **`select-bowler` is a second kind of queued event.** It is order-dependent against the balls around it — a queue holding only deliveries cannot replay an over boundary, because the first ball of the new over is refused with `BOWLER_NOT_SELECTED` until a bowler is chosen. Whatever the queue turns out to be, it has to carry both kinds in order.

## Naming Conventions

| Thing | File | Class |
|---|---|---|
| Use case | bare action, `login.dart`, `get_user.dart`, `resend_otp.dart` — **never** `login_usecase.dart` | `LoginUseCase`, `GetUserUseCase` |
| Repository | `auth_repository.dart` / `auth_repository_impl.dart` | `AuthRepository` / `AuthRepositoryImpl` |
| API service | `user_api_service.dart` | `UserApiService` |
| Endpoints | `auth_endpoint.dart` | `AuthEndpoint` |
| Controller | `login_controller.dart` | `LoginController` |
| Binding | `login_binding.dart` | `LoginBinding` |
| Page | `login_screen.dart` — use the `_screen` suffix; `home_page.dart`/`HomePage` is the lone outlier under `features/`, don't copy it (`core/global/presentation/pages/cricket_image_preview.dart` is a second, outside features) | `LoginScreen` |
| DI | `auth_injection.dart` | `AuthInjection` |
| Request/response DTO | `register_req.dart`, `verify_otp_res.dart` | `RegisterReq`, `VerifyOtpRes` |

- Files `snake_case`, classes `PascalCase`, always `package:` imports. **The lint does not fully cover this**: `avoid_relative_lib_imports` only flags paths containing `lib/`, so a same-directory import like `import 'cricket_text.dart';` passes analysis while still violating the convention. Check imports by eye — grep for `^import '` lines that start with neither `package:` nor `dart:`.
- Shared-widget prefixes in `core/global/widgets/` are not uniform — match the neighbours rather than renaming:
  - `Cricket*` — design-system primitives and app-specific widgets (`CricketButton`, `CricketText`, `CricketTextField`, `CricketImage`, `CricketSnackbar`, `CricketErrorWidget`, `CricketHeadline`). Prefer this for anything new.
  - `Custom*` — app chrome / overlay helpers (`CustomAppBar`, `CustomBottomSheet`).
  - Unprefixed — small composed pickers (`ChooseTheme`, `ChooseLanguage`, `ChoosePhotoOption`, `ThemePickerButton`, `LanguagePickerButton`).
  - Watch out: `dialogue/custom_dialog.dart` actually declares `CricketLoaderDialog` — file and class names don't line up there. Same trap in the usecases: `features/auth/domain/usecases/set_password.dart` declares `ResetPasswordUseCase`, and it's registered under that name in `auth_injection.dart`.
- DTOs live in `data/models/{request,response}/` with explicit `@JsonKey(name: ...)` on every field and a `copyWith` — follow `register_req.dart` / `verify_otp_res.dart`. **Auth predates this and is not a clean reference here:** `login_request_model.dart` (declaring `LoginModel`, no `@JsonKey`, no `copyWith`), `login_response.dart`, `user.dart`, `user_details.dart`, and `onboarding_item.dart` still sit flat in `data/models/`. Don't copy those; don't mass-move them either without checking call sites.

## Testing

Only `test/widget_test.dart` exists and **it currently fails** — it pumps `CricketScorerApp` without running `InjectionContainer.init()`, so `Get.find<LanguageService>()` throws `"LanguageService" not found`. Any widget test that mounts the app must initialize DI first (or stub the services it resolves); a plain `pumpWidget` cannot work. This failure is pre-existing, not a regression.

New usecases, controllers, and repositories should get unit tests going forward; don't treat the current gap as license to skip tests. Mirror the `lib/` path under `test/`. Usecases and repositories are the cheapest to test — they take their collaborators via constructor injection, so pass a fake and assert on the returned `Either`.

## Security Notes

- **Hard rule**: every access token, refresh token, password, or credential goes through `SecureStorageService` only. `SharedPreferenceService` is for non-sensitive state only (logged-in user JSON, onboarding flag, theme, locale). Never put a credential in shared preferences.
- Keys for both stores are centralized in `core/constants/shared_pref_key.dart`.
- On logout: call both `SharedPreferenceService.clearForLogout()` and `SecureStorageService.clearForLogout()`, then `ApiClient.cancelAllRequests()`.
- `AuthInterceptor` reads/writes tokens from secure storage — keep it the single owner of the refresh flow.
- Don't log tokens or full request bodies outside `kDebugMode`.

## Performance Conventions

- **Images**: always render via `CricketImage` (`core/global/widgets/images/`), which routes network images through `CachedNetworkImage` and handles asset/svg/file/network plus fallbacks. Never use `Image.network`, `Image.asset`, `SvgPicture`, or `CachedNetworkImage` directly in feature code. The only files allowed to touch those raw widgets are the image primitives themselves — `cricket_image.dart` and `cricket_image_preview.dart` (the zoomable preview route `CricketImage` navigates to).
- **Uploads**: always run picked images/videos through `CompressionService` before upload — never upload a raw `XFile` from `image_picker`.
- **Lists**: use the builder constructors (`ListView.builder`/`.separated`) for any list that can grow; never map a dynamic collection into a `Column`.
- **Rebuilds**: keep `Obx` as tight as possible around the specific reactive widget — not wrapped around an entire `Scaffold` or page body.
- **Spacing/layout**: use `space_extension` (`16.h`, `12.w`, `24.p`, `8.radius`, `4.rh`) instead of literal `SizedBox`/`EdgeInsets`.
- Prefer `const` constructors wherever possible (lint-enforced).

## Things to Avoid

- **No other state/DI/routing libraries** — don't add `provider`, `riverpod`, `bloc`, `get_it`, or `injectable`. GetX is the only mechanism for all three.
- **No `StatefulWidget` + `setState` for business state** — all mutable state belongs in a `GetxController` as `Rx` values.
- **No direct `Dio` or `package:http` usage** in features — everything goes through the shared `ApiClient`.
- **No `Navigator.push` / `MaterialPageRoute`** — GetX named routes only.
- **No hardcoded user-facing strings** — add a key to `TranslationKeys`, to every locale map (`en.dart`/`hi.dart`/`mr.dart`), **and to the translation CMS** (see below), then use `TranslationKeys.someKey.tr`. The sibling `en.json`/`hi.json`/`mr.json` files are **dead** — nothing in `lib/` reads them and they sit 48 keys behind the `.dart` maps; don't mirror into them, and consider deleting them.
  - **The CMS step is not optional.** `Get.addTranslations` merges per *language*, so the CMS map replaces the local one entirely rather than filling its gaps — a key missing from the CMS renders as the raw key once `LanguageService` syncs, however complete `en.dart` is. Upload via `POST /v1/translations/bulk-update` with `[{key, translations:{en,hi,mr}}, …]` and a bearer token; it `$set`s per key, so it will not disturb existing entries. Don't call `.translation()`. `TranslationKeys` is the *only* string source — the old `ErrorStringConstants` class has been deleted; don't recreate a parallel constants class. Note that where a controller stores a label for the view to render (e.g. `SetPasswordController.strengthLabel`), it stores the **key** and the page applies `.tr`.
- **No raw colors or magic numbers** in widgets — use `context.colorScheme` / `context.colors` (via `theme_x`) and the spacing extensions. Cricket-specific and severity colors are `ThemeExtension` tokens on `AppCustomColors` (`core/extensions/app_custom_colors.dart`, valued per-theme in `config/theme/palettes/app_custom_colors_palette.dart`) — reach them with `context.colors.*`. For severity/meters use `statusDanger` / `statusWarning` / `statusInfo` / `statusSuccess`; add a token to **both** `light` and `dark` rather than hardcoding a `Colors.*` value.
  - `Colors.transparent` and shadow blacks (`Colors.black.withValues(alpha: …)`) are fine — sentinels and scrims, not theme decisions.
  - **Known gap**: `custom_bottomsheet.dart` (10 occurrences) and `dialogue/custom_dialog.dart` (1) still hold literal `Colors.white` for icons/text drawn over colored surfaces and scrims. Some are deliberate, some likely break dark mode — they need a look at the rendered screens, so don't bulk-replace them blind.
  - **Second, quieter palette**: `core/constants/app_color.dart` (`AppColor.*`, 8 raw `Color(0xff…)` constants) is still referenced by `cricket_snackbar.dart`, `cricket_outlined_button.dart`, `custom_bottomsheet.dart`, `custom_navigation_progress_theme.dart`, and `custom_color_scheme.dart` — mostly as a fallback for when `Get.context` is null. Treat it as legacy: don't add references, and put new colors on `AppCustomColors`.
- **Colors belong in the view, not the controller** — a controller exposes state (a score, an enum, a key), and the page maps it to a color (see `SetPasswordScreen._strengthColor`). Don't store a `Color` in an `Rx`.
- **Import GetX as `package:get/get.dart`** — never reach into `package:get/get_utils/src/...` internals. Note the two sources of theme getters: `context.colorScheme` / `context.colors` / `context.isDark` come from our own `theme_x` extension, while `context.textTheme` and `context.theme` come from GetX's context extension — a widget using both needs both imports.
- **Don't duplicate shared validators** — call `Validators.email` / `Validators.password` (`core/utils/validators.dart`). Only field-specific rules (e.g. confirm-password comparing another field) stay local to a controller.
- **Don't bump the pinned codegen versions** — `json_annotation ^4.9.0`, `build_runner ^2.4.13`, `json_serializable ^6.8.0` are pinned deliberately in `pubspec.yaml`.
- **Don't hand-edit `*.g.dart`** — regenerate with `build_runner`.
- **Don't build scoring as online-first** and plan to add sync later, and don't invent a second local-persistence mechanism next to Floor — see [Offline scoring](#offline-scoring).
- **Don't register feature dependencies in `CoreInjection`** — they belong in that feature's own `<Feature>Injection`.

## Lints

`analysis_options.yaml` enables `strict-casts`, `strict-inference`, `strict-raw-types`; upgrades `missing_required_param`/`missing_return` to errors; and enforces `prefer_single_quotes`, `require_trailing_commas`, `always_declare_return_types`, `unawaited_futures`, `avoid_relative_lib_imports`, and the `prefer_const_*` rules. `*.g.dart` is excluded from analysis.
