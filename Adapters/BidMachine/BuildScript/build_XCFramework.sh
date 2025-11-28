#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="ISBidMachineAdapter"
CONFIGURATION="Release"
ADAPTER_WORKSPACE="${PROJECT_DIR}/${PROJECT_NAME}.xcworkspace"
DERIVED_DATA="${PROJECT_DIR}/DerivedData"

if [ -d "${PROJECT_DIR}/ReleaseCandidates/${PROJECT_NAME}" ]; then
  rm -rf "${PROJECT_DIR}/ReleaseCandidates/${PROJECT_NAME}"
fi

if [ -d "${DERIVED_DATA}" ]; then
  rm -rf "${DERIVED_DATA}"
fi

createFramework() {
xcrun xcodebuild -workspace "${ADAPTER_WORKSPACE}" \
    -scheme "${PROJECT_NAME}" \
    -configuration "${CONFIGURATION}" \
    -sdk "$1" \
    -derivedDataPath "${DERIVED_DATA}" \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    ARCHS="$2"
}

createFramework "iphoneos" "arm64"
createFramework "iphonesimulator" "x86_64 arm64"

xcodebuild -create-xcframework \
-framework "${DERIVED_DATA}/Build/Products/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" \
-framework "${DERIVED_DATA}/Build/Products/${CONFIGURATION}-iphonesimulator/${PROJECT_NAME}.framework" \
-output "${PROJECT_DIR}/ReleaseCandidates/${PROJECT_NAME}/${PROJECT_NAME}.xcframework"
