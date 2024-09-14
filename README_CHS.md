# 语言
- ENG [English](README.md)
- CHS [简体中文](/README_CHS.md)

# 说明
本加速镜像不对亚洲用户开放服务，请查询并遵守当地的法律法规
使用时请遵守相应的法律法规。如果侵犯到您的权益，请联系 [Azimiao](https://github.com/Azimiao) | [imashen](https://github.com/imashen) 进行处理  

## 安装脚本使用

```bash
curl -fsSL https://docker.13140521.xyz/install | bash -s docker --mirror Aliyun
```

可选参数:

```text
--channel <stable|test>
--version <VERSION>
--mirror <Aliyun|AzureChinaCloud>
```

## Docker加速源使用

> 请注意，在使用任何加速镜像之前，请确保该加速服务符合您的使用需求，并且遵守相关的使用条款和服务协议

加速源域名: `*.13140521.xyz`

以下是一些常见的Docker镜像源及其对应的加速域名：

| 源站域名            | 加速域名                   |
|-------------------|--------------------------|
| quay.io           | quay.13140521.xyz        |
| gcr.io            | gcr.13140521.xyz         |
| ghcr.io           | ghcr.13140521.xyz        |
| k8s.gcr.io        | k8s-gcr.13140521.xyz     |
| registry.k8s.io   | k8s.13140521.xyz         |
| docker.cloudsmith.io | cloudsmith.13140521.xyz |
| mcr.microsoft.com | mcr.13140521.xyz         |
| docker.elastic.co | elastic.13140521.xyz    |

使用加速源时，请将上述表中的加速域名替换到您的Docker配置中。例如，如果您想使用`quay.io`的加速镜像，您应当将所有的`quay.io`引用替换为`quay.13140521.xyz`


---

### 替换镜像源的方法示例
#### 方法一：修改Docker配置文件

> 请注意，一些版本中并非名为`daemon.json`，而是`daemon.conf`，请根据实际版本进行改动！
> 如果您没有改为正确的文件格式将遇到如下错误：
> ```
> Job for docker.service failed because the control process exited with error code.
> See "systemctl status docker.service" and "journalctl -xeu docker.service" for details.
> ```

1.编辑Docker配置文件：
打开Docker的配置文件（通常位于/etc/docker/daemon.json）：
```bash
sudo nano /etc/docker/daemon.json
```
2.添加或修改镜像源：
添加或修改配置文件中的registry-mirrors字段：
```json
{
  "registry-mirrors": [
    "https://docker.13140521.xyz"
  ]
}
```
3.重启Docker服务:
保存配置文件并重启Docker服务：
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```
#### 方法二：使用Docker CLI命令时替换
拉取/查看镜像时指定镜像源：
例如，拉取quay.io上的镜像时指定加速源：
```bash
docker pull quay.13140521.xyz/library/image_name:tag
```
例如，查看quay.io上的镜像信息时指定加速源：
```bash
docker inspect quay.13140521.xyz/library/image_name:tag
```
