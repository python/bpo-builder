#!/usr/bin/env bash

# write mock passwd and group files
(
  exec 2>/dev/null
  __username=${NSS_USERNAME:-$(id -un)}
  __uid=${NSS_UID:-$(id -u)}

  __groupname=${NSS_GROUPNAME:-$(id -gn)}
  __gid=${NSS_GID:-$(id -g)}

  echo "$__username:x:$__uid:$__uid:gecos:$HOME:/bin/bash" > $NSS_WRAPPER_PASSWD
  echo "$__groupname:x:$__gid:" > $NSS_WRAPPER_GROUP
)

# wrap command
export LD_PRELOAD=/usr/local/lib64/libnss_wrapper.so
exec $@
