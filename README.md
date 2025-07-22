# SWF to Spritesheet

**Experimental AS3 tool for converting Flash MovieClips to spritesheets with JSON metadata — ready for use in Unity3D.**

This tool helps you export legacy Flash `MovieClip` assets (like avatar parts) into a single PNG atlas and a matching JSON file containing pivot and layout data. It's particularly useful when migrating 2D assets into modern engines like Unity3D, where Flash is no longer supported.

---

## 🚀 Features

- 🧩 **Converts MovieClips** into packed spritesheets
- 🖼️ **Outputs transparent PNG** with all parts laid out
- 🧭 **Includes JSON metadata** with positions, sizes, and pivot offsets
- 📐 **Optimized for Unity** — easy integration with custom sprite loaders
- 🔧 **Anchor point calculation** for consistent pivoting

---

## 📦 Output Files

After running the tool, two files will be saved to the target directory:

- `Human.png` – the generated spritesheet (texture atlas)
- `Human.json` – metadata for each part:
```json
{
  "meta": {
    "w": 1024,
    "h": 512
  },
  "parts": [
    {
      "linkage": "Head",
      "x": 50,
      "y": 0,
      "w": 128,
      "h": 128,
      "x_pivot": 64,
      "y_pivot": 64
    },
    ...
  ]
}
