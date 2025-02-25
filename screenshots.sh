#!/usr/bin/env zsh

# This script automates the process of taking screenshots for the App Store.
# It uses UI tests target, which are configured in the Screenshots test plan.
# The final screenshots are saved in a folder named 'screenshots'.

set -e

if ! command -v xcparse &> /dev/null
then
    echo "xcparse could not be found. Please install it: brew install chargepoint/xcparse/xcparse"
    exit 1
fi

if ! command -v convert &> /dev/null
then
    echo "ImageMagick could not be found. Please install it: brew install imagemagick"
    exit 1
fi

declare -a destinations=("platform=iOS Simulator,name=iPhone 16 Plus" "platform=iOS Simulator,name=iPad Pro 13-inch (M4)")

rm -rf ./screenshots
mkdir ./screenshots

for destination in "${destinations[@]}"
do

rm -rf ./Screenshots.xcresult

echo "Taking screenshots for $destination"
xcodebuild -quiet \
-project "HackerTube.xcodeproj" \
-scheme "HackerTube" \
-destination "$destination" \
-resultBundlePath "./Screenshots.xcresult" \
-testPlan Screenshots \
clean test

xcparse screenshots --os --model --test-plan-config "./Screenshots.xcresult" "./screenshots/"

done

# Remove alpha channel from the screenshots, otherwise the App Store will reject them
find ./screenshots -name "*.png" -exec convert "{}" -alpha off "{}" \;
