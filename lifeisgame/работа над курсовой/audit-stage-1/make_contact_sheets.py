#!/usr/bin/env python3
"""Create readable contact sheets from rendered DOCX pages."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image, ImageDraw


def page_number(path: Path) -> int:
    match = re.search(r"(\d+)$", path.stem)
    return int(match.group(1)) if match else 0


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", type=Path)
    parser.add_argument("output_dir", type=Path)
    parser.add_argument("--columns", type=int, default=4)
    parser.add_argument("--rows", type=int, default=3)
    parser.add_argument("--thumb-width", type=int, default=420)
    args = parser.parse_args()

    paths = list(args.input_dir.glob("page-*.png"))
    if not paths:
        paths = list(args.input_dir.glob("*.png"))
    paths = sorted(paths, key=lambda path: (page_number(path), path.name))
    args.output_dir.mkdir(parents=True, exist_ok=True)
    per_sheet = args.columns * args.rows
    margin = 18
    label_height = 32

    for sheet_index in range(0, len(paths), per_sheet):
        batch = paths[sheet_index : sheet_index + per_sheet]
        thumbs = []
        max_height = 0
        for path in batch:
            with Image.open(path) as image:
                if image.mode in {"RGBA", "LA"} or (
                    image.mode == "P" and "transparency" in image.info
                ):
                    rgba = image.convert("RGBA")
                    flattened = Image.new("RGBA", rgba.size, "white")
                    flattened.alpha_composite(rgba)
                    image = flattened.convert("RGB")
                else:
                    image = image.convert("RGB")
                ratio = args.thumb_width / image.width
                thumb = image.resize(
                    (args.thumb_width, max(1, round(image.height * ratio))),
                    Image.Resampling.LANCZOS,
                )
            thumbs.append((path, thumb))
            max_height = max(max_height, thumb.height)

        canvas = Image.new(
            "RGB",
            (
                margin + args.columns * (args.thumb_width + margin),
                margin + args.rows * (max_height + label_height + margin),
            ),
            "#d8d8d8",
        )
        draw = ImageDraw.Draw(canvas)
        for index, (path, thumb) in enumerate(thumbs):
            row, column = divmod(index, args.columns)
            x = margin + column * (args.thumb_width + margin)
            y = margin + row * (max_height + label_height + margin)
            canvas.paste(thumb, (x, y + label_height))
            draw.text((x, y + 5), f"Page {page_number(path)}", fill="black")

        output = args.output_dir / f"contact-{sheet_index // per_sheet + 1:02d}.jpg"
        canvas.save(output, quality=88)


if __name__ == "__main__":
    main()
