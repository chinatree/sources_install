## Release Notes

### 2020-04-18

#### New Features

- 新增编译 go
- 新增编译 openssl
- 新增编译 openresty
- 新增编译 squid
- 新增编译 luarocks
- 新增编译 kong

#### Changes

- [Servers] python 版本更新至 3.6.10
- [Servers] nginx 版本更新至 1.16.1，默认开启 HTTP2 编译参数
- [Servers] redis 版本更新至 5.0.8
- [Libraries] pcre 版本更新至 8.44
- make 参数默认开启支持多核参数
- 语法优化

### 2018-08-01

#### New Features

- [√] 支持 LNMP、LAMP、Python、Nodejs、JDK等
- [√] 支持在线下载源码包 toolchains/auto_download.sh
- [√] 支持初始化配置 toolchains/auto_config.sh
- [√] 支持按版本创建软链 toolchains/auto_softchain.sh
