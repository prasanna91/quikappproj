#!/bin/bash

# Configuration - Using environment variables
CERT_URL="${CERT_URL:-https://raw.githubusercontent.com/prasanna91/QuikApp/main/Pixaware_Certificates.p12}"
PROFILE_URL="${PROFILE_URL:-https://raw.githubusercontent.com/prasanna91/QuikApp/main/Garbcode.mobileprovision}"
CERT_PASSWORD="${CERT_PASSWORD:-opeN@1234}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-9H2AD7NQ49}"
BUNDLE_ID="${BUNDLE_ID:-com.garbcode.garbcodeapp}"
VERSION_NAME="${VERSION_NAME:-1.0.3}"
VERSION_CODE="${VERSION_CODE:-7}"

echo "🔐 Setting up iOS code signing..."

# Create certificates directory if it doesn't exist
mkdir -p certificates

# Download certificate
echo "⬇️ Downloading certificate from $CERT_URL..."
if ! curl -L -o certificates/certificate.p12 "$CERT_URL"; then
    echo "❌ Failed to download certificate"
    exit 1
fi

# Download provisioning profile
echo "⬇️ Downloading provisioning profile from $PROFILE_URL..."
if ! curl -L -o certificates/profile.mobileprovision "$PROFILE_URL"; then
    echo "❌ Failed to download provisioning profile"
    exit 1
fi

# Verify files exist
if [ ! -f "certificates/certificate.p12" ]; then
    echo "❌ Certificate file not found after download"
    exit 1
fi

if [ ! -f "certificates/profile.mobileprovision" ]; then
    echo "❌ Provisioning profile not found after download"
    exit 1
fi

# Clean up any existing keychain
security delete-keychain ios-build.keychain 2>/dev/null || true

# Create and configure keychain
KEYCHAIN_NAME="ios-build.keychain"
KEYCHAIN_PASSWORD="temporary"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security default-keychain -s "$KEYCHAIN_NAME"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security set-keychain-settings -t 3600 -u "$KEYCHAIN_NAME"

# Import certificate
echo "📥 Importing certificate..."
if ! security import "certificates/certificate.p12" -k "$KEYCHAIN_NAME" -P "$CERT_PASSWORD" -T /usr/bin/codesign; then
    echo "❌ Failed to import certificate"
    exit 1
fi

security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"

# Set up provisioning profile
echo "📱 Setting up provisioning profile..."
mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"

# Get profile UUID
PROFILE_UUID=$(/usr/libexec/PlistBuddy -c "Print :UUID" /dev/stdin <<< $(security cms -D -i "certificates/profile.mobileprovision"))
if [ -z "$PROFILE_UUID" ]; then
    echo "❌ Failed to extract UUID from provisioning profile"
    exit 1
fi

echo "✅ Profile UUID: $PROFILE_UUID"

# Copy profile to correct location
cp "certificates/profile.mobileprovision" "$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"

# Generate ExportOptions.plist dynamically
cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>teamID</key>
    <string>$APPLE_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>$(/usr/libexec/PlistBuddy -c "Print :Name" /dev/stdin <<< $(security cms -D -i "certificates/profile.mobileprovision"))</string>
    </dict>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>iCloudContainerEnvironment</key>
    <string>Production</string>
</dict>
</plist>
EOF

# Clean up old builds
rm -rf build/ios/ipa/* 2>/dev/null || true

# Install pods if needed
if [ ! -d "Pods" ]; then
    echo "📦 Installing pods..."
    pod install
fi

# Build IPA
echo "🏗️ Building IPA..."
flutter build ipa \
    --release \
    --export-options-plist=ExportOptions.plist \
    --no-tree-shake-icons

# Clean up
echo "🧹 Cleaning up..."
security delete-keychain "$KEYCHAIN_NAME"
rm -rf certificates

echo "✅ Build complete! Check build/ios/ipa/ for your IPA file." 