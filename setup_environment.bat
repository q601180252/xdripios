@echo off
echo 正在初始化 xDrip iOS 项目环境...

echo.
echo 1. 检查 Xcode 版本...
xcodebuild -version

echo.
echo 2. 检查 Ruby 版本...
ruby --version

echo.
echo 3. 安装 Bundler...
gem install bundler:2.4.19

echo.
echo 4. 安装项目依赖...
bundle install

echo.
echo 5. 解析 Swift Package Manager 依赖...
xcodebuild -workspace xdrip.xcworkspace -scheme xdrip -resolvePackageDependencies

echo.
echo 6. 验证项目配置...
xcodebuild -workspace xdrip.xcworkspace -scheme xdrip -configuration Debug -showBuildSettings | findstr "PRODUCT_NAME\|BUNDLE_IDENTIFIER\|DEVELOPMENT_TEAM"

echo.
echo 项目初始化完成！
echo.
echo 可用的构建方案：
echo - xdrip (主应用)
echo - BleLibrary (蓝牙库)
echo - FotaLibrary (固件更新库)
echo - xDrip Watch App (Apple Watch 应用)
echo - xDrip Widget Extension (小组件扩展)
echo - xDrip Notification Context Extension (通知扩展)
echo - xDrip Watch Complication Extension (表盘复杂功能扩展)
echo.
echo 构建命令示例：
echo xcodebuild -workspace xdrip.xcworkspace -scheme xdrip -configuration Debug -destination "platform=iOS Simulator,name=iPhone 15 Pro" build
echo.
pause
