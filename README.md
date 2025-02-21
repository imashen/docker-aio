# Language
- ENG [English](README.md)
- CHS [简体中文](/README_CHS.md)

# Instructions
This accelerated mirror service is not available for users in Asia. Please check and comply with local laws and regulations.
When using this service, ensure you comply with relevant laws and regulations. If your rights have been infringed upon, please contact [Azimiao](https://github.com/Azimiao) | [imashen](https://github.com/imashen) for resolution.

## Installation Script Usage

```bash
curl -fsSL https://docker.13140521.xyz/install | bash -s docker --mirror Aliyun

Options:

```text
--channel <stable|test>
--version <VERSION>
--mirror <Aliyun|AzureChinaCloud>
```

## Docker Accelerator Mirror Usage

> Please note that before using any accelerated mirrors, ensure that the acceleration service meets your needs and that you comply with relevant terms of use and service agreements.

Accelerated domain: *.13140521.xyz

## ⚠️USE docker.hutu.im insted of docker.13140521.xyz!!! 2025.02.22

Below are some common Docker mirror sources and their corresponding accelerated domains:

| Source Domain            | Accelerated Domain                   |
|-------------------|--------------------------|
| quay.io           | quay.13140521.xyz        |
| gcr.io            | gcr.13140521.xyz         |
| ghcr.io           | ghcr.13140521.xyz        |
| k8s.gcr.io        | k8s-gcr.13140521.xyz     |
| registry.k8s.io   | k8s.13140521.xyz         |
| docker.cloudsmith.io | cloudsmith.13140521.xyz |
| mcr.microsoft.com | mcr.13140521.xyz         |
| docker.elastic.co | elastic.13140521.xyz    |

When using an accelerated mirror, replace the original domain in your Docker configuration with the corresponding accelerated domain from the table above. For example, if you want to use the accelerated mirror for quay.io, replace all references to quay.io with quay.13140521.xyz.


---

### Example Methods for Replacing Mirror Sources
#### Method 1: Modify Docker Configuration File

> Note: In some versions, the configuration file is not named `daemon.json` but rather `daemon.conf`. Please adjust according to the actual version!
> If you do not make the necessary changes, you may face the following error:
> ```
> Job for docker.service failed because the control process exited with error code.
> See "systemctl status docker.service" and "journalctl -xeu docker.service" for details.
> ```

1.Edit the Docker configuration file:   
Open the Docker configuration file (usually located at /etc/docker/daemon.json):
```bash
sudo nano /etc/docker/daemon.json
```
2.Add or modify the mirror source:   
Add or modify the registry-mirrors field in the configuration file:
```json
{
  "registry-mirrors": [
    "https://docker.13140521.xyz"
  ]
}
```
3.Restart the Docker service:   
Save the configuration file and restart the Docker service:
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```
#### Method 2: Replace Using Docker CLI Commands
Specify the mirror source when pulling/viewing images:  
For example, specify the accelerated source when pulling an image from quay.io:
```bash
docker pull quay.13140521.xyz/library/image_name:tag
```
For example, specify the accelerated source when inspecting an image from quay.io:
```bash
docker inspect quay.13140521.xyz/library/image_name:tag
```
