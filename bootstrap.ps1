mkdir -force tmp
#$hh = Get-WmiObject -Class Win32_Processor -ComputerName . | Select-Object -Property NumberOfLogicalProcessors
cd tmp



Import-Module BitsTransfer
$sparkledir=""

function compileQT(){
  if(!(Test-Path ".\qt-everywhere-opensource-src-5.7.0.7z")) {
  Start-BitsTransfer -Priority Foreground -source "http://download.qt.io/archive/qt/5.7/5.7.0/single/qt-everywhere-opensource-src-5.7.0.7z" -Destination "qt-everywhere-opensource-src-5.7.0.7z"
  & 7z x qt-everywhere-opensource-src-5.7.0.7z
}
if(!(Test-Path ".\qt-everywhere-opensource-src-5.7.0")) {
  & 7z x qt-everywhere-opensource-src-5.7.0.7z
}
cd qt-everywhere-opensource-src-5.7.0
"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
& .\configure.bat -opensource -platform win32-msvc2015 -release -confirm-license -prefix $PWD/qtbase
jom -j 16
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
& 7z.exe x protobuf-cpp-3.0.0.zip
pushd protobuf-3.0.0\cmake
mkdir build
pushd build
mkdir Release
pushd  Release
cmake -G "NMake Makefiles JOM" -DCMAKE_BUILD_TYPE=Release ../..
jom -J 16
jom install
popd
popd
popd
}
function compilecryptopp(){
appveyor DownloadFile "http://downloads.sourceforge.net/project/cryptopp/cryptopp/5.6.4/cryptopp564.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fcryptopp%2F%3Fsource%3Dtyp_redirect&ts=1474246354&use_mirror=pilotfiber"
7z.exe x -ocryptopp564 cryptopp564.zip
pushd cryptopp564
mkdir build
pushd build
mkdir release
pushd release
cmake -G "NMake Makefiles JOM" -DCMAKE_RELEASE_TYPE=release ..\..
cmake --build . -- -j 16
cmake --build . -- test
nmake install
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
#cmake --build .
}
function setupVSudio(){
#Set environment variables for Visual Studio Command Prompt
pushd "$env:VS140COMNTOOLS"
cmd /c "vsvars32.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  }
}
popd
write-host '`nVisual Studio 2015 Command Prompt variables set.' -ForegroundColor Yellow
}
setupVSudio
compileJOM
compilecryptopp
compileProtobuf
compilesparkle
compilemain
