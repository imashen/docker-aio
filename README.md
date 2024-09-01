# 说明
本脚本为官方脚本，仅作加速用途，无后门。</br>
可直接访问 https://docker.13140521.xyz/install 查看脚本内容。</br>
使用时请遵守相应的法律法规。如果侵犯到您的权益，请联系仓库所有者进行删除。

## How To Install Docker | 如何安装 Docker
`curl -fsSL https://docker.13140521.xyz/install | bash -s docker --mirror Aliyun`

可选参数
```
--channel <stable|test>
--version <VERSION>
--mirror <Aliyun|AzureChinaCloud>
```


## DockerHub加速源 
`docker.13140521.xyz`

## 加速源使用方法
<details>
<summary>🐧Ubuntu/Debian/CentOS系列</summary>
  
### 如果您正在使用Linux系统如 Ubuntu/Debian/CentOS系列 可通过如下步骤进行替换更改：
通过创建docker-daemon.json的方式更改加速源

```
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://docker.13140521.xyz"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```
<br />
</details>


<details>
<summary>🗄群晖 DSM</summary>

### 如果您正在使用群晖 DSM，可通过如下步骤进行替换更改：

**1.打开 Docker 套件：**
在主菜单中找到并打开 Docker 套件。

**2.访问注册表设置：**
打开 Docker 套件后，点击左侧的 注册表 标签。

**3.添加新的镜像源：**

在 注册表 页面中，点击右上角的 设置 按钮。

在弹出的窗口中，选择 镜像 标签。

在 镜像 标签下，点击 添加 按钮，输入新的镜像源 URL：`http://docker.13140521.xyz`

**4.设置默认镜像源：**
在镜像源列表中，找到刚刚添加的镜像源，点击其右侧的 三点 按钮，选择 设为默认。

<br />
</details>
