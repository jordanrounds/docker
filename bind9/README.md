[ubuntu/bind9](https://hub.docker.com/r/ubuntu/bind9)

edit
```bash
/etc/systemd/resolved.conf
```

change
```bash
DNSStubListener=no
```
*make sure to remove the # so its not commented out*

```bash
sudo systemctl restart systemd-resolved
```

