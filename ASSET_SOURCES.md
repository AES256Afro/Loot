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

## Production rule

Any future external asset must record its creator, source URL or purchase record, license, allowed usage, required attribution, modification status, and the files that use it before being committed. Unverified assets stay outside the repository.
