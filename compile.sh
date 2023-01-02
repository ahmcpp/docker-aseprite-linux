#!/bin/bash

# Fail on errors
set -e

echo "Download and compile Skia & other dependencies"
cd /dependencies

if [ ! -d "/dependencies/skia" ]
then
    curl -L -o "Skia-Linux-Release-x64-libc++.zip" https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
    unzip ./Skia-Linux-Release-x64-libc++.zip -d ./skia
    rm ./Skia-Linux-Release-x64-libc++.zip
fi

echo "Download Aseprite and compile"
cd /output

if [ ! -d "/output/aseprite" ]
then
  git clone -b v1.2.40 --recursive https://github.com/aseprite/aseprite.git
fi

cd aseprite
mkdir -p build
cd build

echo "Compiling Asperite"
export CC=clang-10
export CXX=clang++-10
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=/dependencies/skia \
  -DSKIA_LIBRARY_DIR=/dependencies/skia/out/Release-x64 \
  -DSKIA_LIBRARY=/dependencies/skia/out/Release-x64/libskia.a \
  -G Ninja \
  ..

echo "Linking Aseprite"
ninja aseprite
