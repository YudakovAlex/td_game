# Rune Siege TD — Art Recipe

All art uses a low-resolution painted fantasy RTS style, viewed from a top-down three-quarter angle. Use a subdued grassland palette, strong silhouettes, and warm upper-left lighting. Avoid outlines that disappear against the map, photorealism, text, watermarks, and cast shadows baked into entity sprites.

## Export rules

- Export RGBA PNGs with transparent backgrounds at 128×128; important detail must remain readable when drawn at 32–52 logical pixels.
- Terrain tiles are seamless square 128×128 images. Entity sprites are centered with 10% transparent padding.
- Towers face right in source art. Runtime rotation supplies aiming direction.
- The runtime atlas is `assets/sprite_atlas.png`: a 6×4 grid in the `Asset_Id` order declared in `src/game.odin`. Replacing it requires no code changes.
- Keep lighting, camera, saturation, and scale consistent across a generation batch. Inspect assets at their in-game size before accepting them.

## Generation prompt template

“Low-resolution hand-painted fantasy RTS game sprite, top-down three-quarter orthographic view, strong readable silhouette, subdued grassland palette, warm upper-left light, centered, isolated on perfectly flat chroma-key background, no cast shadow, no text, no watermark, designed to remain readable at 40 pixels.”

Generate entities on a flat chroma-key background, remove it to alpha, then crop to a square with consistent padding. Terrain tiles should instead be seamless and fully opaque.
