from pathlib import Path

from PIL import Image


SOURCE_DIR = Path("/private/tmp/luma_ppt_render")
OUTPUT_DIR = Path(".codex-work/luma-use-cases")


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for slide_number in range(4, 12):
        source = SOURCE_DIR / f"slide-{slide_number}.png"
        image = Image.open(source)
        width, height = image.size

        # The source deck uses the upper strip for the deck title, page badge,
        # and university mark. The coursework needs the substantive diagram,
        # interface examples, and explanatory note from the same slide.
        crop_box = (
            0,
            round(height * 0.235),
            width,
            round(height * 0.985),
        )
        cropped = image.crop(crop_box)
        cropped.save(OUTPUT_DIR / f"use-case-{slide_number - 3}.png", optimize=True)


if __name__ == "__main__":
    main()
