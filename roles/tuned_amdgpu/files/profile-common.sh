#!/bin/bash
#
# 'common' file sourced by other scripts under tuned profile
#
# dynamically determine the connected GPU using the DRM subsystem
CARD=$(/usr/bin/grep -ls ^connected /sys/class/drm/*/status | /usr/bin/grep -o 'card[0-9]' | /usr/bin/sort | /usr/bin/uniq | /usr/bin/sort -h | /usr/bin/tail -1)

function get_hwmon_dir() {
    CARD_DIR="/sys/class/drm/${1}/device/"
    for CANDIDATE in "${CARD_DIR}"/hwmon/hwmon*; do
            if [[ -f "${CANDIDATE}"/power1_cap ]]; then
                    # found a valid hwmon dir
                    echo "${CANDIDATE}"
            fi
    done
}

# determine the hwmon directory
HWMON_DIR=$(get_hwmon_dir "${CARD}")

# read all of the power profiles, used to get the IDs for assignment later
PROFILE_MODES=$(< /sys/class/drm/"${CARD}"/device/pp_power_profile_mode)

# get power capability; later used determine limits
read -r -d '' POWER_CAP < "$HWMON_DIR"/power1_cap_max

# enable THP; profile enables the 'vm.compaction_proactiveness' sysctl
# improves allocation latency
echo 'always' | tee /sys/kernel/mm/transparent_hugepage/enabled

# export determinations
export CARD
export HWMON_DIR
export PROFILE_MODES
export POWER_CAP
