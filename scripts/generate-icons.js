const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const workspaceRoot = path.resolve(__dirname, '..');
const iosAppIconDir = path.join(
  workspaceRoot,
  'mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset'
);
const androidResDir = path.join(
  workspaceRoot,
  'mobile/android/app/src/main/res'
);

// HTML Template with exact SVG specification from Cupid Logo.dc.html
const createIconHtml = (size) => `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body {
    width: ${size}px;
    height: ${size}px;
    background: #FFF6FB;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
  }
  svg {
    width: ${Math.round(size * 0.72)}px;
    height: ${Math.round(size * 0.72)}px;
  }
</style>
</head>
<body>
<svg viewBox="0 0 100 100">
  <defs>
    <mask id="mCut">
      <rect width="100" height="100" fill="#fff" />
      <path d="M9 40 C4 24, 15 10.5, 29 10.5 C39 10.5, 46 16.5, 50 24.5 C54 16.5, 61 10.5, 71 10.5 C85 10.5, 96 24, 91 40 C87 53, 62 69, 52.5 77.5 C51 78.8, 49 78.8, 47.5 77.5 C38 69, 13 53, 9 40 Z" fill="#000" transform="translate(19,22) scale(0.62) rotate(-8 50 45)" />
    </mask>
  </defs>
  <circle cx="50" cy="53" r="40" fill="#FF7FB6" mask="url(#mCut)" />
  <circle cx="89" cy="13" r="7.5" fill="#B78CF5" />
</svg>
</body>
</html>`;

const tmpHtml = path.join('/tmp', 'cupid_icon_master.html');
const tmpMasterPng = path.join('/tmp', 'cupid_icon_1024.png');

fs.writeFileSync(tmpHtml, createIconHtml(1024));

const chromeBin = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
execSync(
  `"${chromeBin}" --headless --disable-gpu --screenshot="${tmpMasterPng}" --window-size=1024,1024 "${tmpHtml}"`
);

console.log('Master icon 1024x1024 rendered successfully.');

const iosTargets = [
  { file: 'Icon-App-20x20@1x.png', size: 20 },
  { file: 'Icon-App-20x20@2x.png', size: 40 },
  { file: 'Icon-App-20x20@3x.png', size: 60 },
  { file: 'Icon-App-29x29@1x.png', size: 29 },
  { file: 'Icon-App-29x29@2x.png', size: 58 },
  { file: 'Icon-App-29x29@3x.png', size: 87 },
  { file: 'Icon-App-40x40@1x.png', size: 40 },
  { file: 'Icon-App-40x40@2x.png', size: 80 },
  { file: 'Icon-App-40x40@3x.png', size: 120 },
  { file: 'Icon-App-60x60@2x.png', size: 120 },
  { file: 'Icon-App-60x60@3x.png', size: 180 },
  { file: 'Icon-App-76x76@1x.png', size: 76 },
  { file: 'Icon-App-76x76@2x.png', size: 152 },
  { file: 'Icon-App-83.5x83.5@2x.png', size: 167 },
  { file: 'Icon-App-1024x1024@1x.png', size: 1024 },
];

const androidTargets = [
  { file: 'mipmap-mdpi/ic_launcher.png', size: 48 },
  { file: 'mipmap-hdpi/ic_launcher.png', size: 72 },
  { file: 'mipmap-xhdpi/ic_launcher.png', size: 96 },
  { file: 'mipmap-xxhdpi/ic_launcher.png', size: 144 },
  { file: 'mipmap-xxxhdpi/ic_launcher.png', size: 192 },
];

// Use Python Pillow to resize with high quality Lanczos filter
const resizeScript = `
from PIL import Image
import sys

master_path = "${tmpMasterPng}"
master = Image.open(master_path).convert("RGBA")

# Process iOS targets
ios_dir = "${iosAppIconDir}"
ios_list = ${JSON.stringify(iosTargets)}
for target in ios_list:
    dest = f"{ios_dir}/{target['file']}"
    sz = int(target['size'])
    resized = master.resize((sz, sz), Image.Resampling.LANCZOS)
    resized.save(dest, "PNG")
    print(f"Generated iOS icon: {dest} ({sz}x{sz})")

# Process Android targets
android_dir = "${androidResDir}"
android_list = ${JSON.stringify(androidTargets)}
for target in android_list:
    dest = f"{android_dir}/{target['file']}"
    sz = int(target['size'])
    resized = master.resize((sz, sz), Image.Resampling.LANCZOS)
    resized.save(dest, "PNG")
    print(f"Generated Android icon: {dest} ({sz}x{sz})")
`;

const tmpPy = path.join('/tmp', 'resize_icons.py');
fs.writeFileSync(tmpPy, resizeScript);
execSync(`python3 "${tmpPy}"`, { stdio: 'inherit' });

console.log('All launcher icons generated and updated successfully!');
