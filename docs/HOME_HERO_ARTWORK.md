# Home hero decorative artwork

## Status

F2.3.1 reserves a decorative artwork slot in the Home hero.

Production currently ships **without** artwork (`HomeHeroArtwork.enabled = false`)
until a final approved asset is provided.

## Slot

| Spec | Value |
|------|--------|
| Asset path | `assets/branding/home_hero_football.png` |
| Display size | 112×112 logical px |
| Aspect ratio | 1:1 |
| Recommended source | 512×512 (or 256×256) transparent PNG/WebP |
| Max visual weight | ~20–30% of hero |

## Placement

- LTR: trailing / lower area beside headline + support
- RTL: leading side via `AlignmentDirectional` (do not mirror the bitmap)

## Enabling

1. Replace `assets/branding/home_hero_football.png` with the final illustration
   (compress to ~100–200KB WebP/PNG if possible; current review file is ~1.1MB).
2. Set `HomeHeroArtwork.enabled = true` in `home_hero_artwork.dart`.
3. Re-run visual review on EN/AR 320 & 390.

## Style brief

Premium 3D football + short turf, soft studio light, no text, no players,
no neon, no mascots. Decorative only — headline stays primary.
