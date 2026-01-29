@echo off
setlocal enabledelayedexpansion

REM xDrip iOS Windows 构建脚本
REM 用于在 Windows 环境通过 WSL 构建 IPA 文件

set "WORKSPACE=xdrip.xcworkspace"
set "SCHEME=xdrip"
set "BUILD_CONFIG=Release"
set "ARCHIVE_PATH=build/xdrip.xcarchive"
set "EXPORT_PATH=build/ipa"
set "EXPORT_OPTIONS=ExportOptions.plist"

echo.
echo ==========================================
echo    xDrip iOS Windows 构建脚本
echo ==========================================
echo.

REM 检查 WSL 是否可用
wsl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: WSL 未安装或不可用
    echo 请先安装 WSL 2 和 Ubuntu
    pause
    exit /b 1
)

REM 检查项目文件
if not exist "%WORKSPACE%" (
    echo 错误: 找不到工作空间文件 %WORKSPACE%
    pause
    exit /b 1
)

if not exist "%EXPORT_OPTIONS%" (
    echo 错误: 找不到导出选项文件 %EXPORT_OPTIONS%
    pause
    exit /b 1
)

echo 检查 WSL 环境...
wsl -e bash -c "which xcodebuild" >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: WSL 中未找到 xcodebuild
    echo 请确保在 WSL 中安装了 Xcode Command Line Tools
    echo 运行: xcode-select --install
    pause
    exit /b 1
)

echo.
echo 开始构建过程...
echo.

REM 清理构建目录
echo [1/5] 清理构建目录...
wsl -e bash -c "rm -rf build/ && mkdir -p build/ipa"

REM 安装依赖
echo [2/5] 安装 Ruby 依赖...
wsl -e bash -c "gem install bundler:2.4.19 && bundle install"

REM 解析包依赖
echo [3/5] 解析 Swift Package Manager 依赖...
wsl -e bash -c "xcodebuild -workspace %WORKSPACE% -scheme %SCHEME% -resolvePackageDependencies"

REM 构建应用
echo [4/5] 构建应用...
wsl -e bash -c "xcodebuild clean -workspace %WORKSPACE% -scheme %SCHEME%"
wsl -e bash -c "xcodebuild archive -workspace %WORKSPACE% -scheme %SCHEME% -configuration %BUILD_CONFIG% -destination \"generic/platform=iOS\" -archivePath %ARCHIVE_PATH% CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=7RV2Y67HF6"

REM 导出 IPA
echo [5/5] 导出 IPA 文件...
wsl -e bash -c "xcodebuild -exportArchive -archivePath %ARCHIVE_PATH% -exportPath %EXPORT_PATH% -exportOptionsPlist %EXPORT_OPTIONS%"

REM 检查结果
wsl -e bash -c "if [ -d \"%EXPORT_PATH%\" ]; then echo '构建成功！'; ls -la %EXPORT_PATH%/*.ipa; else echo '构建失败！'; exit 1; fi"

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo           构建成功完成！
    echo ==========================================
    echo.
    echo IPA 文件已生成在 build/ipa/ 目录中
    echo.
    wsl -e bash -c "ls -la %EXPORT_PATH%/*.ipa"
) else (
    echo.
    echo ==========================================
    echo           构建失败！
    echo ==========================================
    echo.
    echo 请检查错误信息并重试
)

echo.
pause
