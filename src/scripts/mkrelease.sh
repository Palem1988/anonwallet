#!/bin/bash
if [ -z $QT_STATIC ]; then 
    echo "QT_STATIC is not set. Please set it to the base directory of a statically compiled Qt"; 
    exit 1; 
fi

if [ -z $APP_VERSION ]; then echo "APP_VERSION is not set"; exit 1; fi
if [ -z $PREV_VERSION ]; then echo "PREV_VERSION is not set"; exit 1; fi

if [ -z $ANON_DIR ]; then
    echo "ANON_DIR is not set. Please set it to the base directory of a Anon project with built Anon binaries."
    exit 1;
fi

if [ ! -f $ANON_DIR/artifacts/anond ]; then
    echo "Couldn't find anond in $ANON_DIR/artifacts/. Please build anond."
    exit 1;
fi

if [ ! -f $ANON_DIR/artifacts/anon-cli ]; then
    echo "Couldn't find anon-cli in $ANON_DIR/artifacts/. Please build anond."
    exit 1;
fi

# Ensure that anond is the right build
echo -n "anond version........."
if grep -q "zqwMagicBean" $ANON_DIR/artifacts/anond && ! readelf -s $ANON_DIR/artifacts/anond | grep -q "GLIBC_2\.25"; then 
    echo "[OK]"
else
    echo "[ERROR]"
    echo "anond doesn't seem to be a zqwMagicBean build or anond is built with libc 2.25"
    exit 1
fi

echo -n "anond.exe version....."
if grep -q "zqwMagicBean" $ANON_DIR/artifacts/anond.exe; then 
    echo "[OK]"
else
    echo "[ERROR]"
    echo "anond doesn't seem to be a zqwMagicBean build"
    exit 1
fi

echo -n "Version files.........."
# Replace the version number in the .pro file so it gets picked up everywhere
sed -i "s/${PREV_VERSION}/${APP_VERSION}/g" anon-qt-wallet.pro > /dev/null

# Also update it in the README.md
sed -i "s/${PREV_VERSION}/${APP_VERSION}/g" README.md > /dev/null
echo "[OK]"

