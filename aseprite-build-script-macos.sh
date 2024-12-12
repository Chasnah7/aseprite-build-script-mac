#!/bin/zsh
emulate -LR zsh

# REMEMBER TO CONSULT README.MD FIRST!
# IF YOU RECIEVED THIS SCRIPT FROM ANYWHERE OTHER THAN https://github.com/Chasnah7/aseprite-build-script
# DOUBLE CHECK TO MAKE SURE IT HAS NOT BEEN MALICIOUSLY EDITED.
# THE AUTHOR CLAIMS NO LIABILITY NOR WARRANTY FOR THIS SCRIPT
# USE AT YOUR OWN RISK.

# Paths

export DEPS=$HOME/deps

export ASEPRITE=$DEPS/aseprite #DO NOT MODIFY!

export SKIA=$DEPS/skia #DO NOT MODIFY!

export ASEZIP=https://github.com/aseprite/aseprite/releases/download/v1.3.10.1/Aseprite-v1.3.10.1-Source.zip

export SKIAZIP=https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-macOS-Release-arm64.zip

#export SKIAZIP=https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-macOS-Release-x64.zip

#UNCOMMENT ABOVE IF YOU PLAN ON TARGETING INTEL BASED MACS

export ARCH=arm64

#export ARCH=intel

#UNCOMMENT ABOVE IF YOU PLAN ON TARGETING INTEL BASED MACS


#Everything below this comment is automated and shouldn't normally need to be modified.

#Dependencies check
DUMMY=$( xcode-select -p 2>&1 )
if [ "$?" -eq 0 ]; then
    echo "Xcode was found."
else
    echo "Xcode was not found."
    echo "Have you installed it via the App Store?"
    exit 1
fi

which -s ninja
if [ "$?" -eq 0 ]; then
    echo "Ninja build system was found."
else
    echo "Ninja build system was not found."
    echo "Did you correctly install it?"
    echo "brew install ninja"
    exit 1
fi

which -s cmake
if [ "$?" -eq 0 ]; then
    echo "Cmake was found."
else
    echo "Cmake was not found."
    echo "Did you correctly install it?"
    echo "brew install cmake"
    exit 1
fi

#Beginning directory creation and downloads

echo "Checking for deps directory..."
DUMMY=$(ls $DEPS 2>&1)
if [ "$?" -eq 0 ]; then
    echo "Deps directory found."
else
    echo "Deps directory was not found."
    echo "Creating deps directory..."
    mkdir $DEPS
    if [ "$?" -eq 0 ]; then
        echo "Deps directory successfully created."
    else
        echo "Something went wrong in checking for or creating the deps directory."
        echo "Did you set the correct DEPS path for your system?"
        echo "Do you have permission to create a directory in the specified location?"
        exit 1
    fi
fi

echo "Checking for aseprite checkout..."
DUMMY=$(ls $ASEPRITE/ 2>&1)
if [ "$?" -eq 0 ]; then
    echo "Aseprite was found."
else
    echo "Aseprite was not found."
    echo "Downloading aseprite..."
    rm $TMPDIR/asesrc.zip
    curl $ASEZIP -L -o $TMPDIR/asesrc.zip
    echo "Unzipping to $ASEPRITE..."
    mkdir $ASEPRITE
    tar -xf $TMPDIR/asesrc.zip -C $ASEPRITE
    if [ "$?" -eq 0 ]; then
        echo "Aseprite was successfully downloaded and unzipped."
    else
        echo "Aseprite failed to download and extract."
        echo "Are you connected to the internet?"
        echo "Does ASEZIP point to the correct URL?"
        echo "Fatal error. Aborting..."
        exit 1
    fi
fi

echo "Checking for Skia..."
DUMMY=$(ls $SKIA/ 2>&1)
if [ "$?" -eq 0 ]; then
    echo "Skia was found"
