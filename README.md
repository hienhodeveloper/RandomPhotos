# RandomPhotos

A modern iOS app that displays random photos in a paginated grid layout with efficient image downloading and caching capabilities.

<img width="1080" height="2340" alt="simulator_screenshot_E06DD8BC-BD57-498F-85BD-60F480F06EBF" src="https://github.com/user-attachments/assets/531107ec-abd9-4b3b-a6c5-d0fb0a0bcd5a" />

DEMO:
https://github.com/user-attachments/assets/5b6d0d9e-e265-44d0-a523-14f9ff8b8b86


## Features

- **Grid Layout**: Displays photos in a 7x10 grid with pagination support
- **Random Photos**: Fetches random images from Picsum Photos API
- **Concurrent Downloads**: Downloads up to 30 images simultaneously for optimal performance
- **Retry Mechanism**: Failed downloads can be retried with a simple tap
- **Smooth Scrolling**: Horizontal pagination with smooth transitions
- **Memory Efficient**: Proper image loading and memory management

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

### Core Components

- **RandomPhotosViewController**: Main view controller handling UI interactions
- **RandomPhotosPresenter**: Business logic layer managing photo operations
- **PhotoCell**: Custom collection view cell for displaying individual photos
- **PaginationLayout**: Custom collection view layout for grid pagination
- **DownloadPhotoOperations**: Manages concurrent image downloads using OperationQueue

### Key Classes

- `PhotoRecord`: Model representing a photo with its state (new, downloading, success, failed, blank)
- `ImageDownloader`: Custom Operation subclass for downloading images asynchronously
- `DownloadPhotoOperations`: Manages the download queue and concurrent operations

## Technical Details

### Dependencies

- **SnapKit** (~> 5.7.0): Auto Layout DSL for programmatic UI constraints

### Image Source

- Uses [Picsum Photos](https://picsum.photos/) API for random images
- Default image size: 200x200 pixels
- Images are loaded with cache-busting to ensure freshness

## Usage

### Navigation

- **Add Photo**: Tap the "+" button to add a single random photo
- **Reload All**: Tap "Reload All" to refresh with 140 new random photos
- **Retry Failed**: Tap the retry button on failed downloads

## Requirements

- iOS 9.0+
- Xcode 12.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `RandomPhotos.xcworkspace` in Xcode
3. Install CocoaPods dependencies:
   ```bash
   pod install
   ```
4. Build and run the project

## Project Structure

```
RandomPhotos/
├── App/
│   ├── AppDelegate.swift
│   └── Resources/
├── Core/
│   └── Operations/
│       └── DownloadPhotoOperations.swift
├── Modules/
│   └── RandomPhotos/
│       ├── Presenter/
│       │   └── RandomPhotosPresenter.swift
│       └── View/
│           ├── RandomPhotosViewController.swift
│           ├── PhotoCell.swift
│           └── PaginationLayout.swift
└── Info.plist
```

## Author

Created by Ho Hien - October 2025

## License

This project is available for educational and personal use.
