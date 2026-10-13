#!/usr/bin/env bash
# Prepares Godot's Android export inside the container: creates a debug
# keystore (once) and points Godot's editor settings at the SDK and JDK.
set -euo pipefail

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}}"
JDK="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
KEYSTORE=/root/.android/debug.keystore

[ -d "$SDK" ] || { echo "Android SDK not found at $SDK (set ANDROID_HOME)" >&2; exit 1; }

mkdir -p /root/.android /root/.config/godot
if [ ! -f "$KEYSTORE" ]; then
  keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android \
    -keystore "$KEYSTORE" -storepass android \
    -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
fi

cat > /root/.config/godot/editor_settings-4.tres <<SETTINGS
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "$SDK"
export/android/java_sdk_path = "$JDK"
export/android/debug_keystore = "$KEYSTORE"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
SETTINGS