echo -n "Cleaning..............."
rm -rf bin/*
rm -rf artifacts/*
make distclean >/dev/null 2>&1
echo "[OK]"

echo ""
echo "[Building on" `lsb_release -r`"]"

echo -n "Configuring............"
QT_STATIC=$QT_STATIC bash src/scripts/dotranslations.sh >/dev/null
$QT_STATIC/bin/qmake anon-qt-wallet.pro -spec linux-clang CONFIG+=release > /dev/null
echo "[OK]"


echo -n "Building..............."
rm -rf bin/anon-qt-wallet* > /dev/null
rm -rf bin/anonwallet* > /dev/null
make clean > /dev/null
make -j$(nproc) > /dev/null
echo "[OK]"


# Test for Qt
echo -n "Static link............"
if [[ $(ldd anonwallet | grep -i "Qt") ]]; then
    echo "FOUND QT; ABORT"; 
    exit 1
fi
echo "[OK]"


echo -n "Packaging.............."
mkdir bin/anonwallet-v$APP_VERSION > /dev/null
strip anonwallet

cp anonwallet                  bin/anonwallet-v$APP_VERSION > /dev/null
cp $ANON_DIR/artifacts/anond    bin/anonwallet-v$APP_VERSION > /dev/null
cp $ANON_DIR/artifacts/anon-cli bin/anonwallet-v$APP_VERSION > /dev/null
cp README.md                      bin/anonwallet-v$APP_VERSION > /dev/null
cp LICENSE                        bin/anonwallet-v$APP_VERSION > /dev/null

cd bin && tar czf linux-anonwallet-v$APP_VERSION.tar.gz anonwallet-v$APP_VERSION/ > /dev/null
cd .. 

mkdir artifacts >/dev/null 2>&1
cp bin/linux-anonwallet-v$APP_VERSION.tar.gz ./artifacts/linux-binaries-anonwallet-v$APP_VERSION.tar.gz
echo "[OK]"


if [ -f artifacts/linux-binaries-anonwallet-v$APP_VERSION.tar.gz ] ; then
    echo -n "Package contents......."
    # Test if the package is built OK
    if tar tf "artifacts/linux-binaries-anonwallet-v$APP_VERSION.tar.gz" | wc -l | grep -q "6"; then 
        echo "[OK]"
    else
        echo "[ERROR]"
        exit 1
    fi    
else
    echo "[ERROR]"
    exit 1
fi

echo -n "Building deb..........."
debdir=bin/deb/anonwallet-v$APP_VERSION
mkdir -p $debdir > /dev/null
mkdir    $debdir/DEBIAN
mkdir -p $debdir/usr/local/bin

cat src/scripts/control | sed "s/RELEASE_VERSION/$APP_VERSION/g" > $debdir/DEBIAN/control

cp anonwallet                   $debdir/usr/local/bin/
cp $ANON_DIR/artifacts/anond $debdir/usr/local/bin/zqw-anond

mkdir -p $debdir/usr/share/pixmaps/
cp res/anonwallet.xpm           $debdir/usr/share/pixmaps/

mkdir -p $debdir/usr/share/applications
cp src/scripts/desktopentry    $debdir/usr/share/applications/anon-qt-wallet.desktop

dpkg-deb --build $debdir >/dev/null
cp $debdir.deb                 artifacts/linux-deb-anonwallet-v$APP_VERSION.deb
echo "[OK]"



echo ""
echo "[Windows]"

if [ -z $MXE_PATH ]; then 
    echo "MXE_PATH is not set. Set it to ~/github/mxe/usr/bin if you want to build Windows"
    echo "Not building Windows"
    exit 0; 
fi

if [ ! -f $ANON_DIR/artifacts/anond.exe ]; then
    echo "Couldn't find anond.exe in $ANON_DIR/artifacts/. Please build anond.exe"
    exit 1;
fi


if [ ! -f $ANON_DIR/artifacts/anon-cli.exe ]; then
    echo "Couldn't find anon-cli.exe in $ANON_DIR/artifacts/. Please build anond.exe"
    exit 1;
fi

export PATH=$MXE_PATH:$PATH

echo -n "Configuring............"
make clean  > /dev/null
rm -f anon-qt-wallet-mingw.pro
rm -rf release/
#Mingw seems to have trouble with precompiled headers, so strip that option from the .pro file
cat anon-qt-wallet.pro | sed "s/precompile_header/release/g" | sed "s/PRECOMPILED_HEADER.*//g" > anon-qt-wallet-mingw.pro
echo "[OK]"


echo -n "Building..............."
x86_64-w64-mingw32.static-qmake-qt5 anon-qt-wallet-mingw.pro CONFIG+=release > /dev/null
make -j32 > /dev/null
echo "[OK]"


echo -n "Packaging.............."
mkdir release/anonwallet-v$APP_VERSION  
cp release/anonwallet.exe          release/anonwallet-v$APP_VERSION 
cp $ANON_DIR/artifacts/anond.exe    release/anonwallet-v$APP_VERSION > /dev/null
cp $ANON_DIR/artifacts/anon-cli.exe release/anonwallet-v$APP_VERSION > /dev/null
cp README.md                          release/anonwallet-v$APP_VERSION 
cp LICENSE                            release/anonwallet-v$APP_VERSION 
cd release && zip -r Windows-binaries-anonwallet-v$APP_VERSION.zip anonwallet-v$APP_VERSION/ > /dev/null
cd ..

mkdir artifacts >/dev/null 2>&1
cp release/Windows-binaries-anonwallet-v$APP_VERSION.zip ./artifacts/
echo "[OK]"

if [ -f artifacts/Windows-binaries-anonwallet-v$APP_VERSION.zip ] ; then
    echo -n "Package contents......."
    if unzip -l "artifacts/Windows-binaries-anonwallet-v$APP_VERSION.zip" | wc -l | grep -q "11"; then 
        echo "[OK]"
    else
        echo "[ERROR]"
        exit 1
    fi
else
    echo "[ERROR]"
    exit 1
fi
