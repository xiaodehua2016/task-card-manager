#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo "   小久的任务卡片管理系统 - 配置工具"
echo "========================================"
echo

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ 未检测到Node.js环境${NC}"
    echo
    echo "请选择配置方式："
    echo "1. 安装Node.js后使用自动配置（推荐）"
    echo "2. 手动配置（无需Node.js）"
    echo
    read -p "请输入选择 (1 或 2): " choice
    
    case $choice in
        1)
            echo
            echo -e "${BLUE}📥 请按照以下步骤安装Node.js：${NC}"
            echo
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo "macOS系统："
                echo "1. 访问 https://nodejs.org/zh-cn/"
                echo "2. 下载并安装LTS版本"
                echo "或使用Homebrew: brew install node"
            else
                echo "Linux系统："
                echo "Ubuntu/Debian: sudo apt install nodejs npm"
                echo "CentOS/RHEL: sudo yum install nodejs npm"
                echo "或访问 https://nodejs.org/zh-cn/ 下载"
            fi
            echo
            echo "安装完成后请重新运行此脚本"
            exit 0
            ;;
        2)
            manual_setup
            exit 0
            ;;
        *)
            echo -e "${RED}无效选择，退出程序${NC}"
            exit 1
            ;;
    esac
fi

echo -e "${GREEN}✅ 检测到Node.js环境${NC}"
node --version
echo

# 检查配置文件是否存在
if [ -f "config/supabase.js" ]; then
    echo -e "${YELLOW}⚠️  配置文件已存在${NC}"
    read -p "是否覆盖现有配置？(y/n): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "配置已取消"
        exit 0
    fi
fi

echo
echo -e "${BLUE}📋 请输入Supabase配置信息：${NC}"
echo
read -p "Supabase项目URL (https://xxx.supabase.co): " supabase_url
read -p "Supabase API密钥: " supabase_key

if [ -z "$supabase_url" ]; then
    echo -e "${RED}❌ URL不能为空${NC}"
    exit 1
fi

if [ -z "$supabase_key" ]; then
    echo -e "${RED}❌ API密钥不能为空${NC}"
    exit 1
fi

echo
echo -e "${BLUE}🔧 正在配置项目...${NC}"
node deploy-setup.js setup "$supabase_url" "$supabase_key"

if [ $? -eq 0 ]; then
    echo
    echo -e "${GREEN}✅ 配置完成！${NC}"
    echo
    echo -e "${BLUE}📱 测试步骤：${NC}"
    echo "1. 运行: npx serve . -p 8000"
    echo "2. 浏览器访问: http://localhost:8000"
    echo "3. 在不同设备上测试数据同步"
    echo
else
    echo -e "${RED}❌ 配置失败，请检查输入信息${NC}"
    exit 1
fi

show_help
exit 0

manual_setup() {
    echo
    echo -e "${BLUE}📝 手动配置步骤：${NC}"
    echo
    echo "1. 复制配置文件模板"
    mkdir -p config
    cp config/supabase.example.js config/supabase.js 2>/dev/null || {
        echo -e "${RED}❌ 配置文件模板不存在${NC}"
        exit 1
    }
    
    echo "2. 请手动编辑 config/supabase.js 文件"
    echo "   - 将 'your-project-id' 替换为您的项目ID"
    echo "   - 将 'your-anon-key-here' 替换为您的API密钥"
    echo
    echo "3. 编辑完成后，在浏览器中打开 index.html 即可使用"
    echo
    
    read -p "是否现在打开配置文件进行编辑？(y/n): " open_config
    if [[ "$open_config" =~ ^[Yy]$ ]]; then
        if command -v code &> /dev/null; then
            code config/supabase.js
        elif command -v nano &> /dev/null; then
            nano config/supabase.js
        elif command -v vim &> /dev/null; then
            vim config/supabase.js
        else
            echo "请使用您喜欢的文本编辑器打开 config/supabase.js"
        fi
    fi
    
    show_help
}

show_help() {
    echo
    echo -e "${BLUE}📚 更多帮助：${NC}"
    echo "- 快速开始: QUICK_START.md"
    echo "- Node.js安装: NODE_SETUP.md"
    echo "- 故障排除: TROUBLESHOOTING.md"
    echo
}