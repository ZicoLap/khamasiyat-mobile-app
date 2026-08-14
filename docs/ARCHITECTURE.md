# Architecture notes (F0)

## Layers

| Layer | Responsibility |
|-------|----------------|
| `app/` | Composition root: bootstrap, router, theme, l10n |
| `core/` | Cross-cutting infrastructure (HTTP, storage, config, errors, clock) |
| `features/` | Product verticals (empty placeholders in F0 except smoke) |
| `shared/` | Reusable formatting/validation/widgets without feature ownership |

## Feature layout (target for F1+)

```text
features/<name>/
  presentation/   # widgets, screens, controllers
  domain/         # entities, repository interfaces, use-cases
  data/           # DTOs, API mappers, repository implementations
```

F0 does not create empty presentation/domain/data trees for every feature — only
placeholder libraries — to avoid ceremony before real code exists.

## Dependency rules

- Features may depend on `core/` and `shared/`
- Features must not depend on other features' `data/` layers
- Widgets must not construct `Dio` or parse API envelopes
- Tokens never leave `TokenStore` into logs or preferences

## Error flow

1. Transport failure → `ErrorMapper` → `NetworkException` / `UnauthorizedException`
2. Envelope `success: false` → `ApiException` (keeps `code`, `requestId`, `details`)
3. Malformed JSON → `ParsingException`
4. UI maps exceptions to localized copy in later phases

## Auth redirect plan (F1 - implemented)

1. `AuthController` exposes `AuthInitializing` / `AuthUnauthenticated` / `AuthAuthenticated` / `AuthRefreshing`
2. `goRouterProvider` uses `refreshListenable` + `redirect`
3. Unauthenticated users cannot open `/home`
4. Authenticated users are redirected away from login/register/splash
5. `mustChangePassword` forces `/change-password`
6. Concurrent 401s share one refresh via `TokenRefresher` + `AuthRefreshInterceptor`
