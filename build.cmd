@ECHO OFF

for /f "delims=" %%i in ('git -C submodules/libui rev-list --count HEAD') do set DOTNET_BUILD_VERSION=%%i

PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "[System.Threading.Thread]::CurrentThread.CurrentCulture = ''; [System.Threading.Thread]::CurrentThread.CurrentUICulture = '';& '%~dp0build.ps1' %*; exit $LASTEXITCODE"
