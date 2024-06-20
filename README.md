# 说明
本脚本完全为官方脚本，进当作加速用途，无后门</br>
可直接访问 https://docker.13140521.xyz/install 查看脚本内容
# How To Install | 如何使用
`curl -fsSL https://docker.13140521.xyz/install | bash -s docker --mirror Aliyun`

可选参数
```
--channel <stable|test>
--version <VERSION>
--mirror <Aliyun|AzureChinaCloud>
```


## Docker加速源 
`docker.13140521.xyz`

可通过创建docker daemon.json的方式更改加速源

```
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["docker.13140521.xyz"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```
