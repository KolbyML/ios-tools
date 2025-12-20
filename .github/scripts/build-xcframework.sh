#!/usr/bin/env bash
set -euxo pipefail

# 1. Define Static Targets
DEVICE_TARGET=./device-static
SIMULATOR_TARGET=./sim-static

DEVICE_LIB_DIR=$(find ./device -name "libjava.a" | head -n 1 | xargs dirname)
SIM_LIB_DIR=$(find ./simulator -name "libjava.a" | head -n 1 | xargs dirname)

# Find jni.h to locate the include folder
DEVICE_INCLUDE_DIR=$(find ./device -name "jni.h" | head -n 1 | xargs dirname)
SIM_INCLUDE_DIR=$(find ./simulator -name "jni.h" | head -n 1 | xargs dirname)

# Check if we found them
if [ -z "$DEVICE_INCLUDE_DIR" ]; then
  echo "ERROR: Could not find jni.h in ./device artifact!"
  exit 1
fi

echo "--- Paths ---"
echo "Dev Libs: $DEVICE_LIB_DIR"
echo "Sim Libs: $SIM_LIB_DIR"
echo "Dev Inc:  $DEVICE_INCLUDE_DIR"

# 3. Create device static
mkdir -p $DEVICE_TARGET
cp ./libffi-ios/libffi.a $DEVICE_TARGET
cp "$DEVICE_LIB_DIR"/*.a $DEVICE_TARGET
cp "$DEVICE_LIB_DIR"/zero/libjvm.a $DEVICE_TARGET

cd $DEVICE_TARGET
libtool -static -o libdevice.a \
    libjvm.a libffi.a \
    libjava.a libzip.a libnet.a libnio.a libjimage.a \
    libjava.sql.a \
    libjava.desktop.a \
    libjava.management.a \
    libjdk.unsupported.a \
    libjava.prefs.a \
    libjava.logging.a \
    libjava.xml.a \
    libjdk.crypto.ec.a \
    libjava.naming.a \
    libjava.datatransfer.a \
    libjava.instrument.a \
    libjava.scripting.a \
    libjava.security.jgss.a \
    libjava.security.sasl.a \
    libjdk.management.a \
    libjdk.net.a
cd ..

# 4. Create sim static
mkdir -p $SIMULATOR_TARGET
cp ./libffi-ios-sim/libffi.a $SIMULATOR_TARGET
cp "$SIM_LIB_DIR"/*.a $SIMULATOR_TARGET
cp "$SIM_LIB_DIR"/zero/libjvm.a $SIMULATOR_TARGET

cd $SIMULATOR_TARGET
libtool -static -o libsim.a \
    libjvm.a libffi.a \
    libjava.a libzip.a libnet.a libnio.a libjimage.a \
    libjava.sql.a \
    libjava.desktop.a \
    libjava.management.a \
    libjdk.unsupported.a \
    libjava.prefs.a \
    libjava.logging.a \
    libjava.xml.a \
    libjdk.crypto.ec.a \
    libjava.naming.a \
    libjava.datatransfer.a \
    libjava.instrument.a \
    libjava.scripting.a \
    libjava.security.jgss.a \
    libjava.security.sasl.a \
    libjdk.management.a \
    libjdk.net.a
cd ..

# 5. Create XCFramework
xcodebuild -create-xcframework \
  -library $DEVICE_TARGET/libdevice.a \
  -headers "$DEVICE_INCLUDE_DIR" \
  -library $SIMULATOR_TARGET/libsim.a \
  -headers "$SIM_INCLUDE_DIR" \
  -output ./OpenJDK.xcframework