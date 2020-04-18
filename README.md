# PuppetLab
Silly testbed for puppet.

This repo is for testing various scenarios with puppet/bolt tools.
It is not recommended for any production scenarios, but you are highly encouraged
to give feedback!

## Quickstart

add to your ssh_config a directory

```
Include PATH_TO_YOUR_SSH_INCLUDE/ssh_config
```

After that init terraform and apply

```
terraform init
terraform apply -var ssh_include_path=PATH_TO_YOUR_SSH_INCLUDE/ssh_config
```

You should now be able to simply ssh to puppetmaster and database machines:

```
ssh puppetmaster
ssh database
```
