#!/bin/bash
set -e

BUILD_DIR="$(pwd)/build"
PLATFORMS="windows macos ios android web"

build_windows() {
    echo "Building Windows version..."
    dotnet publish src/windows -c Release -o "$BUILD_DIR/windows"
    echo "Windows build completed."
}

build_macos() {
    echo "Building macOS version..."
    xcodebuild -project src/macos/Excel.xcodeproj -scheme Excel -configuration Release -derivedDataPath "$BUILD_DIR/macos"
    echo "macOS build completed."
}

build_ios() {
    echo "Building iOS version..."
    xcodebuild -project src/ios/Excel.xcodeproj -scheme Excel -configuration Release -sdk iphoneos -derivedDataPath "$BUILD_DIR/ios"
    echo "iOS build completed."
}

build_android() {
    echo "Building Android version..."
    ./gradlew -p src/android assembleRelease
    mkdir -p "$BUILD_DIR/android"
    cp src/android/app/build/outputs/apk/release/app-release.apk "$BUILD_DIR/android/Excel.apk"
    echo "Android build completed."
}

build_web() {
    echo "Building web version..."
    cd src/web
    npm install
    npm run build
    mkdir -p "$BUILD_DIR/web"
    cp -r build/* "$BUILD_DIR/web/"
    cd ../..
    echo "Web build completed."
}

build_all() {
    for platform in $PLATFORMS; do
        build_$platform
    done
}

# Create build directory
mkdir -p "$BUILD_DIR"

# Build all platforms
build_all

echo "All builds completed successfully."