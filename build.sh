#!/bin/bash
set -e

echo "🚀 Starting Flutter Web Build for Vercel..."

# Install Flutter if not present
if [ ! -d "$HOME/flutter" ]; then
  echo "📦 Installing Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
  echo "✅ Flutter SDK installed"
else
  echo "✅ Flutter SDK already exists"
fi

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Verify Flutter installation
echo "🔍 Checking Flutter installation..."
flutter --version

# Configure Flutter for web
echo "⚙️  Configuring Flutter for web..."
flutter config --enable-web

# Get dependencies
echo "📥 Installing dependencies..."
flutter pub get

# Build for production
echo "🏗️  Building Flutter web app..."
flutter build web --release --web-renderer canvaskit

echo "✅ Build complete! Output in build/web/"
