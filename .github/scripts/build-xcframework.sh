#!/usr/bin/env bash
set -euxo pipefail

# Define constants
LIBFFI=./libffi-ios
LIBFFI_SIM=./libffi-ios-sim
OPENJDK_DEVICE_BUILD=./device/mobile/build/ios-aarch64-zero-release
OPENJDK_SIMULATOR_BUILD=./simulator/mobile/build/iossim-aarch64-zero-release
DEVICE_TARGET=./device-static
SIMULATOR_TARGET=./sim-static

# Create device static
mkdir $DEVICE_TARGET
cp $LIBFFI/libffi.a $DEVICE_TARGET
cp $OPENJDK_DEVICE_BUILD/images/static-libs/lib/*.a $DEVICE_TARGET
cp $OPENJDK_DEVICE_BUILD/images/static-libs/lib/zero/libjvm.a $DEVICE_TARGET
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

# Create sim static
mkdir $SIMULATOR_TARGET
cp $LIBFFI_SIM/libffi.a $SIMULATOR_TARGET
cp $OPENJDK_SIMULATOR_BUILD/images/static-libs/lib/*.a $SIMULATOR_TARGET
cp $OPENJDK_SIMULATOR_BUILD/images/static-libs/lib/zero/libjvm.a $SIMULATOR_TARGET
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

# Flatten header location
cp $OPENJDK_DEVICE_BUILD/jdk/include/ios/* $OPENJDK_DEVICE_BUILD/jdk/include/
cp $OPENJDK_SIMULATOR_BUILD/jdk/include/ios/* $OPENJDK_SIMULATOR_BUILD/jdk/include/

# Create XCFramework
xcodebuild -create-xcframework \
  -library $DEVICE_TARGET/libdevice.a \
  -headers $OPENJDK_DEVICE_BUILD/jdk/include \
  -library $SIMULATOR_TARGET/libsim.a \
  -headers $OPENJDK_SIMULATOR_BUILD/jdk/include \
  -output ./OpenJDK.xcframework