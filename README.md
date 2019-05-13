# This wallet is under development and should NOT be used at this time
Skellers (13th May, 2019)

AnonWallet is a z-Addr first, Sapling compatible wallet and full node for anond that runs on Linux, Windows and macOS.

![Screenshot](docs/screenshot-main.png?raw=true)
![Screenshots](docs/screenshot-sub.png?raw=true)
# Installation

Head over to the releases page and grab the latest installers or binary. https://github.com/AnonFoundation/anonwallet/releases

### Linux

If you are on Debian/Ubuntu, please download the `.deb` package and install it.
```
sudo dpkg -i linux-deb-anonwallet-v0.6.9.deb
sudo apt install -f
```

Or you can download and run the binaries directly.
```
tar -xvf anonwallet-v0.6.9.tar.gz
./anonwallet-v0.6.9/anonwallet
```

### Windows
Download and run the `.msi` installer and follow the prompts. Alternately, you can download the release binary, unzip it and double click on `anonwallet.exe` to start.

### macOS
Double-click on the `.dmg` file to open it, and drag `anonwallet` on to the Applications link to install.

## anond
AnonWallet needs a Anon node running anond. If you already have a anond node running, AnonWallet will connect to it. 

If you don't have one, AnonWallet will start its embedded anond node. 

Additionally, if this is the first time you're running AnonWallet or a anond daemon, AnonWallet will download the anon params (~1.7 GB) and configure `anon.conf` for you. 

Pass `--no-embedded` to disable the embedded anond and force AnonWallet to connect to an external node.

## Compiling from source
AnonWallet is written in C++ 14, and can be compiled with g++/clang++/visual c++. It also depends on Qt5, which you can get from [here](https://www.qt.io/download). Note that if you are compiling from source, you won't get the embedded anond by default. You can either run an external anond, or compile anond as well. 

See detailed build instructions [on the wiki](https://github.com/AnonFoundation/anonwallet/wiki/Compiling-from-source-code)

### Building on Linux

```
git clone https://github.com/AnonFoundation/anonwallet.git
cd anonwallet
/path/to/qt5/bin/qmake anon-qt-wallet.pro CONFIG+=debug
make -j$(nproc)

./anonwallet
```

### Building on Windows
You need Visual Studio 2017 (The free C++ Community Edition works just fine). 

From the VS Tools command prompt
```
git clone  https://github.com/AnonFoundation/anonwallet.git
cd anonwallet
c:\Qt5\bin\qmake.exe anon-qt-wallet.pro -spec win32-msvc CONFIG+=debug
nmake

debug\anonwallet.exe
```

To create the Visual Studio project files so you can compile and run from Visual Studio:
```
c:\Qt5\bin\qmake.exe anon-qt-wallet.pro -tp vc CONFIG+=debug
```

### Building on macOS
You need to install the Xcode app or the Xcode command line tools first, and then install Qt. 

```
git clone https://github.com/AnonFoundation/anonwallet.git
cd anonwallet
/path/to/qt5/bin/qmake anon-qt-wallet.pro CONFIG+=debug
make

./anonwallet.app/Contents/MacOS/anonwallet
```

### [Troubleshooting Guide & FAQ](https://github.com/AnonFoundation/anonwallet/wiki/Troubleshooting-&-FAQ)
Please read the [troubleshooting guide](https://docs.anonwallet.co/troubleshooting/) for common problems and solutions.
For support or other questions, tweet at [@anonwallet](https://twitter.com/anonwallet) or [file an issue](https://github.com/AnonFoundation/anonwallet/issues).

_PS: AnonWallet is NOT an official wallet, and is not affiliated with the Electric Coin Company in any way._
