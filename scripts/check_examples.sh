#!/bin/bash
set -euo pipefail
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
examples="$repo_root/skills/apple-accessibility/references/examples"
ios_sdk="$(xcrun --sdk iphoneos --show-sdk-path)"
sim_sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
sim_developer="$(xcrun --sdk iphonesimulator --show-sdk-platform-path)/Developer"
mac_sdk="$(xcrun --sdk macosx --show-sdk-path)"

app_examples=()
for file in "$examples"/*.swift; do
  [[ "$(basename "$file")" == "AccessibilityUITests.swift" ]] || app_examples+=("$file")
done

# App examples: iOS 17 deployment target with availability gates for newer APIs.
xcrun swiftc -typecheck -swift-version 6 -sdk "$ios_sdk" -target arm64-apple-ios17.0 "${app_examples[@]}"

# Same sources as a Mac Catalyst 17 app.
xcrun swiftc -typecheck -swift-version 6 -sdk "$mac_sdk" \
  -F "$mac_sdk/System/iOSSupport/System/Library/Frameworks" \
  -I "$mac_sdk/System/iOSSupport/usr/include" \
  -target arm64-apple-ios17.0-macabi "${app_examples[@]}"

# AppKit and cross-platform chart examples as a macOS 14 app.
xcrun swiftc -typecheck -swift-version 6 -sdk "$mac_sdk" -target arm64-apple-macos14.0 \
  "$examples/AppKitAccessibility.swift" "$examples/AudioGraph.swift"

# UI-test example against XCTest for an iOS 17 simulator test target.
xcrun swiftc -typecheck -swift-version 6 -sdk "$sim_sdk" \
  -F "$sim_developer/Library/Frameworks" -I "$sim_developer/usr/lib" \
  -target arm64-apple-ios17.0-simulator "$examples/AccessibilityUITests.swift"

echo "Swift 6 examples passed for iOS 17, Mac Catalyst 17, macOS 14, and an iOS 17 UI-test target using the selected SDKs."
