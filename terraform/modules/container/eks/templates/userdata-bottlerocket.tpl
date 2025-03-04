# https://github.com/bottlerocket-os/bottlerocket/blob/develop/README.md#description-of-settings
${pre_userdata}
[settings.kubernetes]
api-server = "${endpoint}"
cluster-certificate = "${cluster_auth_base64}"
cluster-name = "${cluster_name}"

${additional_userdata}

# Hardening based on https://github.com/bottlerocket-os/bottlerocket/blob/develop/SECURITY_GUIDANCE.md

# Enable kernel lockdown in "integrity" mode.
# This prevents modifications to the running kernel, even by privileged users.
[settings.kernel]
lockdown = "integrity"

# The admin host container provides SSH access and runs with "superpowers".
# It is disabled by default, but can be disabled explicitly.
[settings.host-containers.admin]
enabled = ${enable_admin_container}

# The control host container provides out-of-band access via SSM.
# It is enabled by default, and can be disabled if you do not expect to use SSM.
# This could leave you with no way to access the API and change settings on an existing node!
[settings.host-containers.control]
enabled = ${enable_control_container}