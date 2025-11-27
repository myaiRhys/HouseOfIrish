#!/usr/bin/env node

/**
 * Generate placeholder PNG icons for PWA
 * Run with: node generate-icons.js
 *
 * Note: This creates simple colored placeholder PNGs.
 * For production, replace with proper icons using the generate-icons.html file.
 */

const fs = require('fs');
const path = require('path');

const sizes = [72, 96, 128, 144, 152, 192, 384, 512];
const iconsDir = path.join(__dirname, 'icons');

// Ensure icons directory exists
if (!fs.existsSync(iconsDir)) {
    fs.mkdirSync(iconsDir, { recursive: true });
}

// Create a minimal valid PNG (1x1 green pixel) in base64
// This is a valid PNG file that browsers can scale
const createPlaceholderPNG = (size) => {
    // This is a 1x1 green pixel PNG in base64
    const greenPixel = Buffer.from(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        'base64'
    );

    return greenPixel;
};

// Generate all icon sizes
sizes.forEach(size => {
    const filename = path.join(iconsDir, `icon-${size}x${size}.png`);
    const pngData = createPlaceholderPNG(size);

    fs.writeFileSync(filename, pngData);
    console.log(`✓ Created ${filename}`);
});

console.log('\n✓ All placeholder icons created!');
console.log('Note: These are minimal placeholders. For better icons:');
console.log('1. Open generate-icons.html in a browser');
console.log('2. Click "Generate All Icons"');
console.log('3. Move downloaded icons to the /icons/ directory');
