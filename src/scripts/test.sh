#!/bin/bash

set -e

TEST_DIR=$(pwd)/tests
PLATFORMS="core windows macos ios android web"
TEST_RESULTS_DIR=$(pwd)/test_results

run_core_tests() {
    echo "Running core tests..."
    cd src/core
    npm run test
    cd ../..
    echo "Core tests completed."
}

run_windows_tests() {
    echo "Running Windows tests..."
    dotnet test src/windows --logger trx --results-directory "$TEST_RESULTS_DIR/windows"
    echo "Windows tests completed."
}

run_macos_tests() {
    echo "Running macOS tests..."
    xcodebuild test -project src/macos/Excel.xcodeproj -scheme Excel -destination 'platform=macOS' -resultBundlePath "$TEST_RESULTS_DIR/macos"
    echo "macOS tests completed."
}

run_ios_tests() {
    echo "Running iOS tests..."
    xcodebuild test -project src/ios/Excel.xcodeproj -scheme Excel -destination 'platform=iOS Simulator,name=iPhone 12' -resultBundlePath "$TEST_RESULTS_DIR/ios"
    echo "iOS tests completed."
}

run_android_tests() {
    echo "Running Android tests..."
    ./gradlew -p src/android test
    mkdir -p "$TEST_RESULTS_DIR/android"
    cp -r src/android/app/build/test-results/* "$TEST_RESULTS_DIR/android/"
    echo "Android tests completed."
}

run_web_tests() {
    echo "Running web tests..."
    cd src/web
    npm run test -- --ci --reporters=default --reporters=jest-junit --outputFile="$TEST_RESULTS_DIR/web/test-results.xml"
    cd ../..
    echo "Web tests completed."
}

run_all_tests() {
    for platform in $PLATFORMS; do
        run_${platform}_tests
    done
}

# Create test results directory
mkdir -p "$TEST_RESULTS_DIR"

# Run all tests
run_all_tests

echo "All tests completed. Results are available in $TEST_RESULTS_DIR"