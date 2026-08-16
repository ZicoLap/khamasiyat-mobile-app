# Development stadium photography

## Status

The customer catalog list UI is designed around real `primaryPhoto.url` values from
`GET /api/v1/stadiums`.

Local/dev seed data may currently return `primaryPhoto: null` for many (or all)
stadiums. When that happens, the app correctly shows a branded missing-photo
fallback — but screenshots and UX review should not treat that empty state as
the primary product look.

## Do / don't

- **Do** attach stadium photo metadata in the backend/admin tooling or seed so
  list items include a public `primaryPhoto.url`.
- **Do** keep the Flutter missing-photo fallback tested.
- **Don't** hardcode fake production stadiums or photo URLs inside the Flutter
  customer app.

## Evaluating UI with photography

For widget tests and visual review harnesses, inject fixture stadiums via the
fake catalog remote (`test/helpers/fake_catalog_remote.dart`) with optional
`photoUrl` values. Network images in goldens use a test-only solid-color
`ImageProvider` hook (`StadiumPhoto.debugImageProviderForUrl`) — not production
data.

Home visual approval frames: [`docs/f2.3.1-visual-review/`](f2.3.1-visual-review/).
Filter-sheet frames: [`docs/f2.2-visual-review/`](f2.2-visual-review/).

Recommended backend follow-up (outside this mobile phase): ensure seed/demo
stadiums include at least one primary photo URL so device smoke screenshots
match the intended discovery experience.
