pushd submodules/libui
mkdir -p build && cd build
mkdir "$OS_NAME" && cd "$OS_NAME"
/build/cmake/bin/cmake ../../ -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
/build/cmake/bin/cmake --build . --config Release
popd