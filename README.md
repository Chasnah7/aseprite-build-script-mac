# Aseprite-Build-Script-Mac

**Created by [Chasnah](https://chasnah.com/)**

## A customizable, automated macOS Zsh script for easily compiling Aseprite

Please refer to Aseprite's [INSTALL.md](https://github.com/aseprite/aseprite/blob/v1.3.10.1/INSTALL.md) to check for any updates to Aseprite installation procedure.

This script was tested in macOS Sonoma on a M1 Pro Macbook Pro. This script will target either Intel x86_64 or Apple Silicon arm64 based on what architecture is selected in paths.

As long as all dependencies are met and all paths are correct this script will automatically download and extract
both the Aseprite source code and a pre-built package of Skia then run the build process.

## Dependencies

* The latest version of [Cmake](https://cmake.org) (3.16 or greater)
* [Curl](https://curl.se/) (Bundled with macOS)
* [Ninja](https://ninja-build.org/) build system
* Minimum [Xcode 13.1](https://apps.apple.com/us/app/xcode/id497799835?mt=12) and macOS 11.3 SDK
* Installing [Homebrew](<https://homebrew.sh/>) is recommended to install several dependencies:

         brew install ninja cmake

* Note that Homebrew requires Xcode's Command Line Tools which can be installed with the following command:

         xcode-select --install

## Explanation of Paths

The user customizable portion of this script consists of paths. Most of these paths can be changed to better fit your build environment. Below is a short description of each path in order of appearance.

1. DEPS

    * Change DEPS path to your main working directory. The working directory will be created for you if it does not already exist.

2. ASEPRITE

    * Path where Aseprite's source code will be unzipped into, this directory is created for you. DO NOT MODIFY!

3. SKIA

    * Path where Skia will be unzipped into, this directory is created for you. DO NOT MODIFY!

4. ASEZIP

    * Determines what URL Aseprite's source code is downloaded from, modify if you are building a different version of aseprite.

5. SKIAZIP

    * Determines what URL Skia is downloaded from, uncomment the version for x64 if you are targeting Intel based Macs. Modify if your version of INSTALL.MD recommends a different version of Skia.

6. ARCH

    * Determines which architecture you are targeting, uncomment intel if you are targeting Intel based Macs.

## Updating and Changing Architectures

* If you have previously run the script and have changed the URL for ASEZIP, please make sure to delete the previous aseprite directory in the working directory (DEPS).

* If you have previously run the script and are targeting a different architecure than before or you change the URL for SKIAZIP, please make sure to delete the skia directory in the working directory (DEPS).

## Details

After adjusting paths to fit your build environment simply execute the script and it will run completely hands off, creating your specified working directory and all subdirectories if they do not already exist.

Aseprite source code and a pre-built copy of Skia are curled into the temp directory and extracted into their respective subdirectories.

The script will then begin the build process based on instructions from [INSTALL.md](https://github.com/aseprite/aseprite/blob/main/INSTALL.md).

Upon completion the script will output a DIR command displaying the newly compiled Aseprite located in the
$ASEPRITE\build\bin directory. You can copy the executable and data folder located in the previously mentioned bin directory into a new folder named aseprite.app and it will function as a normal macOS application.

Enjoy using Aseprite!
