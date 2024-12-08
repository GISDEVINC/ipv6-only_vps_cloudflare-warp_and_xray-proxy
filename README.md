# ipv6-only_vps_cloudflare-warp_and_xray-proxy
### ENG
Your IPv6 only VPS will derive IPv4/IPv6 dual-stack networking and Xray-based proxy.

The script help you automatically install CloudFlare-Warp and Xray from official sources. And the relative services will be started.

Please note that the script only supports Ubuntu. Moreover, I only test it on Ubuntu 22.04.

And if you place the problem like "How to access Github without IPv6", you will be recommended to download it and then upload it to your IPv6-only VPS via SFTP/FTP. 

Furthermore, warp service will listen on port: 40000 by default, used as the outbound target for the Xray service. And you can also refer to the official Xray documentation for guidance on manually modifying its inbound configuration. 



### 中文
一键脚本，为只有IPv6的VPS安装cloudflare-warp和xray，实现双栈网络与代理。

脚本内软件源均指向官方源，执行完成后cloudflare-warp和xray均会启动。

请注意，本脚本仅支持Ubuntu。进一步来说，只在Ubuntu 22.04完成了测试。

可通过SFTP/FTP将此脚本上传至IPv6-only VPS，再进一步执行。

此外，warp服务默认监听40000端口，Xray服务出站将指向该端口。安装完成后，可以参考Xray官方文档手动更改Xray的入站配置。
