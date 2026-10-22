from pathlib import Path
from PIL import Image, ImageDraw
import json

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'assets/img/favicons'
VERSION = 'walll-v1'
# A compact W: code-like angles, with the site's mint and lime accents.
POINTS = [(10,19),(19,19),(24,39),(29,25),(35,25),(40,39),(45,19),(54,19),(45,47),(36,47),(32,36),(28,47),(19,47)]
SVG = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="14" fill="#0a0c10"/><path d="M10 19H19L24 39L29 25H35L40 39L45 19H54L45 47H36L32 36L28 47H19Z" fill="#6df4e7"/><path d="M46 10H54V14H46Z" fill="#d9ff57"/></svg>\n'

def icon(size):
    scale = 8
    image = Image.new('RGB', (size*scale, size*scale), '#0a0c10')
    draw = ImageDraw.Draw(image)
    unit = size*scale/64
    draw.polygon([(round(x*unit),round(y*unit)) for x,y in POINTS], fill='#6df4e7')
    draw.rectangle((46*unit,10*unit,54*unit,14*unit), fill='#d9ff57')
    return image.resize((size,size), Image.Resampling.LANCZOS)

DEST.mkdir(parents=True, exist_ok=True)
(DEST / f'{VERSION}.svg').write_text(SVG, encoding='utf-8')
for filename, size in [('favicon-16x16.png',16),('favicon-32x32.png',32),('apple-touch-icon.png',180),('android-chrome-192x192.png',192),('android-chrome-512x512.png',512),('mstile-150x150.png',150)]:
    icon(size).save(DEST / filename)
icon(64).save(DEST / 'favicon.ico', sizes=[(16,16),(32,32),(48,48),(64,64)])
icon(64).save(ROOT / 'favicon.ico', sizes=[(16,16),(32,32),(48,48),(64,64)])
print('Generated W favicon assets (SVG, PNG, ICO).')
