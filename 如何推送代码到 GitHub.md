# 如何推送代码到 GitHub 🚀

## 📊 当前状态

您有 **10+ 个本地 commits** 需要推送到 GitHub，包括：
- Team ID 切换到 Yang Li (HHZN32E89C)
- 所有 Bundle ID 前缀更新
- GitHub Actions workflows 更新
- 工具脚本和文档

---

## ✅ 推荐方式：使用 GitHub Desktop

### 步骤 1: 打开 GitHub Desktop
```
应用程序 → GitHub Desktop
```

### 步骤 2: 选择仓库
```
左上角 → Current Repository → xdripios
```

### 步骤 3: 查看 Changes
```
左侧栏应该显示:
  • 10+ commits ready to push
  • 或者显示具体的文件更改
```

### 步骤 4: Push
```
点击右上角 "Push origin" 按钮
或者: Repository → Push (⌘P)
```

### 步骤 5: 等待完成
```
底部状态栏会显示推送进度
完成后会显示 "Pushed successfully"
```

---

## 备选方式 1: 使用命令行（HTTPS）

### 如果您有 GitHub Personal Access Token

```bash
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios
git push origin main
```

**如果提示输入用户名和密码**:
- **Username**: 您的 GitHub 用户名（例如: q601180252）
- **Password**: Personal Access Token（**不是您的 GitHub 密码！**）

### 如何创建 Personal Access Token

1. **访问 GitHub Settings**
   ```
   https://github.com/settings/tokens
   ```

2. **创建新 Token**
   ```
   点击 "Generate new token (classic)"
   ```

3. **配置 Token**
   ```
   Note: xdrip-push-access
   Expiration: 90 days（或选择其他期限）
   
   Select scopes:
     ✅ repo (完整权限)
        ✅ repo:status
        ✅ repo_deployment
        ✅ public_repo
        ✅ repo:invite
        ✅ security_events
   ```

4. **生成并复制**
   ```
   点击 "Generate token"
   复制生成的 token（类似: ghp_xxxxxxxxxxxxxxxxxxxx）
   ⚠️  这个 token 只显示一次，请妥善保存！
   ```

5. **使用 Token**
   ```bash
   git push origin main
   Username: q601180252
   Password: <粘贴您的 token>
   ```

### 保存凭据（可选）

避免每次都输入：
```bash
git config --global credential.helper osxkeychain
```

下次推送时输入一次 token，macOS 会自动保存到钥匙串。

---

## 备选方式 2: 使用 SSH

### 前提：已配置 SSH Key

如果您还没有配置 SSH Key，先创建：

```bash
# 1. 生成 SSH Key
ssh-keygen -t ed25519 -C "your_email@example.com"
# 按回车使用默认路径，设置密码（可选）

# 2. 添加到 ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 3. 复制公钥
cat ~/.ssh/id_ed25519.pub
# 复制输出的内容

# 4. 添加到 GitHub
# 访问: https://github.com/settings/keys
# 点击 "New SSH key"
# 粘贴公钥内容
# 点击 "Add SSH key"
```

### 使用 SSH 推送

```bash
# 1. 修改 remote URL 为 SSH
cd /Users/liyang/Documents/work/wunew/ios/loopcloud2/xdripios
git remote set-url origin git@github.com:q601180252/xdripios.git

# 2. 推送
git push origin main
```

---

## ⚠️ 推送后的下一步

### 1. 验证推送成功

访问 GitHub 仓库：
```
https://github.com/q601180252/xdripios
```

检查：
- ✅ 最新 commit 是否已显示
- ✅ Workflow 文件是否已更新

### 2. 配置 Provisioning Profiles（必需）

GitHub Actions 需要 Provisioning Profiles 才能构建 IPA。

您需要：
1. 在 Apple Developer Portal 创建 **5 个 App Store Provisioning Profiles**
2. 下载 Profiles
3. 导出为 base64 编码
4. 添加到 GitHub Secrets

**详细步骤见**:
- `如何创建 Provisioning Profiles 详细教程.md`
- `GitHub Actions 构建失败解决方案.md`

### 3. 更新 GitHub Secrets

可能需要更新的 Secrets（如果使用新的 Apple ID）:
- `APPSTORE_API_KEY_ID`
- `APPSTORE_ISSUER_ID`
- `APPSTORE_API_PRIVATE_KEY`

---

## 🎯 快速检查清单

推送前：
- [ ] 所有更改已 commit
- [ ] 确认 commit 历史正确（git log --oneline -10）

推送时：
- [ ] 选择一种推送方式（GitHub Desktop 最简单）
- [ ] 如果使用命令行，确保有正确的凭据

推送后：
- [ ] 在 GitHub 网站上验证更改
- [ ] 检查 workflow 文件是否正确更新
- [ ] 准备配置 Provisioning Profiles

---

## 💡 推荐的推送方式

**如果您已经安装了 GitHub Desktop**:
→ 使用 GitHub Desktop（最简单，图形界面，点击即可）

**如果没有 GitHub Desktop**:
→ 使用命令行 + Personal Access Token

**如果经常使用命令行**:
→ 配置 SSH Key（一次配置，终身受益）

---

## 📞 遇到问题？

### 问题 1: "Permission denied (publickey)"
**解决**: SSH Key 未配置或未添加到 GitHub
- 查看上面的 "使用 SSH" 部分
- 或者改用 HTTPS 方式

### 问题 2: "Authentication failed"
**解决**: 密码错误
- **不要使用 GitHub 密码！**
- 必须使用 Personal Access Token

### 问题 3: "Repository not found"
**解决**: Remote URL 配置错误
```bash
git remote -v
# 应该显示: https://github.com/q601180252/xdripios.git
```

---

**现在请推送代码到 GitHub！** 🚀

推送完成后告诉我，我会帮您完成 Provisioning Profiles 配置！

