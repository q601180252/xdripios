#!/bin/bash

# xDrip iOS 本地构建脚本
# 用于在本地环境构建 IPA 文件

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
WORKSPACE="xdrip.xcworkspace"
SCHEME="xdrip"
BUILD_CONFIG="Release"
ARCHIVE_PATH="build/xdrip.xcarchive"
EXPORT_PATH="build/ipa"
EXPORT_OPTIONS="ExportOptions.plist"

# 函数：打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 函数：检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message $RED "错误: $1 命令未找到"
        exit 1
    fi
}

# 函数：清理构建目录
clean_build() {
    print_message $YELLOW "清理构建目录..."
    rm -rf build/
    mkdir -p build/ipa
}

# 函数：安装依赖
install_dependencies() {
    print_message $BLUE "安装 Ruby 依赖..."
    if ! command -v bundler &> /dev/null; then
        gem install bundler:2.4.19
    fi
    bundle install
    
    print_message $BLUE "解析 Swift Package Manager 依赖..."
    xcodebuild -workspace $WORKSPACE -scheme $SCHEME -resolvePackageDependencies
}

# 函数：构建应用
build_app() {
    print_message $BLUE "开始构建应用..."
    
    # 清理项目
    xcodebuild clean -workspace $WORKSPACE -scheme $SCHEME
    
    # 构建归档
    xcodebuild archive \
        -workspace $WORKSPACE \
        -scheme $SCHEME \
        -configuration $BUILD_CONFIG \
        -destination "generic/platform=iOS" \
        -archivePath $ARCHIVE_PATH \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM=7RV2Y67HF6
}

# 函数：导出 IPA
export_ipa() {
    print_message $BLUE "导出 IPA 文件..."
    
    xcodebuild -exportArchive \
        -archivePath $ARCHIVE_PATH \
        -exportPath $EXPORT_PATH \
        -exportOptionsPlist $EXPORT_OPTIONS
}

# 函数：显示构建结果
show_results() {
    print_message $GREEN "构建完成！"
    
    if [ -d "$EXPORT_PATH" ]; then
        print_message $GREEN "IPA 文件位置:"
        ls -la $EXPORT_PATH/*.ipa
        
        # 显示文件大小
        IPA_FILE=$(ls $EXPORT_PATH/*.ipa | head -1)
        if [ -f "$IPA_FILE" ]; then
            FILE_SIZE=$(du -h "$IPA_FILE" | cut -f1)
            print_message $GREEN "文件大小: $FILE_SIZE"
        fi
    else
        print_message $RED "错误: IPA 文件未找到"
        exit 1
    fi
}

# 主函数
main() {
    print_message $GREEN "xDrip iOS 本地构建脚本"
    print_message $GREEN "=========================="
    
    # 检查必要的命令
    check_command "xcodebuild"
    check_command "gem"
    check_command "bundle"
    
    # 检查必要文件
    if [ ! -f "$WORKSPACE" ]; then
        print_message $RED "错误: 找不到工作空间文件 $WORKSPACE"
        exit 1
    fi
    
    if [ ! -f "$EXPORT_OPTIONS" ]; then
        print_message $RED "错误: 找不到导出选项文件 $EXPORT_OPTIONS"
        exit 1
    fi
    
    # 执行构建步骤
    clean_build
    install_dependencies
    build_app
    export_ipa
    show_results
    
    print_message $GREEN "构建成功完成！"
}

# 处理命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            BUILD_CONFIG="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  -c, --config CONFIG    设置构建配置 (Debug/Release, 默认: Release)"
            echo "  -h, --help            显示帮助信息"
            exit 0
            ;;
        *)
            print_message $RED "未知参数: $1"
            echo "使用 -h 或 --help 查看帮助信息"
            exit 1
            ;;
    esac
done

# 运行主函数
main
