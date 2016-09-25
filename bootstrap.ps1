
#$hh = Get-WmiObject -Class Win32_Processor -ComputerName . | Select-Object -Property NumberOfLogicalProcessors
#cd tmp
$currentDir=$pwd
mkdir deps -force
$perl=$false
$git=$false
Import-Module BitsTransfer
$sparkledir=""
function checkForCommands(){
"Checking for Programs"
if(Get-Command git){
"have git"
$git=$true
}else{
$git=$false
"You Need git;"}


if(Get-Command -ErrorAction SilentlyContinue perl){
"have perl"
$perl=$true
}else{
$perl=$false
"You Need perl"}
if($env:QT){
"you have Qt"
}
else{
"you need Qt"
}}

function installMissing(){
if(-Not(Get-Command -ErrorAction Continue choco )){
"installing chocolaty"
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}
if(!$perl){
cinst -y strawberryperl --allow-empty-checksums
}
}

function compileQT(){
  if(!(Test-Path ".\qt-everywhere-opensource-src-5.7.0.7z")) {
  Start-BitsTransfer -Priority Foreground -source "http://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_57/qt.57.win32_msvc2015/5.7.0-1qtwebsockets-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"
  Start-BitsTransfer -Priority Foreground -source "http://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_57/qt.57.win32_msvc2015/5.7.0-1qttools-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"
  Start-BitsTransfer -Priority Foreground -source "http://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_57/qt.57.win32_msvc2015/5.7.0-1qtsvg-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"
  Start-BitsTransfer -Priority Foreground -source "http://download.qt.io/online/qtsdkrepository/windows_x86/desktop/qt5_57/qt.57.win32_msvc2015/5.7.0-1qtbase-Windows-Windows_10-MSVC2015-Windows-Windows_10-X86.7z"

  
  #& 7z x qt*.7z
}


#"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
#& .\configure.bat -opensource -platform win32-msvc2015 -MP -release -confirm-license -prefix C:\qtopen
#jom -j 16
}

function compileJOM(){
    if(!(Test-Path ".\jom.zip")) {
  Start-BitsTransfer -source 'http://download.qt.io/official_releases/jom/jom.zip' -Destination "jom.zip"
  & 7z x jom.zip -ojom
}
if(!(Test-Path ".\jom")) {
  & 7z x jom.zip -ojom
}
$env:Path += ";"+ $(Resolve-Path .\jom\)
}
function compilesparkle(){
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/vslavik/winsparkle/releases/download/v0.5.2/WinSparkle-0.5.2-src.7z","$pwd\WinSparkle-0.5.2-src.7z")
& 7z x WinSparkle-0.5.2-src.7z
pushd WinSparkle-0.5.2-src
msbuild WinSparkle-2015.sln /property:Configuration=Release /property:Platform=x64 /m
$sparkledir=$(pwd)
popd
}
function compileProtobuf(){
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/google/protobuf/releases/download/v3.0.0/protobuf-cpp-3.0.0.zip","$pwd\protobuf-cpp-3.0.0.zip")
& 7z.exe x -y protobuf-cpp-3.0.0.zip
pushd protobuf-3.0.0\cmake
mkdir build
pushd build
mkdir Release
pushd  Release
mkdir $currentDir\deps\protobuf
cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX="$(Resolve-Path $currentDir\deps\protobuf)" -Wno-dev -DCMAKE_BUILD_TYPE=Release ..\..
cmake --build .
cmake --build . -- install
$env:Path += ";"+ "C:\Program Files (x86)\protobuf\bin"
popd
popd
popd
}
function compilecryptopp(){
Start-BitsTransfer -source "https://www.cryptopp.com/cryptopp564.zip" -Destination "cryptopp564.zip"
7z.exe x -y -ocryptopp564 cryptopp564.zip
pushd cryptopp564
mkdir build
pushd build
mkdir -Force release
pushd release
mkdir $currentDir\deps\cryptopp
cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX="$(Resolve-Path $currentDir\deps\cryptopp)" ..\..
cmake --build .
cmake --build . -- test
cmake --build . -- install
popd
popd
popd
}
function compilemain(){

git clone https://github.com/librevault/librevault.git
pushd librevault
git submodule update --init
mkdir build
pushd build
cmake -DBOOST_ROOT="C:\Libraries\boost_1_59_0" -DBOOST_LIBRARYDIR="C:\Libraries\boost_1_59_0\lib32-msvc-14.0" -DCMAKE_PREFIX_PATH="C:\Qt\5.7\msvc2015\lib\cmake\Qt5" -DUSE_BUNDLED_SQLITE3="TRUE" -DPROTOBUF_INCLUDE_DIR="C:\libraries\protoc-3.0.0\cmake\build\release" -DPROTOBUF_LIBRARY='C:\libraries\protoc-3.0.0\cmake\build\release' -DCRYPTOPP_ROOT_DIR='C:\Program Files (x86)\cryptopp' -Dwinsparkle_LIBRARIES="$sparkledir/release" -DCRYPTOPP_LIBRARY="C:\Program Files (x86)\cryptopp\lib" ..
cmake --build .
}
function setupVSudio(){
#Set environment variables for Visual Studio Command Prompt
pushd "$env:VS140COMNTOOLS\..\..\VC"
cmd /c "vcvarsall.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  }
}
popd
cd $currentDir
write-host '`nVisual Studio 2015 Command Prompt variables set.' -ForegroundColor Yellow
}
mkdir -force -ErrorAction SilentlyContinue tmp
pushd tmp
#checkForCommands
#installMissing
setupVSudio
#compileJOM
#compileQT
compilecryptopp
compileProtobuf
compilesparkle
compilemain
popd tmp