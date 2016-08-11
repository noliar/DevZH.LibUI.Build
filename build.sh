#!/usr/bin/env bash
repoFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $repoFolder

export DOTNET_BUILD_VERSION=$(git -C submodules/libui rev-list --count HEAD)
cmake --version
if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    export OS_NAME="ubuntu"
    source ./build-with-cmake.sh
    mkdir -p artifacts/build/package-src-linux/contents/runtimes/debian-x64/native
    cp submodules/libui/build/ubuntu/out/libui.so artifacts/build/package-src-linux/contents/runtimes/debian-x64/native

    curl -sSL -o cmake.tar.gz https://cmake.org/files/v3.6/cmake-3.6.1-Linux-x86_64.tar.gz
    tar zxf cmake.tar.gz
    mv cmake-3.6.1-Linux-x86_64 cmake

    export OS_NAME="centos"
    pushd submodules/libui
    git apply -- ../../CMakeLists.txt.CentOS.patched
    popd
    docker pull centos:7
    docker run -t -e OS_NAME -v $(pwd):/build -v /usr/bin:/usrbin centos:7 /bin/sh -c "cd /build && ./build-rhel.sh && ./build-with-extra-cmake.sh"
    mkdir -p artifacts/build/package-src-linux/contents/runtimes/rhel-x64/native
    cp submodules/libui/build/centos/out/libui.so artifacts/build/package-src-linux/contents/runtimes/rhel-x64/native
    pushd submodules/libui
    git apply -R ../../CMakeLists.txt.CentOS.patched
    popd

    export OS_NAME="fedora"
    docker pull fedora:23
    docker run -t -e OS_NAME -v $(pwd):/build -v /usr/bin:/usrbin fedora:23 /bin/sh -c "cd /build && ./build-fedora.sh && ./build-with-extra-cmake.sh"
    mkdir -p artifacts/build/package-src-linux/contents/runtimes/fedora-x64/native
    cp submodules/libui/build/fedora/out/libui.so artifacts/build/package-src-linux/contents/runtimes/fedora-x64/native

    export OS_NAME="opensuse"
    docker pull opensuse:13.2
    docker run -t -e OS_NAME -v $(pwd):/build -v /usr/bin:/usrbin opensuse:13.2 /bin/sh -c "cd /build && ./build-opensuse.sh && ./build-with-extra-cmake.sh"
    mkdir -p artifacts/build/package-src-linux/contents/runtimes/opensuse-x64/native
    cp submodules/libui/build/opensuse/out/libui.so artifacts/build/package-src-linux/contents/runtimes/opensuse-x64/native
else
    export OS_NAME="osx"
    source ./build-with-cmake.sh
    mkdir -p artifacts/build/package-src-darwin/contents/runtimes/osx-x64/native
    cp submodules/libui/build/osx/out/libui.dylib artifacts/build/package-src-darwin/contents/runtimes/osx-x64/native
fi

koreBuildZip="https://github.com/aspnet/KoreBuild/archive/dev.zip"
if [ ! -z $KOREBUILD_ZIP ]; then
    koreBuildZip=$KOREBUILD_ZIP
fi

buildFolder=".build"
buildFile="$buildFolder/KoreBuild.sh"

if test ! -d $buildFolder; then
    echo "Downloading KoreBuild from $koreBuildZip"
    
    tempFolder="/tmp/KoreBuild-$(uuidgen)"    
    mkdir $tempFolder
    
    localZipFile="$tempFolder/korebuild.zip"
    
    retries=6
    until (wget -O $localZipFile $koreBuildZip 2>/dev/null || curl -o $localZipFile --location $koreBuildZip 2>/dev/null)
    do
        echo "Failed to download '$koreBuildZip'"
        if [ "$retries" -le 0 ]; then
            exit 1
        fi
        retries=$((retries - 1))
        echo "Waiting 10 seconds before retrying. Retries left: $retries"
        sleep 10s
    done
    
    unzip -q -d $tempFolder $localZipFile
  
    mkdir $buildFolder
    cp -r $tempFolder/**/build/** $buildFolder
    
    chmod +x $buildFile
    
    # Cleanup
    if test ! -d $tempFolder; then
        rm -rf $tempFolder  
    fi
fi

$buildFile -r $repoFolder "$@"