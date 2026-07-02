#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting deep clean for iOS dependencies..."

# 1. Flutter clean and pub get
echo "🧹 Cleaning Flutter project..."
flutter clean
flutter pub get

# 2. Navigate to ios directory
cd ios || { echo "❌ iOS directory not found!"; exit 1; }

# 3. Remove old artifacts
echo "🗑 Removing Pods, .symlinks, and Podfile.lock..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf build

# 4. Update CocoaPods and install
echo "📦 Updating CocoaPods repos and installing pods..."

pod cache clean --all
pod repo update
pod install --repo-update

# 5. Return to root
cd ..

echo "✅ Success! You can now run your project on iPhone 17 Pro."