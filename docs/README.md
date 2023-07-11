# Deploy The Device Edge Demo Via Ansible Navigator

## Prerequisites
* Fork this repository to your own GitHub account
* Copy ssh key to bastion host using the link - [How to use GitHub Action to Run SSH Commands](https://medium.com/@tcij1013/how-to-use-github-action-to-run-ssh-commands-609df2a88ac3)
* Update the bastion host to use ansible navigator 

## Getting Started
**ssh into bastion host**
```
ssh user@example.com
```

### One-time | Installing oc
```
curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/pre-steps/configure-openshift-packages.sh
chmod +x configure-openshift-packages.sh
./configure-openshift-packages.sh -i
```

**Install the following packages** 
```
$ sudo dnf install git vim unzip wget bind-utils python3-pip tar util-linux-user  gcc python3-devel podman make  -y
```

**Git Clone Repo** *if pipeline was not ran*
```
git clone https://github.com/tosin2013/device-edge-demos.git
cd $HOME/device-edge-demos/
```

**Create Inventory**
```
export INVENTORY=vmc # on demo.redhat.com $GUID
cd $HOME/device-edge-demos
mkdir -p inventories/${INVENTORY}/group_vars
mkdir -p inventories/${INVENTORY}/group_vars/sno_clusters
cp demos/rhde-pipeline/playbooks/vars/controller-configuration.yml inventories/${INVENTORY}/group_vars/all.yaml
cat >inventories/${INVENTORY}/group_vars/sno_clusters/path.yml<<EOF
tmpdir:
  path: /tmp
EOF
```

**I will convert this to use ansible vault when i feel like it**
```
cp demos/rhde-pipeline/playbooks/vars/credentials.yml inventories/${INVENTORY}/group_vars/sno_clusters/vault.yaml
vim inventories/${INVENTORY}/group_vars/sno_clusters/vault.yaml
```

**Add hosts file**
```
sno_clusters_user=${USER}
sno_clusters_host=$(hostname -I | awk '{print $1}')
echo "[sno_clusters]" > inventories/${INVENTORY}/hosts
echo "sno_clusters ansible_host=${sno_clusters_host} ansible_user=${sno_clusters_user}" >> inventories/${INVENTORY}/hosts
```
**Configure SSH**
```
IP_ADDRESS=$(hostname -I | awk '{print $1}')
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
ssh-copy-id $USER@${IP_ADDRESS}
```

**Install Ansible Navigator** *if pipeline was not ran*
```
make install-ansible-navigator
```

**Create Ansible navigator config file**
```
export INVENTORY=$GUID
cat >~/.ansible-navigator.yml<<EOF
---
ansible-navigator:
  ansible:
    inventory:
      entries:
      - /home/$USER/device-edge-demos/inventories/${INVENTORY}
  execution-environment:
    container-engine: podman
    enabled: true
    environment-variables:
      pass:
      - USER
    image: localhost/device-edge-demo:0.1.0 
    pull:
      policy: missing
  logging:
    append: true
    file: /tmp/navigator/ansible-navigator.log
    level: debug
  playbook-artifact:
    enable: false
EOF
```

**Build the image:**
```
make build-image
```

**Validate Inventory**
```
ansible-navigator inventory --list -m stdout # --vault-password-file $HOME/.vault_password
```

## Running Plyabooks 
**Configure Openshift Registry** - OPTIONAL
[Configuring the Registry for Perisistent Storage](https://github.com/tosin2013/openshift-4-deployment-notes/blob/master/vmware/configuring-registry.md)
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t configure_registry -m stdout #  --vault-password-file $HOME/.vault_password 
```

**Install Ansible Automation Platform**

```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t install_ansible  --vault-password-file $HOME/.vault_password -m stdout 
```

**Update vault.yaml**
```
$ vim inventories/vmc/group_vars/sno_clusters/vault.yaml

controller_hostname: CHANGEME
controller_password: CHANGEME
```

**Configure Ansible Automation Platform**
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t configure_controller  -m stdout
```


**Configure storage for SNO and OCP Virt**  - OPTIONAL
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t configure_storage  -m stdout
```
**Configure OpenShift Virtulaization**  - OPTIONAL
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t  configure_virtualization -m stdout
```

**Configure Image Builder Template** - OpenShift Virt VM
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t setup_image_builder_template -m stdout
```

**Configure Ansible Automation Platform - Secrets**
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml  -t configure_secrets  -m stdout
```

**Install OpenShift Pipelines**
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t  configure_pipelines -m stdout
```


**Deploy and Configure web container** - TESTING
```
$ ansible-navigator run demos/rhde-pipeline/playbooks/configure-standalone-openshift.yaml -t  deploy_edge_container  -m stdout
```