import os
import subprocess
import math
from PIL import Image, ImageDraw, ImageFilter

def create_master_icon():
    size = 1024
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    
    # 1. Background Squircle
    # macOS squircle bounds: inset by ~80px for standard Apple icon grid
    margin = 80
    bg_box = [margin, margin, size - margin, size - margin]
    radius = 190

    # Gradient background: deep night indigo to vibrant deep purple (#1e1b4b -> #4338ca -> #6366f1)
    mask = Image.new("L", (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(bg_box, radius=radius, fill=255)

    bg_grad = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg_grad)
    for y in range(margin, size - margin):
        factor = (y - margin) / float(size - 2 * margin)
        # Deep space dark indigo to vibrant violet
        r = int(24 + factor * 50)
        g = int(20 + factor * 40)
        b = int(55 + factor * 160)
        bg_draw.line([(margin, y), (size - margin, y)], fill=(r, g, b, 255))

    # Inner soft highlight glow
    bg_composed = Image.composite(bg_grad, Image.new("RGBA", (size, size), (0, 0, 0, 0)), mask)

    # 2. Add subtle drop shadow under the main icon
    shadow_mask = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow_mask)
    s_draw.rounded_rectangle([margin, margin + 20, size - margin, size - margin + 25], radius=radius, fill=(0, 0, 0, 110))
    shadow_blurred = shadow_mask.filter(ImageFilter.GaussianBlur(30))

    img.alpha_composite(shadow_blurred)
    img.alpha_composite(bg_composed)

    # 3. Draw Sticky Note (Tilted golden amber note)
    # We create a note layer, rotate it slightly, then paste it
    note_w = 460
    note_h = 480
    note_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    n_draw = ImageDraw.Draw(note_img)

    # Note center position
    cx, cy = 490, 520
    nx1 = cx - note_w // 2
    ny1 = cy - note_h // 2
    nx2 = cx + note_w // 2
    ny2 = cy + note_h // 2

    # Note shadow
    n_draw.rounded_rectangle([nx1 - 4, ny1 + 18, nx2 + 14, ny2 + 24], radius=32, fill=(0, 0, 0, 70))
    note_img = note_img.filter(ImageFilter.GaussianBlur(18))

    # Note body (Warm Golden Pastel #FEF08A to #FBBF24)
    note_body = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    nb_draw = ImageDraw.Draw(note_body)
    nb_draw.rounded_rectangle([nx1, ny1, nx2, ny2], radius=30, fill=(254, 240, 138, 255))
    
    # Note top header strip (slightly deeper amber #FDE047)
    nb_draw.rounded_rectangle([nx1, ny1, nx2, ny1 + 80], radius=30, fill=(253, 224, 71, 255))
    nb_draw.rectangle([nx1, ny1 + 50, nx2, ny1 + 80], fill=(253, 224, 71, 255))

    # Note subtle lines (like a real lined notepad)
    line_color = (217, 119, 6, 80)
    for line_y in range(ny1 + 130, ny2 - 60, 45):
        nb_draw.rounded_rectangle([nx1 + 45, line_y, nx2 - 45, line_y + 6], radius=3, fill=line_color)

    # Checklist checkboxes on the note
    for check_y in [ny1 + 175, ny1 + 265]:
        nb_draw.rounded_rectangle([nx1 + 45, check_y - 2, nx1 + 72, check_y + 25], radius=6, outline=(217, 119, 6, 160), width=3)
        # Checkmark in first box
        if check_y == ny1 + 175:
            nb_draw.line([(nx1 + 50, check_y + 11), (nx1 + 56, check_y + 18), (nx1 + 68, check_y + 6)], fill=(16, 185, 129, 255), width=4)

    # 4. Apple Intelligence Sparkles (Glowing Purple & Cyan AI magic in corner)
    # Sparkle 1 (Large 4-point star at top right of note)
    def draw_star(draw, x, y, r, inner_r, fill_color):
        points = []
        for i in range(8):
            rad = r if i % 2 == 0 else inner_r
            angle = i * math.pi / 4
            points.append((x + rad * math.cos(angle), y + rad * math.sin(angle)))
        draw.polygon(points, fill=fill_color)

    star_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    s_draw2 = ImageDraw.Draw(star_layer)

    # Large AI star at (690, 360)
    draw_star(s_draw2, 700, 360, 52, 14, (255, 255, 255, 255))
    draw_star(s_draw2, 770, 430, 30, 8, (192, 132, 252, 240)) # purple accent
    draw_star(s_draw2, 650, 440, 24, 7, (56, 189, 248, 240))  # cyan accent

    # Glow under stars
    star_glow = star_layer.filter(ImageFilter.GaussianBlur(16))
    
    # 5. Pushpin at Top Left of Note
    pin_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    p_draw = ImageDraw.Draw(pin_layer)
    pin_x, pin_y = nx1 + 40, ny1 + 35

    # Pushpin shadow
    p_draw.ellipse([pin_x - 12, pin_y + 14, pin_x + 36, pin_y + 38], fill=(0, 0, 0, 80))
    pin_layer = pin_layer.filter(ImageFilter.GaussianBlur(6))
    p_draw = ImageDraw.Draw(pin_layer)

    # Pushpin head (vibrant ruby red / coral #EF4444 with 3D highlight)
    p_draw.ellipse([pin_x - 18, pin_y - 18, pin_x + 22, pin_y + 22], fill=(239, 68, 68, 255))
    p_draw.ellipse([pin_x - 12, pin_y - 14, pin_x + 6, pin_y + 4], fill=(252, 165, 165, 230))
    p_draw.ellipse([pin_x - 4, pin_y - 8, pin_x + 12, pin_y + 8], fill=(185, 28, 28, 255))

    # Compose layers
    img.alpha_composite(note_img)
    img.alpha_composite(note_body)
    img.alpha_composite(pin_layer)
    img.alpha_composite(star_glow)
    img.alpha_composite(star_layer)

    # Final glossy rim on squircle border
    rim = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    r_draw = ImageDraw.Draw(rim)
    r_draw.rounded_rectangle(bg_box, radius=radius, outline=(255, 255, 255, 45), width=3)
    img.alpha_composite(rim)

    return img

def generate_icns():
    master = create_master_icon()
    iconset_dir = "AppIcon.iconset"
    os.makedirs(iconset_dir, exist_ok=True)

    sizes = [
        (16, "icon_16x16.png"),
        (32, "icon_16x16@2x.png"),
        (32, "icon_32x32.png"),
        (64, "icon_32x32@2x.png"),
        (128, "icon_128x128.png"),
        (256, "icon_128x128@2x.png"),
        (256, "icon_256x256.png"),
        (512, "icon_256x256@2x.png"),
        (512, "icon_512x512.png"),
        (1024, "icon_512x512@2x.png"),
    ]

    for s, name in sizes:
        resized = master.resize((s, s), Image.Resampling.LANCZOS)
        resized.save(os.path.join(iconset_dir, name))

    os.makedirs("Resources", exist_ok=True)
    os.makedirs("assets", exist_ok=True)
    
    # Save 1024x1024 preview to assets
    master.save("assets/app_icon_1024.png")

    # Run iconutil to create AppIcon.icns
    subprocess.run(["iconutil", "-c", "icns", iconset_dir, "-o", "Resources/AppIcon.icns"], check=True)
    print("✅ Successfully generated Resources/AppIcon.icns and assets/app_icon_1024.png")

    # Clean up iconset
    import shutil
    shutil.rmtree(iconset_dir)

if __name__ == "__main__":
    generate_icns()
