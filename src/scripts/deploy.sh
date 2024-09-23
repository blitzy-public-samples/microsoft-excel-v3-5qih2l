#!/bin/bash
set -e

DEPLOY_DIR="$(pwd)/deploy"
BUILD_DIR="$(pwd)/build"
PLATFORMS="windows macos ios android web"
VERSION="$(cat version.txt)"

deploy_windows() {
    echo "Deploying Windows version..."
    mkdir -p "$DEPLOY_DIR/windows"
    cp -r "$BUILD_DIR/windows"/* "$DEPLOY_DIR/windows/"
    # TODO: Code signing and notarization for Windows
    echo "Windows deployment completed."
}

deploy_macos() {
    echo "Deploying macOS version..."
    mkdir -p "$DEPLOY_DIR/macos"
    cp -r "$BUILD_DIR/macos/Build/Products/Release/Excel.app" "$DEPLOY_DIR/macos/"
    # TODO: Code signing and notarization for macOS
    echo "macOS deployment completed."
}

deploy_ios() {
    echo "Deploying iOS version..."
    mkdir -p "$DEPLOY_DIR/ios"
    cp "$BUILD_DIR/ios/Build/Products/Release-iphoneos/Excel.ipa" "$DEPLOY_DIR/ios/"
    # TODO: Upload to App Store Connect
    echo "iOS deployment completed."
}

deploy_android() {
    echo "Deploying Android version..."
    mkdir -p "$DEPLOY_DIR/android"
    cp "$BUILD_DIR/android/Excel.apk" "$DEPLOY_DIR/android/"
    # TODO: Upload to Google Play Console
    echo "Android deployment completed."
}

deploy_web() {
    echo "Deploying web version..."
    mkdir -p "$DEPLOY_DIR/web"
    cp -r "$BUILD_DIR/web"/* "$DEPLOY_DIR/web/"
    # TODO: Deploy to web server or cloud hosting service
    echo "Web deployment completed."
}

deploy_all() {
    for platform in $PLATFORMS; do
        deploy_$platform
    done
}

# Create deploy directory
mkdir -p "$DEPLOY_DIR"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found. Please run build script first."
    exit 1
fi

# Deploy all platforms
deploy_all

echo "All deployments completed successfully."
echo "Deployed version: $VERSION"