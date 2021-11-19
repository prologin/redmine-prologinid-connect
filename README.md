# Redmine ProloginID Connect

Plugin that integrates ProloginID authentication to redmine

## How to install

```
cd plugins/
git clone git@github.com:prologin/redmine-prologinid-connect prologinid_connect
```

## How to configure

Go to administration > plugins > Redmine ProloginID Connect > Configure

## Keycloak Role mappings

You can control some redmine-related settings with keycloak **client roles** :

- `redmine::access` is a required role to connect to redmine
- `redmine::superuser` is a role that grants admin access on redmine

- `redmine::group::gid` adds the user to redmine group with the id `gid`


At each login, group memberships are changed to match the keycloak roles.

For example if a user tries to login and is a member of group 1 in redmine
but does not have the role `redmine::group::1`, the user will be removed
from group 1.