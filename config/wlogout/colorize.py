#!/usr/bin/env python3
"""
Coloriza los iconos de wlogout con los colores de la paleta matugen.
Se ejecuta como post_hook de matugen cada vez que cambia el wallpaper.
"""
import sys, os, re
from PIL import Image

WLOGOUT = os.path.expanduser("~/.config/wlogout")
PALETTE = os.path.join(WLOGOUT, "colors.css")

def parse_colors(path):
    colors = {}
    with open(path) as f:
        for line in f:
            m = re.match(r'@define-color\s+(\w+)\s+(#[0-9a-fA-F]{6});', line)
            if m:
                colors[m.group(1)] = m.group(2)
    return colors

def colorize(src, dst, hex_color):
    r, g, b = int(hex_color[1:3], 16), int(hex_color[3:5], 16), int(hex_color[5:7], 16)
    img = Image.open(src).convert("RGBA")
    img.putdata([(r, g, b, a) for (_, _, _, a) in img.getdata()])
    img.save(dst)

colors = parse_colors(PALETTE)

ICON_COLORS = {
    "lock":      colors.get("primary",              "#d3bcfd"),
    "logout":    colors.get("secondary",            "#cdc2db"),
    "shutdown":  colors.get("error",                "#ffb4ab"),
    "reboot":    colors.get("tertiary",             "#f0b7c5"),
    "suspend":   colors.get("secondary",            "#cdc2db"),
    "hibernate": colors.get("tertiary",             "#f0b7c5"),
}
DEFAULT_COLOR = colors.get("on_surface_variant", "#cbc4cf")

os.makedirs(f"{WLOGOUT}/icons_colored", exist_ok=True)
os.makedirs(f"{WLOGOUT}/icons_default", exist_ok=True)

for name, color in ICON_COLORS.items():
    src = f"{WLOGOUT}/icons/{name}.png"
    colorize(src, f"{WLOGOUT}/icons_colored/{name}.png", color)
    colorize(src, f"{WLOGOUT}/icons_default/{name}.png", DEFAULT_COLOR)

print("wlogout: iconos colorizados con paleta matugen")
