@ECHO OFF

for /f "delims=" %%i in ('git -C submodules/libui rev-list --count HEAD') do set DOTNET_BUILD_VERSION=%%i
cd submodules/libui
git apply -- ../../CMakeLists.txt.VisualStudio.patched
cmake --version
mkdir build && cd build
mkdir x86 && cd x86
cmake ../../ -G"Visual Studio 14 2015" -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
mkdir ..\x64 && cd ../x64
cmake ../../ -G"Visual Studio 14 2015 Win64" -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
mkdir ..\ARM && cd ../ARM
cmake ../../ -G"Visual Studio 14 2015 ARM" -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
cd ../../../../


PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%~dp0build.ps1' %*; exit $LASTEXITCODE"
