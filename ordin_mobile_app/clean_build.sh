#!/bin/bash

echo "🧹 Cleaning Flutter build..."
flutter clean

echo "🧹 Cleaning Android Gradle cache..."
cd android
./gradlew clean --no-daemon
cd ..

echo "🧹 Removing Gradle cache directories..."
rm -rf android/.gradle
rm -rf android/app/.gradle
rm -rf build

echo "🧹 Cleaning Flutter Gradle plugin cache..."
sudo rm -rf /usr/lib/flutter/packages/flutter_tools/gradle/.gradle

echo "✅ Clean complete! Now run: flutter run -d RZCX40NTHJD"
