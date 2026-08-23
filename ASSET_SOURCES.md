# Asset Sources and Usage

## Current M00 assets

The engine spike contains no downloaded art, audio, fonts, models, textures, logos, voice recordings, or third-party placeholder assets.

All visible 3D content is assembled at runtime or in Godot scenes from built-in primitive meshes:

- boxes for floors, walls, corridors, pipes, desks, anchor structures, and room accents;
- low-segment spheres for fungal growths, lamps, and environmental accents;
- Godot's default font for interface and world labels;
- original solid-color materials authored for this project.

The three enemy sprites and Picket portrait are original 32 by 40 pixel images generated deterministically at runtime by `scripts/visual/pixel_sprite_factory.gd`. They use project-authored shapes and colors and no external source images or model output.

The item names, enemy names, descriptions, power text, labels, party names, and commentary in the crawler build are original project text.

## M04A generated visual set

The following raster sheets were generated specifically for this project with OpenAI's built-in image generation tool on 2026-08-23. They were directed from the project's original Gutterbloom characters, enemies, equipment, palette, and an earlier project-generated first-person composition reference. No downloaded game art, franchise screenshot, third-party texture, commercial asset pack, or artist portfolio image was supplied as a reference.

| Project file | Contents | Production use |
| --- | --- | --- |
| `art/concepts/first_person_promo_reference.png` | Earlier project-generated first-person shaded-pixel composition | Composition target only |
| `assets/generated/party_portraits.png` | Dena, Moss, Vell, and Ilex portrait sheet | Lower combat HUD and Archive context |
| `assets/generated/crawler_enemies.png` | Filing Larva, Pipe Goblin, and Form Auditor sheet | First-person enemy billboards |
| `assets/generated/equipment_icons.png` | Sixteen original weapon, armor, implement, charm, and relic icons | Commands, party equipment, and Archive list |
| `assets/generated/dungeon_materials.png` | Gutterbloom wall, floor, pipe, and fungal material quadrants | Runtime room materials |

Generation prompts required original shaded lo-fi pixel art, heavy inked silhouettes, teal and magenta sewer lighting, warm brass interface accents, no text, no logos, no watermarks, no protected characters, and visual consistency with the project-generated composition. Portrait, enemy, and equipment prompts requested isolated subjects in even grids. The generator baked a light checker pattern instead of true transparency, so `scripts/visual/generated_asset_library.gd` removes only high-value neutral checker pixels in memory when the game loads. Source PNG files remain unmodified.

These files are project-owned generated outputs subject to the applicable OpenAI service terms. If the project approaches commercial distribution, the release gate must still perform similarity review, provenance review, final human art direction, and any legal review considered appropriate. This record is provenance, not a warranty of exclusive rights.

## Production rule

Any future external asset must record its creator, source URL or purchase record, license, allowed usage, required attribution, modification status, and the files that use it before being committed. Unverified assets stay outside the repository.
