# How To Install
`curl -fsSL https://cdn.jsdelivr.net/gh/imashen/docker-autoinstall/docker | bash -s docker`

or

`curl -fsSL https://fastly.jsdelivr.net/gh/imashen/docker-autoinstall/docker | bash -s docker`

### Powered by `Aliyun`

另附自建Docker加速源 `docker.13140521.xyz`

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
