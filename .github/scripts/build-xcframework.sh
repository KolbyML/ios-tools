#!/usr/bin/env bash
set -euxo pipefail

# 1. Define Static Targets
DEVICE_TARGET=./device-static
SIMULATOR_TARGET=./sim-static

# 2. LOCATE INPUTS (Auto-detection)
DEVICE_LIB_DIR=$(find ./device -name "libjava.a" | head -n 1 | xargs dirname)
SIM_LIB_DIR=$(find ./simulator -name "libjava.a" | head -n 1 | xargs dirname)
DEVICE_INCLUDE_DIR=$(find ./device -name "jni.h" | head -n 1 | xargs dirname)
SIM_INCLUDE_DIR=$(find ./simulator -name "jni.h" | head -n 1 | xargs dirname)

echo "--- Paths ---"
echo "Dev Libs: $DEVICE_LIB_DIR"
echo "Sim Libs: $SIM_LIB_DIR"
echo "Dev Inc:  $DEVICE_INCLUDE_DIR"

if [ -z "$DEVICE_INCLUDE_DIR" ]; then
  echo "ERROR: Could not find jni.h. Did you update the upload step to include jdk/include?"
  exit 1
fi

# 3. FLATTEN HEADERS (The Fix for 'jni_md.h not found')
# OpenJDK puts machine-dependent headers in 'darwin' or 'ios' subfolders.
# We must move them up to the root 'include' folder so jni.h can find them.

# For Device
cp -f "$DEVICE_INCLUDE_DIR"/darwin/* "$DEVICE_INCLUDE_DIR"/ 2>/dev/null || :
cp -f "$DEVICE_INCLUDE_DIR"/ios/* "$DEVICE_INCLUDE_DIR"/ 2>/dev/null || :

# For Simulator
cp -f "$SIM_INCLUDE_DIR"/darwin/* "$SIM_INCLUDE_DIR"/ 2>/dev/null || :
cp -f "$SIM_INCLUDE_DIR"/ios/* "$SIM_INCLUDE_DIR"/ 2>/dev/null || :

# 4. CREATE DEVICE STATIC LIB
mkdir -p $DEVICE_TARGET
cp ./libffi-ios/libffi.a $DEVICE_TARGET
cp "$DEVICE_LIB_DIR"/*.a $DEVICE_TARGET
cp "$DEVICE_LIB_DIR"/zero/libjvm.a $DEVICE_TARGET

cd $DEVICE_TARGET
libtool -static -o libdevice.a \
    libjvm.a \
    libffi.a \
    libjava.a \
    libjli.a \
    libzip.a \
    libnet.a \
    libnio.a \
    libjimage.a \
    libmanagement.a \
    libmanagement_ext.a \
    libprefs.a \
    libinstrument.a \
    libextnet.a \
    libverify.a \
    libattach.a \
    libj2gss.a \
    libjaas.a \
    libsyslookup.a
cd ..

# 5. CREATE SIMULATOR STATIC LIB
mkdir -p $SIMULATOR_TARGET
cp ./libffi-ios-sim/libffi.a $SIMULATOR_TARGET
cp "$SIM_LIB_DIR"/*.a $SIMULATOR_TARGET
cp "$SIM_LIB_DIR"/zero/libjvm.a $SIMULATOR_TARGET

cd $SIMULATOR_TARGET
libtool -static -o libsim.a \
    libjvm.a \
    libffi.a \
    libjava.a \
    libjli.a \
    libzip.a \
    libnet.a \
    libnio.a \
    libjimage.a \
    libmanagement.a \
    libmanagement_ext.a \
    libprefs.a \
    libinstrument.a \
    libextnet.a \
    libverify.a \
    libattach.a \
    libj2gss.a \
    libjaas.a \
    libsyslookup.a
cd ..

# 6. CREATE XCFRAMEWORK
xcodebuild -create-xcframework \
  -library $DEVICE_TARGET/libdevice.a \
  -headers "$DEVICE_INCLUDE_DIR" \
  -library $SIMULATOR_TARGET/libsim.a \
  -headers "$SIM_INCLUDE_DIR" \
  -output ./OpenJDK.xcframework
