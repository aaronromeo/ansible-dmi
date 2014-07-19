ansible-dmi
===========

# Running ansible playbooks

ansible-playbook {{ Playbook Name }}

# A few useful things to do when creating a server...

### Update the default editor so we aren't living in squalor
```
> sudo update-alternatives --config editor
```

### Update the `root` password and add the `hotstuff` user
```
> passwd
> adduser hotstuff
> visudo
```
Then add the line
```
# User privilege specification
root    ALL=(ALL:ALL) ALL
hotstuff  ALL=(ALL:ALL) NOPASSWD: ALL
```

### Secure the SSH shell from bastards
```
> vi /etc/ssh/sshd_config
```
Update the lines in this file like so...
```
Port 1234 # A random number between 1025 and 65536
...
PermitRootLogin no
...
AllowUsers hotstuff # You'll probably need to add this line
```


### To copy over the SSH key (this is done from the local machine)
```
ssh-copy-id hotstuff@{server-name}
```