else
    echo "Skia was not found."
    echo "Downloading Skia m102..."
    rm $TMPDIR/skia.zip
    curl $SKIAZIP -L -o $TMPDIR/skia.zip
    echo "Unzipping to $SKIA..."
    mkdir $SKIA
    tar -xf $TMPDIR/skia.zip -C $SKIA
    if [ "$?" -eq 0 ]; then
        echo "Skia was successfully downloaded and unzipped."
    else
        echo "Skia failed to download and extract."
        echo "Are you connected to the internet?"
        echo "Does SKIAZIP point to the correct URL?"
        echo "Fatal Error. Aborting..."
        exit 1
    fi
fi

echo "All checks okay!"
echo "."

# Compile

echo "Setting system architecture..."
if [[ $(echo $ARCH) == *arm64* ]]; then 
    echo "Beginning build for Apple Silicon."
    cd $ASEPRITE
    mkdir build
    cd build
    cmake \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
        -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
        -DLAF_BACKEND=skia \
        -DSKIA_DIR=$SKIA \
        -DSKIA_LIBRARY_DIR=$SKIA/out/Release-arm64 \
        -DSKIA_LIBRARY=$SKIA/out/Release-arm64/libskia.a \
        -DPNG_ARM_NEON:STRING=on \
        -G Ninja \
        ..
else
    if [[ $(echo $ARCH) == *intel* ]]; then
        echo "Beginning build for Intel x86_64."
        cd $ASEPRITE
        mkdir build
        cd build
        cmake \
            -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DCMAKE_OSX_ARCHITECTURES=x86_64 \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
            -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
            -DLAF_BACKEND=skia \
            -DSKIA_DIR=$SKIA \
            -DSKIA_LIBRARY_DIR=$SKIA/out/Release-x64 \
            -DSKIA_LIBRARY=$SKIA/out/Release-x64/libskia.a \
            -G Ninja \
            ..

            if [ "$?" -eq 0 ]; then
                ninja aseprite
                if [ "$?" -eq 0 ]; then
                    echo "Build complete!"
                    echo "Finished build is located in the $ASEPRITE/build/bin directory."
                    ls -l $ASEPRITE/build/bin/
                    echo "The aseprite executable and data folder listed above can be moved into a new folder named "
                    echo "aseprite.app in order to function as a standard macOS application."
                    exit 0
                else
                    echo "Failed to compile"
                    echo "Are you using the correct version of Skia?"
                    echo "If you edited aseprite's source code you may have made an error, consult the compiler's output."
                    echo "Fatal error. Aborting..."
                    exit 1
                fi
            else
                echo "Configuring cmake failed"
                echo "Was the aseprite source code properly downloaded?"
                echo "Are you using the correct version of Skia?"
                echo "Is cmake up to date?"
                echo "Fatal error. Aborting..."
                exit 1
            fi

    else
        echo "Failed to set system architecture."
        echo "Did you properly uncomment which architecture you are targeting?"
        echo "Fatal error. Aborting..."
        exit 1
    fi
fi

if [ "$?" -eq 0 ]; then
    ninja aseprite
    if [ "$?" -eq 0 ]; then
        echo "Build complete!"
        echo "Finished build is located in the $ASEPRITE/build/bin directory."
        ls -l $ASEPRITE/build/bin/
        echo "The aseprite executable and data folder listed above can be moved into a new folder named "
        echo "aseprite.app in order to function as a standard macOS application."
        exit 0
    else
        echo "Failed to compile"
        echo "Are you using the correct version of Skia?"
        echo "If you edited aseprite's source code you may have made an error, consult the compiler's output."
        echo "Fatal error. Aborting..."
        exit 1
    fi
else
    echo "Configuring cmake failed"
    echo "Was the aseprite source code properly downloaded?"
    echo "Are you using the correct version of Skia?"
    echo "Is cmake up to date?"
    echo "Fatal error. Aborting..."
    exit 1
fi