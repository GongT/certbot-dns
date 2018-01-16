# certbot-dns

调用certbot，获取证书    
主要用于天朝的特殊网络环境（不能用80和443）

条件：
* 自建dns服务器（bind），国内外、本机都可以（本机还要保证53端口可以访问）
* 如果是远程服务器，可以免密码登录ssh（rsa key）

### 依赖

这些脚本依赖新版的`bash`和`expect`

### 用法：
1. 复制 config-example.sh → config.sh
1. 编辑config.sh，详见注释

```bash
./certbot-dns [-d] [-f /path/to/config] sub-domain
```
将获取 sub-domain.`BASE_DOMAIN` 的证书    
用`-d`连接测试服务
