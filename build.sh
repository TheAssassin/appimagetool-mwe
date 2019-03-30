#! /bin/bash

#! /bin/bash

set -x
set -e

# build in different directory outside CI systems
if [ "$CI" == "" ]; then
    # use RAM disk if possible
    if [ -d /dev/shm ]; then
        TEMP_BASE=/dev/shm
    else
        TEMP_BASE=/tmp
    fi

    BUILD_DIR=$(mktemp -d -p "$TEMP_BASE" AppImageLauncher-build-XXXXXX)

    cleanup () {
        if [ -d "$BUILD_DIR" ]; then
            rm -rf "$BUILD_DIR"
        fi
    }

    trap cleanup EXIT

    # store repo root as variable
    REPO_ROOT=$(readlink -f $(dirname $(dirname $0)))
    OLD_CWD=$(readlink -f .)

    pushd "$BUILD_DIR"
fi

mkdir AppDir
touch AppDir/example.png
cat > AppDir/example.desktop <<\EOF
[Desktop Entry]
Name=example
Icon=example
Exec=example
Type=Application
Categories=Development;
Terminal=true
EOF

cat > AppDir/AppRun <<\EOF
#! /bin/bash
echo "It's ALIVE!!!!111elf"
EOF

chmod +x AppDir/AppRun

wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage

chmod +x appimagetool-x86_64.AppImage

export ARCH=x86_64
./appimagetool-x86_64.AppImage -g AppDir

./example*.AppImage
