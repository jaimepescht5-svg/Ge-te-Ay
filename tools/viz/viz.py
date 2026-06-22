#!/usr/bin/env python3
"""viz — a tiny visual-check harness for Godot work.

The loop it automates: run a scene headlessly (Xvfb + software GL, no GPU
needed) and capture frames, stitch them into ONE contact sheet the AI can read
at a glance, and into an MP4/GIF clip a human can confirm on a phone.

Subcommands:
  run      run a Godot project (rendered under Xvfb, or --headless) with env vars
  contact  build a labelled grid of frames (for a quick AI glance)
  clip     build an MP4 (+ GIF) from frames (for human confirmation)
  check    run + contact + clip in one go, print every artifact path

Frames are any files matching frame_*.png in a directory. Projects can produce
them via tools/viz/capture.gd (a drop-in autoload), or with their own capture
(NEON DELTA writes to $VIZ_OUT when set).

Deps: Pillow (contact), imageio + imageio-ffmpeg (clip). See requirements.txt.
"""
import argparse
import glob
import os
import subprocess
import sys


def find_frames(frames_dir, min_bytes=3000):
    files = sorted(glob.glob(os.path.join(frames_dir, "frame_*.png")))
    return [f for f in files if os.path.getsize(f) >= min_bytes]


def _sample(items, n):
    if len(items) <= n:
        return list(items)
    step = len(items) / n
    return [items[int(i * step)] for i in range(n)]


# ---------------------------------------------------------------- run
def cmd_run(args):
    engine = args.engine or os.environ.get("VIZ_GODOT")
    if not engine or not os.path.exists(engine):
        sys.exit("error: --engine <godot binary> not found (or set VIZ_GODOT)")
    env = dict(os.environ)
    for kv in args.env or []:
        k, _, v = kv.partition("=")
        env[k] = v
    if args.frames_out:
        env["VIZ_OUT"] = os.path.abspath(args.frames_out)
        os.makedirs(env["VIZ_OUT"], exist_ok=True)
        if not args.headless:
            env.setdefault("VIZ_CAPTURE", "1")
    if args.headless:
        cmd = [engine, "--headless", "--path", args.project]
    else:
        env["LIBGL_ALWAYS_SOFTWARE"] = "1"
        cmd = ["xvfb-run", "-a", engine, "--path", args.project,
               "--rendering-driver", "opengl3", "--resolution", args.res]
    print("running:", " ".join(cmd))
    try:
        subprocess.run(cmd, env=env, timeout=args.timeout)
    except subprocess.TimeoutExpired:
        print(f"(stopped after {args.timeout}s timeout)")
    return env.get("VIZ_OUT")


# ---------------------------------------------------------------- contact sheet
def cmd_contact(args):
    from PIL import Image, ImageDraw
    files = _sample(find_frames(args.frames), args.max)
    if not files:
        sys.exit(f"no frames in {args.frames}")
    cols = args.cols
    rows = (len(files) + cols - 1) // cols
    thumb_w = args.width // cols
    sample = Image.open(files[0])
    thumb_h = int(sample.height * thumb_w / sample.width)
    sheet = Image.new("RGB", (thumb_w * cols, thumb_h * rows), (12, 12, 16))
    draw = ImageDraw.Draw(sheet)
    for i, f in enumerate(files):
        im = Image.open(f).convert("RGB").resize((thumb_w, thumb_h))
        x, y = (i % cols) * thumb_w, (i // cols) * thumb_h
        sheet.paste(im, (x, y))
        draw.text((x + 4, y + 2), os.path.basename(f).replace("frame_", "").replace(".png", ""),
                  fill=(255, 240, 120))
    out = args.out or os.path.join(args.frames, "contact.png")
    sheet.save(out)
    print("contact sheet:", out, f"({len(files)} of {len(find_frames(args.frames))} frames)")
    return out


# ---------------------------------------------------------------- clip
def cmd_clip(args):
    import imageio.v2 as imageio
    from PIL import Image
    files = find_frames(args.frames)
    if not files:
        sys.exit(f"no frames in {args.frames}")
    frames = []
    for f in files:
        im = Image.open(f).convert("RGB")
        h = int(im.height * args.width / im.width)
        frames.append(im.resize((args.width, h)))
    base = args.out or os.path.join(args.frames, "clip")
    mp4 = base + ".mp4"
    imageio.mimwrite(mp4, [f for f in frames], fps=args.fps, quality=7, macro_block_size=8)
    print("mp4:", mp4, _kb(mp4))
    if args.gif:
        gif = base + ".gif"
        frames[0].save(gif, save_all=True, append_images=frames[1:],
                       duration=int(1000 / args.fps), loop=0, optimize=True)
        print("gif:", gif, _kb(gif))
    return mp4


def _kb(p):
    return f"({round(os.path.getsize(p) / 1024)} KB)"


# ---------------------------------------------------------------- check (all)
def cmd_check(args):
    out = cmd_run(args)
    frames = args.frames or out
    if not frames:
        sys.exit("no --frames dir and project did not report VIZ_OUT")
    args.frames = frames
    print("\n--- contact ---")
    cmd_contact(args)
    print("\n--- clip ---")
    cmd_clip(args)


def main():
    p = argparse.ArgumentParser(description="visual-check harness for Godot")
    sub = p.add_subparsers(dest="cmd", required=True)

    def add_run_opts(sp):
        sp.add_argument("--engine", help="path to Godot binary (or $VIZ_GODOT)")
        sp.add_argument("--project", required=True, help="Godot project dir")
        sp.add_argument("--env", action="append", help="VAR=value (repeatable)")
        sp.add_argument("--res", default="800x450")
        sp.add_argument("--headless", action="store_true", help="no rendering (logic only)")
        sp.add_argument("--timeout", type=int, default=200)
        sp.add_argument("--frames-out", help="redirect $VIZ_OUT here")

    def add_view_opts(sp):
        sp.add_argument("--out")
        sp.add_argument("--width", type=int, default=900)
        sp.add_argument("--cols", type=int, default=4)
        sp.add_argument("--max", type=int, default=12)
        sp.add_argument("--fps", type=int, default=24)
        sp.add_argument("--gif", action="store_true")

    sp = sub.add_parser("run"); add_run_opts(sp)
    sp = sub.add_parser("contact"); sp.add_argument("frames"); add_view_opts(sp)
    sp = sub.add_parser("clip"); sp.add_argument("frames"); add_view_opts(sp)
    sp = sub.add_parser("check"); add_run_opts(sp); add_view_opts(sp)
    sp.add_argument("--frames", help="frames dir (defaults to project's $VIZ_OUT)")

    args = p.parse_args()
    {"run": cmd_run, "contact": cmd_contact, "clip": cmd_clip, "check": cmd_check}[args.cmd](args)


if __name__ == "__main__":
    main()
