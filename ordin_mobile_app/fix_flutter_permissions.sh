#!/bin/bash

echo "🔧 Fixing Flutter Gradle permissions issue..."

# Remove the corrupted cache
sudo rm -rf /usr/lib/flutter/packages/flutter_tools/gradle/.gradle

# Create the directory with proper permissions
sudo mkdir -p /usr/lib/flutter/packages/flutter_tools/gradle/.gradle
sudo chmod -R 777 /usr/lib/flutter/packages/flutter_tools/gradle/.gradle
sudo chown -R $USER:$USER /usr/lib/flutter/packages/flutter_tools/gradle/.gradle

echo "✅ Permissions fixed!"
echo "Now run: flutter run -d RZCX40NTHJD"
