ansible-dmi
===========

# Running ansible playbooks

ansible-playbook {{ Playbook Name }}

The two ones here are `db-server.yml` and `web-server.yml`.

### Setting up the hosts for Digital Ocean

* Setup the mapping in `~/.ssh/config.d/` for `dmi-db-droplet` and `dmi-web-droplet`.

* The hosts are set in `/etc/ansible/hosts`. They are currently set as the following...

        [droplets]
        dmi-db-droplet
        dmi-web-droplet
    
        [dbservers]
        dmi-db-droplet
    
        [webservers]
        dmi-web-droplet

* This also requires the setting in `/etc/ansible/group_vars/droplets` 

        ---
        ansible_ssh_user: {{ the server's ssh user }}
        

* New projects can be added to the file `roles/common/vars/main.yml` under the variable `projects`

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
