#cloud-config
# Add groups to the system
# The following example adds the ubuntu group with members foo and bar and
# the group cloud-users.
groups:
  - docker: [${user_name}]

# Add users to the system. Users are added after groups are added.
users:
  - name: ${user_name}
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    primary-group: ${user_name}
    groups: sudo
    lock_passwd: true
    passwd: ${user_passwd}
    ssh-authorized-keys:
      - ${ssh_authorized-key}
