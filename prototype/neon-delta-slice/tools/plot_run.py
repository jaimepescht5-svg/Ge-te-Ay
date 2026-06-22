#!/usr/bin/env python3
"""Top-down diagnostic plot of a selfcheck run.

Reads track.csv + path.csv (written by the selfcheck) and renders a bird's-eye
PNG: the road, the bot's path coloured by speed (red = slow, green = fast),
and the start/end markers. This is a self-observation tool — it turns a wall
of numbers into something the loop (and a human) can read at a glance.

Usage: python3 tools/plot_run.py <userdata_dir> [out.png]
Requires Pillow (dev-time only; not part of the shipped slice).
"""
import csv
import sys
from PIL import Image, ImageDraw

W, H, MARGIN = 1100, 760, 60


def read_track(path):
    pts, road_width = [], 17.0
    with open(path) as f:
        r = csv.reader(f)
        next(r)
        for row in r:
            if row[0] == "road_width":
                road_width = float(row[1])
            else:
                pts.append((float(row[0]), float(row[1])))
    return pts, road_width


def read_path(path):
    rows = []
    with open(path) as f:
        for d in csv.DictReader(f):
            rows.append((float(d["x"]), float(d["z"]), float(d["speed"]), int(d["off"])))
    return rows


def main():
    base = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else base + "/run_topdown.png"
    track, road_width = read_track(base + "/track.csv")
    path = read_path(base + "/path.csv")

    xs = [p[0] for p in track]; zs = [p[1] for p in track]
    minx, maxx, minz, maxz = min(xs), max(xs), min(zs), max(zs)
    scale = min((W - 2 * MARGIN) / (maxx - minx), (H - 2 * MARGIN) / (maxz - minz))

    def to_px(x, z):
        return (MARGIN + (x - minx) * scale, H - (MARGIN + (z - minz) * scale))

    img = Image.new("RGB", (W, H), (18, 19, 24))
    d = ImageDraw.Draw(img)

    # road as a thick closed band, then centerline
    road_px = max(2, int(road_width * scale))
    loop = [to_px(x, z) for x, z in track] + [to_px(track[0][0], track[0][1])]
    d.line(loop, fill=(46, 48, 56), width=road_px, joint="curve")
    d.line(loop, fill=(120, 110, 60), width=1)

    # bot path coloured by speed (0..max -> red..green)
    vmax = max((p[2] for p in path), default=1.0) or 1.0
    for i in range(1, len(path)):
        x0, z0, v, off = path[i - 1]
        x1, z1, _, _ = path[i]
        t = min(1.0, v / vmax)
        col = (int(220 * (1 - t)) + 30, int(200 * t) + 30, 40)
        if off:
            col = (255, 60, 220)  # magenta where off-track
        d.line([to_px(x0, z0), to_px(x1, z1)], fill=col, width=4)

    if path:
        sx, sz = path[0][0], path[0][1]
        ex, ez, ev, _ = path[-1]
        d.ellipse(_dot(to_px(sx, sz), 7), fill=(80, 255, 120))   # start
        d.ellipse(_dot(to_px(ex, ez), 9), outline=(255, 80, 80), width=3)  # end
        d.text((20, 20), "start=green  end=red ring  red->green = slow->fast"
               "  magenta = off-track", fill=(220, 220, 220))
        d.text((20, 40), f"end speed={ev * 3.6:.0f} km/h  points={len(path)}", fill=(220, 220, 220))

    img.save(out)
    print("wrote", out)


def _dot(c, r):
    return [c[0] - r, c[1] - r, c[0] + r, c[1] + r]


if __name__ == "__main__":
    main()
