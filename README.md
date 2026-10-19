# Quality Camera (iOS)

A lightweight, single-shutter iOS camera application built with Swift and AVFoundation, featuring precise Megapixel (MP) resolution selection (8MP, 5MP, 3MP, 1MP, 0.3MP) and native iOS Files app integration.

## Features
- **Single Shutter Capture:** Clean viewfinder preview and direct shutter trigger.
- **Megapixel (MP) Quality Presets:** Downscales captures precisely to standard resolution tiers (8MP, 5MP, 3MP, 1MP, 0.3MP).
- **Files App Export:** Photos are saved to On My iPhone > Quality Camera in the Files app.
- **Live viewfinder, front/back camera switch, camera permission handling.**

## Project Structure
- `Sources/CameraManager.swift`: Manages the AVFoundation capture session and photo output.
- `Sources/ResolutionEngine.swift`: Handles scaling images to target Megapixel tiers.
- `Sources/FileExporter.swift`: Manages writing files to the local document directory.
