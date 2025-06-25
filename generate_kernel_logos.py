#!/usr/bin/env python3
"""
Generate kernel logo icons for JupyterLab kernels.
Creates logo-32x32.png and logo-64x64.png for each kernel.
"""

import os
import base64
from io import BytesIO
from PIL import Image, ImageDraw, ImageFont

# Define kernel configurations with colors and symbols
KERNEL_CONFIGS = {
    'python2.7': {'bg': '#3776AB', 'fg': 'white', 'text': 'Py', 'sub': '2.7'},
    'python3': {'bg': '#3776AB', 'fg': 'white', 'text': 'Py', 'sub': '3'},
    'python3.13': {'bg': '#3776AB', 'fg': 'white', 'text': 'Py', 'sub': '3.13'},
    'python3.14': {'bg': '#4B8BBE', 'fg': 'white', 'text': 'Py', 'sub': '3.14β'},

    'cpp11': {'bg': '#00599C', 'fg': 'white', 'text': 'C++', 'sub': '11'},
    'cpp14': {'bg': '#00599C', 'fg': 'white', 'text': 'C++', 'sub': '14'},
    'cpp17': {'bg': '#00599C', 'fg': 'white', 'text': 'C++', 'sub': '17'},
    'cpp23': {'bg': '#00599C', 'fg': 'white', 'text': 'C++', 'sub': '23'},
    'cpp26': {'bg': '#004482', 'fg': 'white', 'text': 'C++', 'sub': '26β'},

    'java11': {'bg': '#007396', 'fg': 'white', 'text': 'Java', 'sub': '11'},
    'java17': {'bg': '#007396', 'fg': 'white', 'text': 'Java', 'sub': '17'},
    'java24': {'bg': '#5382A1', 'fg': 'white', 'text': 'Java', 'sub': '24β'},

    'dotnet7-csharp': {'bg': '#512BD4', 'fg': 'white', 'text': 'C#', 'sub': '.NET7'},
    'dotnet8-csharp': {'bg': '#512BD4', 'fg': 'white', 'text': 'C#', 'sub': '.NET8'},
    'dotnet9-csharp': {'bg': '#68217A', 'fg': 'white', 'text': 'C#', 'sub': '.NET9β'},

    'gophernotes': {'bg': '#00ADD8', 'fg': 'white', 'text': 'Go', 'sub': ''},
    'julia-1.11': {'bg': '#9558B2', 'fg': 'white', 'text': 'Jl', 'sub': '1.11'},
    'rust': {'bg': '#CE422B', 'fg': 'white', 'text': 'Rs', 'sub': ''},
    'tslab': {'bg': '#3178C6', 'fg': 'white', 'text': 'TS', 'sub': ''},
    'ir': {'bg': '#276DC3', 'fg': 'white', 'text': 'R', 'sub': ''},
    'kotlin': {'bg': '#7F52FF', 'fg': 'white', 'text': 'Kt', 'sub': ''},
    'scala': {'bg': '#DC322F', 'fg': 'white', 'text': 'Sc', 'sub': ''},
    'bash': {'bg': '#4EAA25', 'fg': 'white', 'text': 'Sh', 'sub': ''},
    'sparql': {'bg': '#0C479C', 'fg': 'white', 'text': 'SQ', 'sub': ''},
}

def create_logo(kernel_name, size):
    """Create a logo image for a kernel."""
    config = KERNEL_CONFIGS.get(kernel_name, {
        'bg': '#666666', 'fg': 'white', 'text': '?', 'sub': ''
    })

    # Create image with background color
    img = Image.new('RGB', (size, size), config['bg'])
    draw = ImageDraw.Draw(img)

    # Try to use a simple font, fallback to default if not available
    try:
        if config['sub']:
            # For kernels with version numbers, use smaller main text
            main_size = int(size * 0.4)
            sub_size = int(size * 0.2)
        else:
            # For kernels without version numbers, use larger text
            main_size = int(size * 0.5)
            sub_size = 0

        # Default font (Pillow's built-in)
        font_main = ImageFont.load_default()
        font_sub = ImageFont.load_default()

        # Try to load a better font if available
        try:
            font_main = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", main_size)
            if sub_size > 0:
                font_sub = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", sub_size)
        except:
            # Use default font with approximate sizing
            pass
    except:
        font_main = ImageFont.load_default()
        font_sub = ImageFont.load_default()

    # Draw main text
    text = config['text']

    # Get text bounding box for centering
    try:
        # For newer Pillow versions
        bbox = draw.textbbox((0, 0), text, font=font_main)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
    except AttributeError:
        # For older Pillow versions
        text_width, text_height = draw.textsize(text, font=font_main)

    if config['sub']:
        # Position main text slightly higher when there's a subtitle
        x = (size - text_width) // 2
        y = (size - text_height) // 2 - size // 8
    else:
        # Center text when there's no subtitle
        x = (size - text_width) // 2
        y = (size - text_height) // 2

    draw.text((x, y), text, fill=config['fg'], font=font_main)

    # Draw subtitle if present
    if config['sub']:
        sub_text = config['sub']
        try:
            bbox = draw.textbbox((0, 0), sub_text, font=font_sub)
            sub_width = bbox[2] - bbox[0]
            sub_height = bbox[3] - bbox[1]
        except AttributeError:
            sub_width, sub_height = draw.textsize(sub_text, font=font_sub)

        sub_x = (size - sub_width) // 2
        sub_y = y + text_height + 2
        draw.text((sub_x, sub_y), sub_text, fill=config['fg'], font=font_sub)

    return img

def save_kernel_logos(output_dir):
    """Generate and save logo files for all kernels."""
    os.makedirs(output_dir, exist_ok=True)

    for kernel_name in KERNEL_CONFIGS:
        kernel_dir = os.path.join(output_dir, kernel_name)
        os.makedirs(kernel_dir, exist_ok=True)

        # Create 32x32 logo
        logo_32 = create_logo(kernel_name, 32)
        logo_32.save(os.path.join(kernel_dir, 'logo-32x32.png'))

        # Create 64x64 logo
        logo_64 = create_logo(kernel_name, 64)
        logo_64.save(os.path.join(kernel_dir, 'logo-64x64.png'))

        print(f"Created logos for {kernel_name}")

def generate_dockerfile_commands():
    """Generate Dockerfile COPY commands for kernel logos."""
    print("\n# Dockerfile commands to copy kernel logos:")
    for kernel_name in KERNEL_CONFIGS:
        print(f"COPY kernel-logos/{kernel_name}/logo-*.png /usr/local/share/jupyter/kernels/{kernel_name}/")

if __name__ == "__main__":
    # Save logos to kernel-logos directory
    save_kernel_logos("kernel-logos")

    # Print Dockerfile commands
    generate_dockerfile_commands()

    print("\nLogo generation complete!")
