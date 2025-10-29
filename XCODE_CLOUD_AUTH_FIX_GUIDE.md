# Xcode Cloud API 401认证错误修复指南

## 问题诊断结果
通过诊断脚本发现：
- ❌ **Xcode中没有配置开发者账号**
- ⚠️  Xcode Cloud配置缺失
- ✅ 网络连接正常

## 解决步骤

### 第一步：添加开发者账号到Xcode
1. **打开Xcode**
2. **进入偏好设置**
   - 菜单栏：Xcode → Preferences
3. **选择Accounts标签**
   - 在Preferences窗口中点击"Accounts"
4. **添加开发者账号**
   - 点击左下角的"+"按钮
   - 选择"Apple ID"
   - 输入您的开发者账号凭据
   - 确保显示"Xcode Cloud"权限

### 第二步：验证Xcode Cloud权限
1. **访问App Store Connect**
   - 打开浏览器访问：https://appstoreconnect.apple.com
   - 使用开发者账号登录
2. **检查用户权限**
   - 点击右上角的用户图标
   - 选择"用户和访问"
   - 确保您的账号有以下权限：
     - **Admin** 或 **App Manager** 角色
     - **Xcode Cloud** 访问权限

### 第三步：清理Xcode缓存
```bash
# 清理Xcode Cloud缓存
rm -rf ~/Library/Caches/com.apple.dt.XcodeCloud

# 清理Xcode派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData

# 重启Xcode
killall Xcode
```

### 第四步：重新配置Xcode Cloud
1. **重启Xcode**
2. **重新尝试Xcode Cloud设置**
3. **确保在授权时选择正确的开发者账号**

## 验证步骤
完成上述步骤后，运行诊断脚本验证：
```bash
./fix_xcode_cloud_auth.sh
```

应该看到：
- ✅ Developer accounts found
- ✅ Xcode Cloud configuration exists

## 如果问题仍然存在

### 高级故障排除

#### 1. 检查Apple Developer账号状态
- 访问：https://developer.apple.com/account
- 确保账号状态正常（没有过期或暂停）
- 检查开发者协议是否已接受

#### 2. 重置Xcode配置
```bash
# 备份当前配置（可选）
cp ~/Library/Preferences/com.apple.dt.Xcode.plist ~/Desktop/

# 重置Xcode偏好设置
rm ~/Library/Preferences/com.apple.dt.Xcode.plist

# 重启Xcode
killall Xcode
```

#### 3. 检查系统时间
```bash
# 检查系统时间
date

# 如果时间不正确，手动设置
sudo systemsetup -setdate "$(date)"
sudo systemsetup -settimezone Asia/Shanghai
```

#### 4. 网络连接检查
```bash
# 测试Apple服务连接
curl -I https://api.apple-cloudkit.com
curl -I https://appstoreconnect.apple.com
```

#### 5. 防火墙和安全软件
- 暂时禁用防火墙
- 关闭VPN连接
- 检查是否有安全软件阻止Xcode网络访问

## 联系支持
如果以上步骤都无法解决问题：

1. **Apple Developer支持**
   - 访问：https://developer.apple.com/support/
   - 提交支持请求，说明Xcode Cloud 401错误

2. **检查Apple系统状态**
   - 访问：https://developer.apple.com/system-status/
   - 确认所有Apple Developer服务正常运行

## 常见错误代码
- **401 Unauthorized**: 认证失败，通常是账号权限问题
- **403 Forbidden**: 权限不足，需要Admin或App Manager角色
- **404 Not Found**: 服务不可用，检查Apple系统状态
- **500 Internal Server Error**: Apple服务器问题，稍后重试

## 快速检查清单
- [ ] Xcode中已添加开发者账号
- [ ] 开发者账号有Xcode Cloud权限
- [ ] App Store Connect中账号角色正确
- [ ] 网络连接正常
- [ ] 系统时间正确
- [ ] 没有VPN或代理干扰
- [ ] Xcode缓存已清理

完成这些步骤后，Xcode Cloud API 401错误应该就能解决了。