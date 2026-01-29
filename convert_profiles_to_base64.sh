#!/bin/bash

# 自动转换证书和 Provisioning Profiles 为 Base64

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $GREEN "🔐 Provisioning Profiles Base64 转换工具"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 创建输出目录
OUTPUT_DIR="$HOME/Desktop/xdrip_profiles_base64"
mkdir -p "$OUTPUT_DIR"

print_message $BLUE "📁 输出目录: $OUTPUT_DIR"
echo ""

# 1. 转换证书
print_message $YELLOW "1️⃣  转换证书..."
CERT_FILE="$HOME/Desktop/Distribution_Certificate.p12"

if [ -f "$CERT_FILE" ]; then
    base64 -i "$CERT_FILE" | tr -d '\n' > "$OUTPUT_DIR/cert_base64.txt"
    print_message $GREEN "   ✅ 证书已转换: cert_base64.txt"
else
    print_message $RED "   ❌ 证书文件不存在: $CERT_FILE"
    print_message $YELLOW "   请确保已导出证书到桌面，文件名为 Distribution_Certificate.p12"
fi

echo ""

# 2. 转换 Provisioning Profiles
print_message $YELLOW "2️⃣  转换 Provisioning Profiles..."

# Profile 文件路径（尝试多个可能的位置）
DOWNLOAD_DIR="$HOME/Downloads"
DESKTOP_DIR="$HOME/Desktop"

# Profile 1: 主应用
print_message $BLUE "   Profile 1/5: 主应用..."
for dir in "$DOWNLOAD_DIR" "$DESKTOP_DIR"; do
    if [ -f "$dir/xDrip_Main_AppStore.mobileprovision" ]; then
        base64 -i "$dir/xDrip_Main_AppStore.mobileprovision" | tr -d '\n' > "$OUTPUT_DIR/profile_main.txt"
        print_message $GREEN "   ✅ 主应用 Profile 已转换"
        break
    fi
done

# Profile 2: Widget
print_message $BLUE "   Profile 2/5: Widget..."
for dir in "$DOWNLOAD_DIR" "$DESKTOP_DIR"; do
    if [ -f "$dir/xDrip_Widget_AppStore.mobileprovision" ]; then
        base64 -i "$dir/xDrip_Widget_AppStore.mobileprovision" | tr -d '\n' > "$OUTPUT_DIR/profile_widget.txt"
        print_message $GREEN "   ✅ Widget Profile 已转换"
        break
    fi
done

# Profile 3: Watch App
print_message $BLUE "   Profile 3/5: Watch App..."
for dir in "$DOWNLOAD_DIR" "$DESKTOP_DIR"; do
    if [ -f "$dir/xDrip_WatchApp_AppStore.mobileprovision" ]; then
        base64 -i "$dir/xDrip_WatchApp_AppStore.mobileprovision" | tr -d '\n' > "$OUTPUT_DIR/profile_watch.txt"
        print_message $GREEN "   ✅ Watch App Profile 已转换"
        break
    fi
done

# Profile 4: Watch Complication
print_message $BLUE "   Profile 4/5: Watch Complication..."
for dir in "$DOWNLOAD_DIR" "$DESKTOP_DIR"; do
    if [ -f "$dir/xDrip_WatchComplication_AppStore.mobileprovision" ]; then
        base64 -i "$dir/xDrip_WatchComplication_AppStore.mobileprovision" | tr -d '\n' > "$OUTPUT_DIR/profile_complication.txt"
        print_message $GREEN "   ✅ Watch Complication Profile 已转换"
        break
    fi
done

# Profile 5: Notification
print_message $BLUE "   Profile 5/5: Notification..."
for dir in "$DOWNLOAD_DIR" "$DESKTOP_DIR"; do
    if [ -f "$dir/xDrip_Notification_AppStore.mobileprovision" ]; then
        base64 -i "$dir/xDrip_Notification_AppStore.mobileprovision" | tr -d '\n' > "$OUTPUT_DIR/profile_notification.txt"
        print_message $GREEN "   ✅ Notification Profile 已转换"
        break
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $GREEN "✅ 转换完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 显示结果
print_message $BLUE "📊 生成的文件:"
echo ""
ls -lh "$OUTPUT_DIR"/*.txt 2>/dev/null || print_message $RED "   没有找到任何文件"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message $YELLOW "📋 下一步操作："
echo ""
print_message $YELLOW "1. 访问 GitHub Secrets 设置:"
print_message $YELLOW "   https://github.com/q601180252/xdripios/settings/secrets/actions"
echo ""
print_message $YELLOW "2. 添加以下 7 个 Secrets:"
echo ""
print_message $YELLOW "   Secret 1: IOS_DISTRIBUTION_CERTIFICATE_BASE64"
print_message $YELLOW "   复制命令: cat $OUTPUT_DIR/cert_base64.txt | pbcopy"
echo ""
print_message $YELLOW "   Secret 2: IOS_DISTRIBUTION_CERTIFICATE_PASSWORD"
print_message $YELLOW "   Value: 您设置的证书密码"
echo ""
print_message $YELLOW "   Secret 3: IOS_PROVISIONING_PROFILE_MAIN_BASE64"
print_message $YELLOW "   复制命令: cat $OUTPUT_DIR/profile_main.txt | pbcopy"
echo ""
print_message $YELLOW "   Secret 4: IOS_PROVISIONING_PROFILE_WIDGET_BASE64"
print_message $YELLOW "   复制命令: cat $OUTPUT_DIR/profile_widget.txt | pbcopy"
echo ""
print_message $YELLOW "   Secret 5: IOS_PROVISIONING_PROFILE_WATCH_BASE64"
print_message $YELLOW "   复制命令: cat $OUTPUT_DIR/profile_watch.txt | pbcopy"
echo ""
print_message $YELLOW "   Secret 6: IOS_PROVISIONING_PROFILE_WATCH_COMPLICATION_BASE64"
print_message $YELLOW "   复制命令: cat $OUTPUT_DIR/profile_complication.txt | pbcopy"
echo ""
print_message $YELLOW "   Secret 7: IOS_PROVISIONING_PROFILE_NOTIFICATION_BASE64"
print_message $YELLOW "   复制命令: cat $OUTPUT_DIR/profile_notification.txt | pbcopy"
echo ""
print_message $GREEN "3. 配置完成后告诉我，我会更新 Workflow 文件！"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

