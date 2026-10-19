#!/usr/bin/env python3
"""Draw the link-preview card for the showcase (public/og-image.png).

Link previews (LinkedIn, Facebook, Slack) need an absolute image URL, which is
why index.html points at https://interop.pattygcoding.com/og-image.png.  The
card is committed rather than built, so this script is only run when the wording
or the counts change::

    python tools/generate_og_image.py

It needs Pillow (``pip install pillow``), and the fonts Windows ships; on another
platform it falls back to Pillow's built-in bitmap font.
"""

from __future__ import annotations

import os
import sys

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTPUT = os.path.join(ROOT, "public", "og-image.png")

WIDTH, HEIGHT = 1200, 630
NAVY = (5, 7, 12)
PANEL = (13, 19, 30)
MINT = (141, 235, 196)
GUEST = (125, 211, 252)
TEXT = (233, 240, 238)
MUTED = (140, 156, 160)

FONTS = os.path.join(os.environ.get("WINDIR", "C:\\Windows"), "Fonts")


def font(name: str, size: int):
    try:
        return ImageFont.truetype(os.path.join(FONTS, name), size)
    except OSError:
        return ImageFont.load_default(size)


def main() -> int:
    image = Image.new("RGB", (WIDTH, HEIGHT), NAVY)
    draw = ImageDraw.Draw(image)

    # The thin mint rule the site's favicon shares.
    draw.rectangle((0, 0, WIDTH, 8), fill=MINT)

    # Two panels facing each other: a host on the left, a guest on the right, with
    # the arrow between them standing in for the bridge.
    panel_w, panel_h, gap = 230, 156, 90
    left = WIDTH - 60 - (2 * panel_w + gap)
    top = (HEIGHT - panel_h) // 2 + 10
    for index, colour in ((0, MINT), (1, GUEST)):
        x = left + index * (panel_w + gap)
        draw.rounded_rectangle(
            (x, top, x + panel_w, top + panel_h), radius=18, fill=PANEL, outline=(30, 44, 62), width=2
        )
        draw.rounded_rectangle(
            (x + 22, top + 22, x + 22 + 96, top + 22 + 12), radius=6, fill=colour
        )
        for line in range(3):
            y = top + 60 + line * 24
            draw.rounded_rectangle((x + 22, y, x + panel_w - 32 - line * 36, y + 9), radius=4, fill=(38, 48, 63))

    arrow_y = top + panel_h // 2
    draw.line((left + panel_w + 14, arrow_y, left + panel_w + gap - 14, arrow_y), fill=MUTED, width=3)
    draw.polygon(
        [
            (left + panel_w + gap - 14, arrow_y),
            (left + panel_w + gap - 30, arrow_y - 10),
            (left + panel_w + gap - 30, arrow_y + 10),
        ],
        fill=MUTED,
    )

    # Text on the left.
    draw.text((70, 108), "TWO LANGUAGES  /  ONE PROGRAM  /  88 SAMPLES", font=font("consola.ttf", 20), fill=MINT)
    heading = font("segoeuib.ttf", 66)
    draw.text((70, 162), "Interop", font=heading, fill=TEXT)
    draw.text((70, 244), "Samples", font=heading, fill=MINT)
    body = font("segoeui.ttf", 27)
    draw.text((70, 366), "Native linking, child processes,", font=body, fill=MUTED)
    draw.text((70, 404), "pipes, ports and embedding -", font=body, fill=MUTED)
    draw.text((70, 442), "one average calculator, 88 ways.", font=body, fill=MUTED)
    draw.text((70, 546), "interop.pattygcoding.com", font=font("consola.ttf", 24), fill=MINT)

    image.save(OUTPUT, optimize=True)
    print("wrote %s" % OUTPUT)
    return 0


if __name__ == "__main__":
    sys.exit(main())
