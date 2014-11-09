ansible-dmi
===========

# Running ansible playbooks

`ansible-playbook _{Playbook Name}_`

Right now the following playbooks exist:
* application-breedfeedlaunch-create.yml
* application-breedfeedlaunch-deploy.yml
* create-db-servers.yml
* create-django-servers.yml
* create-sites.yml

### Setting up the hosts for the VPS

* Create your machines on the VPS and remember to enable the _virtual private networking_ feature. If you do this, update your django database settings so to use the VPN IP rather than the public IP. The corresponding IP addresses in `/group_vars/all`.

* Map host name to IP in `/etc/hosts`

        123.123.123.123   dmi-web-droplet
        123.123.123.124   dmi-db-droplet

* Setup the mapping in `~/.ssh/config.d/` for `dmi-db-droplet` and `dmi-web-droplet`. For example,

        host dmi-db-droplet
            User deploy
            Hostname dmi-db-droplet
            Port 1234
            ForwardAgent = yes
            ForwardX11 no
            IdentityFile /Users/aaron/.ssh/id_rsa
        host dmi-web-droplet
            User deploy
            Hostname dmi-web-droplet
            Port 1234
            ForwardAgent = yes
            ForwardX11 no
            IdentityFile /Users/aaron/.ssh/id_rsa
    See information below on securing the SSH connection for information about the port.

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
        
* New projects can be added to the file `/group_vars/all` under the variable `projects`

### Project requirements
Django projects are expected to have a directory named `serverdeploy` which contains the following files
* gunicorn.conf
* gunicorn_start.bash
* nginx-sites-enabled.conf
* vars.secure

# A few useful things to do when creating a server...

### Update the default editor so we aren't living in squalor
```
> sudo update-alternatives --config editor
```

### Update the `root` password and add the user configured with ssh. In this example, the `hotstuff` user is added
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
