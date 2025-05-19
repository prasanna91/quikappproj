#!/bin/bash
set -e

echo "🔔 Firebase Push Notification Setup for iOS"

if [ "$PUSH_NOTIFY" = "true" ]; then
  echo "✅ PUSH_NOTIFY is true. Proceeding..."

  # 1. Download and apply Firebase config
  mkdir -p firebase/ios
  if [ -n "$firebase_config_ios" ]; then
    echo "📥 Downloading GoogleService-Info.plist..."
    wget -O firebase/ios/GoogleService-Info.plist "$firebase_config_ios"
  fi

  if [ -f "firebase/ios/GoogleService-Info.plist" ]; then
    cp firebase/ios/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist
    echo "✅ GoogleService-Info.plist copied."
  else
    echo "❌ Missing GoogleService-Info.plist. Cannot proceed with Firebase setup."
    exit 1
  fi

  # 2. Add Firebase SDK via Package.resolved (if pre-committed)
  if [ -f "firebase/ios/Package.resolved" ]; then
    mkdir -p ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/
    cp firebase/ios/Package.resolved ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
    echo "📦 Firebase SDK resolved from committed Package.resolved."
  else
    echo "⚠️ Package.resolved not found. Firebase SDK must be added manually in Xcode."
  fi

  # 3. Download APNs Auth Key (Optional)
  if [ -n "$APNS_AUTH_KEY_URL" ]; then
    wget -O firebase/ios/AuthKey.p8 "$APNS_AUTH_KEY_URL"
    echo "📥 Downloaded AuthKey.p8 for APNs."
  fi

  # 4. APNs Entitlements Setup
  BUILD_MODE=${BUILD_MODE:-debug}  # fallback to debug if not set
  if [ "$BUILD_MODE" = "release" ]; then
    APS_ENV="production"
  else
    APS_ENV="development"
  fi

  if [ ! -f "ios/Runner/Runner.entitlements" ]; then
    echo "📝 Creating Runner.entitlements with aps-environment = $APS_ENV"
    cat <<EOF > ios/Runner/Runner.entitlements
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>aps-environment</key>
  <string>$APS_ENV</string>
</dict>
</plist>
EOF
  else
    if grep -q "aps-environment" ios/Runner/Runner.entitlements; then
      echo "✅ APNs entitlements already enabled."
    else
      echo "⚠️ Warning: aps-environment key missing in existing Runner.entitlements."
    fi
  fi

else
  echo "🚫 PUSH_NOTIFY is false. Skipping Firebase iOS setup."
  rm -f ios/Runner/GoogleService-Info.plist
  rm -f ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
  echo "🧹 Cleaned up Firebase iOS configuration files."
fi
