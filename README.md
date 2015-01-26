ansible-dmi
===========

# Running ansible playbooks

Verify if the submodules need to pulled again...
```
    git pull
    git submodule foreach git pull
```

Then run...
```
    ansible-playbook {{ Playbook Name }}
```
Or    
```
    ansible-playbook {{ Playbook Name }} --extra-vars "create=true"
```

Right now the following playbooks exist:
* application-breedfeedlaunch-deploy.yml
* application-kromeo2015-deploy.yml
* create-db-servers.yml
* create-django-servers.yml
* create-sites.yml

### Setting up the hosts for the VPS

* Create your machines on the VPS and remember to enable the _virtual private networking_ feature. If you do this, update your django database settings so to use the VPN IP rather than the public IP. The corresponding IP addresses in `/group_vars/all`.

* Map host name to IP in `/etc/hosts`

        123.123.123.123   dmi-web-droplet
        123.123.123.124   dmi-db-droplet
        123.123.123.125   dmi-worker-droplet

* Setup the mapping in `~/.ssh/config.d/` for `dmi-db-droplet`, `dmi-worker-droplet` and `dmi-web-droplet`. For example,

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
        host dmi-worker-droplet
            User deploy
            Hostname dmi-worker-droplet
            Port 1234
            ForwardAgent = yes
            ForwardX11 no
            IdentityFile /Users/aaron/.ssh/id_rsa
    See information below on securing the SSH connection for information about the port.

* The hosts are set in `/etc/ansible/hosts`. They are currently set as the following...

        [droplets]
        dmi-db-droplet
        dmi-web-droplet
        dmi-worker-droplet
    
        [dbservers]
        dmi-db-droplet
    
        [webservers]
        dmi-web-droplet

        [workerservers]
        dmi-worker-droplet

* This also requires the setting in `/etc/ansible/group_vars/droplets` 

        ---
        ansible_ssh_user: {{ the server's ssh user }}
        ansible_ssh_port: {{ the server's ssh port }}

        rabbitmq_guest_default_pass: {{ the default password for the guest user }}

* And also requires the setting in `/etc/ansible/group_vars/all`
        ---
        newrelic_license: {{ the newrelic license key }}
        
### Project requirements
The current Django project default expects a directory named `serverdeploy` which contains the following files
* gunicorn.conf
* gunicorn_start.bash
* nginx-sites-enabled.conf
* vars.secure

If further customization is required (as in the case of the `kromeo2015` deploy), this can be added as a submodule.
```
> cd playbooks/roles
> git submodule add https://github.com/{{ repo_name }}.git {{ project_name }}
```

Remember to use `git submodule status` to verify the submodule's status.

Add a new application playbook named `application-{{ project_name }}-deploy.yml`
```
    ---
    - name: Deploy {{ project_name }}
      hosts: webservers
      remote_user: deploy
      roles:
        - django
```

If this is a further customized project, modify this new playbook to include {{ project_name }}.
```
    ---
    - name: Deploy {{ project_name }}
      hosts: webservers
      remote_user: deploy
      roles:
        - {{ project_name }}
```

Then add the application name in `create-django-servers.yml`.

This project also uses [git-crypt](https://www.agwa.name/projects/git-crypt/) and Dropbox to secure the `vars.secure` file. A example of how this would be used is...
```
> git-crypt init
> git-crypt export-key ~/Dropbox/git-crypt/{{ project_name }}
```
The keys are then sourced via the ansible script for an scp styled copy.

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
