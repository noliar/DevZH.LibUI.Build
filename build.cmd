@ECHO OFF

cd submodules/libui
for /f "delims=" %%i in ('git rev-list --count HEAD') do set DOTNET_BUILD_VERSION=%%i
cmake --version
mkdir build && cd build
mkdir x86 && cd x86
cmake ../../ -G"Visual Studio 14 2015"
mkdir ..\x64 && cd ../x64
cmake ../../ -G"Visual Studio 14 2015 Win64"
mkdir ..\ARM && cd ../ARM
cmake ../../ -G"Visual Studio 14 2015 ARM"
cd ../../../../

PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%~dp0build.ps1' %*; exit $LASTEXITCODE"
