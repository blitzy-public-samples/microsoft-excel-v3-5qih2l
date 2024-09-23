# Microsoft Excel

![Build Status](https://github.com/microsoft/excel/workflows/Excel%20CI/badge.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

Microsoft Excel is a comprehensive spreadsheet application designed to provide powerful data management, analysis, and visualization capabilities across multiple platforms. This project implements Excel for Windows, macOS, iOS, Android, and web browsers.

## Features

- Cross-platform compatibility (Windows, macOS, iOS, Android, Web)
- Powerful calculation engine with 400+ built-in functions
- Advanced charting and data visualization tools
- Real-time collaboration and sharing capabilities
- Extensibility through add-ins and APIs
- Cloud integration for storage and synchronization

## Getting Started

### Prerequisites

- Node.js 14+
- .NET 6.0 SDK
- Xcode 12+ (for macOS and iOS)
- Android Studio 4.0+ (for Android)
- Docker (optional, for containerized deployment)

### Installation

1. Clone the repository: `git clone https://github.com/microsoft/excel.git`
2. Navigate to the project directory: `cd excel`
3. Install dependencies: `npm install`

### Running the Application

- Web version: `npm run start:web`
- Windows desktop: `dotnet run --project src/windows`
- macOS desktop: Open `src/macos/Excel.xcodeproj` in Xcode and run
- iOS: Open `src/ios/Excel.xcodeproj` in Xcode and run
- Android: Open `src/android` in Android Studio and run

## Development

- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint`

## Deployment

### Web
Instructions for deploying the web version

### Desktop
Instructions for packaging and distributing desktop versions

### Mobile
Instructions for submitting to app stores

## Architecture

Brief overview of the system architecture and key components

## Contributing

Guidelines for contributing to the project

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Contact information for the project maintainers