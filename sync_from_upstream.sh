#!/bin/bash

# GitHub Repository Sync Script
# 用于同步上游仓库 (JohanDegraeve/xdripswift) 的更新到本地仓库

set -e  # 遇到错误时立即退出

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GitHub Repository Sync Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查是否在git仓库中
if [ ! -d .git ]; then
    echo -e "${RED}错误: 当前目录不是git仓库${NC}"
    exit 1
fi

# 显示当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}当前分支:${NC} ${CURRENT_BRANCH}"

# 检查工作目录是否干净
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}警告: 工作目录有未提交的更改${NC}"
    echo -e "${YELLOW}未提交的文件:${NC}"
    git status --short
    echo ""
    read -p "是否要继续同步? (可能会导致合并冲突) [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}同步已取消${NC}"
        exit 1
    fi
fi

# 检查并配置upstream远程仓库
echo -e "${BLUE}检查upstream远程仓库配置...${NC}"
if ! git remote | grep -q "^upstream$"; then
    echo -e "${YELLOW}未找到upstream远程仓库，正在添加...${NC}"
    git remote add upstream https://github.com/JohanDegraeve/xdripswift.git
    echo -e "${GREEN}已添加upstream: https://github.com/JohanDegraeve/xdripswift.git${NC}"
else
    echo -e "${GREEN}upstream远程仓库已配置${NC}"
fi

# 显示远程仓库
echo ""
echo -e "${BLUE}远程仓库配置:${NC}"
git remote -v | grep -E "(origin|upstream)"
echo ""

# 从upstream获取最新更新
echo -e "${BLUE}从upstream获取最新更新...${NC}"
git fetch upstream

# 可选：指定要同步的分支，默认为master
UPSTREAM_BRANCH=${1:-master}
echo -e "${BLUE}准备合并 upstream/${UPSTREAM_BRANCH} 到当前分支 ${CURRENT_BRANCH}${NC}"
echo ""

# 合并upstream的更新
echo -e "${BLUE}合并upstream更新...${NC}"
if git merge upstream/${UPSTREAM_BRANCH} --no-edit; then
    echo -e "${GREEN}✓ 合并成功${NC}"
else
    echo -e "${RED}✗ 合并出现冲突，请手动解决冲突后继续${NC}"
    echo -e "${YELLOW}解决冲突后执行:${NC}"
    echo -e "  git add ."
    echo -e "  git commit"
    echo -e "  git push origin ${CURRENT_BRANCH}"
    exit 1
fi

# 更新子模块
if [ -f .gitmodules ]; then
    echo ""
    echo -e "${BLUE}更新子模块...${NC}"
    git submodule update --init --recursive
    echo -e "${GREEN}✓ 子模块更新完成${NC}"
fi

# 询问是否推送到origin
echo ""
read -p "是否推送到origin远程仓库? [Y/n]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}跳过推送，本地同步完成${NC}"
else
    echo -e "${BLUE}推送到origin/${CURRENT_BRANCH}...${NC}"
    git push origin ${CURRENT_BRANCH}
    echo -e "${GREEN}✓ 推送成功${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  同步完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}同步摘要:${NC}"
echo -e "  上游分支: upstream/${UPSTREAM_BRANCH}"
echo -e "  当前分支: ${CURRENT_BRANCH}"
echo -e "  最新提交: $(git log -1 --oneline)"
