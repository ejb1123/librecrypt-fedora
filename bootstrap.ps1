mkdir -force tmp
cd tmp
Import-Module BitsTransfer
if(!(Test-Path ".\jom.zip")) {
  Start-BitsTransfer -source 'http://download.qt.io/official_releases/jom/jom.zip'-Destination "$PSScriptRoot\tmp\jom.zip"
  7z x jom.zip -ojom
}
if(!(Test-Path ".\jom")) {
  7z x jom.zip -ojom
}
$env:Path += ";"+ $(Resolve-Path .\jom\)
if(!(Test-Path ".\qt-everywhere-opensource-src-5.7.0.7z")) {
  Start-BitsTransfer -Priority Foreground -source "http://download.qt.io/archive/qt/5.7/5.7.0/single/qt-everywhere-opensource-src-5.7.0.7z" -Destination "$PSScriptRoot\tmp\qt-everywhere-opensource-src-5.7.0.7z"
  7z x qt-everywhere-opensource-src-5.7.0.7z
}
if(!(Test-Path ".\qt-everywhere-opensource-src-5.7.0")) {
  7z x qt-everywhere-opensource-src-5.7.0.7z
}
cd qt-everywhere-opensource-src-5.7.0
"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
configure.bat -opensource -platform win32-msvc2015 -release -confirm-license -prefix $PWD/qtbase
$hh = Get-WmiObject -Class Win32_Processor -ComputerName . | Select-Object -Property NumberOfLogicalProcessors
jom -j$hh
