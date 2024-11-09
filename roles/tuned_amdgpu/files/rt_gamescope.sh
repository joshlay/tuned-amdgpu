#!/bin/bash
#
# script run by 'tuned' to ensure gamescope has the proper capability

# Check for arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 {verify|start}"
    exit 1
fi

function verify_cap() {
        /usr/sbin/getcap "$(which gamescope)" |& grep 'sys_nice=eip'
        return $?
}

function set_cap() {
        /usr/sbin/setcap 'CAP_SYS_NICE=eip' "$(which gamescope)"
}

# Handle arguments
case "$1" in
    verify)
        verify_cap
        ;;
    start)
        set_cap
        ;;
    *)
        echo "Invalid argument. Use 'verify' or 'start'."
        exit 1
        ;;
esac

