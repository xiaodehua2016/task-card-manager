// 部署设置脚本
// 运行此脚本来快速配置Supabase连接

const fs = require('fs');
const path = require('path');

class DeploymentSetup {
    constructor() {
        this.configPath = path.join(__dirname, 'config', 'supabase.js');
        this.examplePath = path.join(__dirname, 'config', 'supabase.example.js');
    }

    // 创建配置文件
    createConfig(supabaseUrl, supabaseKey) {
        const configContent = `// Supabase配置文件
// 此文件包含敏感信息，不应提交到版本控制

window.SUPABASE_CONFIG = {
    url: '${supabaseUrl}',
    anonKey: '${supabaseKey}',
    
    options: {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: true
        }
    }
};

console.log('Supabase配置已加载');
`;

        // 确保config目录存在
        const configDir = path.dirname(this.configPath);
        if (!fs.existsSync(configDir)) {
            fs.mkdirSync(configDir, { recursive: true });
        }

        // 写入配置文件
        fs.writeFileSync(this.configPath, configContent, 'utf8');
        console.log('✅ Supabase配置文件已创建:', this.configPath);
    }

    // 检查配置文件是否存在
    checkConfig() {
        return fs.existsSync(this.configPath);
    }

    // 验证配置
    validateConfig() {
        if (!this.checkConfig()) {
            console.log('❌ 配置文件不存在，请先创建配置文件');
            return false;
        }

        try {
            const configContent = fs.readFileSync(this.configPath, 'utf8');
            if (configContent.includes('your-project-id') || configContent.includes('your-anon-key')) {
                console.log('❌ 请更新配置文件中的实际Supabase信息');
                return false;
            }
            
            console.log('✅ 配置文件验证通过');
            return true;
        } catch (error) {
            console.log('❌ 配置文件读取失败:', error.message);
            return false;
        }
    }

    // 更新gitignore
    updateGitignore() {
        const gitignorePath = path.join(__dirname, '.gitignore');
        const ignoreContent = `
# Supabase配置文件（包含敏感信息）
config/supabase.js

# 日志文件
*.log
npm-debug.log*

# 依赖目录
node_modules/

# 操作系统文件
.DS_Store
Thumbs.db

# 编辑器文件
.vscode/
.idea/
*.swp
*.swo

# 临时文件
*.tmp
*.temp
`;

        fs.writeFileSync(gitignorePath, ignoreContent.trim(), 'utf8');
        console.log('✅ .gitignore文件已更新');
    }

    // 显示部署指南
    showDeploymentGuide() {
        console.log(`
🚀 GitHub + Supabase 部署指南

1. 创建Supabase项目:
   - 访问 https://supabase.com
   - 创建新项目
   - 执行SQL创建数据表（见DEPLOYMENT.md）

2. 配置项目:
   - 复制你的Supabase URL和API Key
   - 运行: node deploy-setup.js setup <URL> <KEY>

3. 部署到GitHub Pages:
   - 推送代码到GitHub
   - 启用GitHub Pages
   - 选择GitHub Actions作为源

4. 验证部署:
   - 访问你的GitHub Pages URL
   - 测试多设备同步功能

详细说明请查看 DEPLOYMENT.md 文件
        `);
    }
}

// 命令行接口
if (require.main === module) {
    const setup = new DeploymentSetup();
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        setup.showDeploymentGuide();
    } else if (args[0] === 'setup' && args.length === 3) {
        const [, supabaseUrl, supabaseKey] = args;
        setup.createConfig(supabaseUrl, supabaseKey);
        setup.updateGitignore();
        console.log('✅ 部署设置完成！');
    } else if (args[0] === 'check') {
        setup.validateConfig();
    } else {
        console.log(`
使用方法:
  node deploy-setup.js                    # 显示部署指南
  node deploy-setup.js setup <URL> <KEY> # 创建配置文件
  node deploy-setup.js check             # 验证配置文件
        `);
    }
}

module.exports = DeploymentSetup;