# tuned-amdgpu

hacky solution to integrate AMDGPU power profile control in `tuned` with Ansible

## Notable variables
 - Power control: (float) multipliers to determine power _limits_ from board power _capability_
   - `power_max_default_multi`: Controls power for the generated `default` GPU profile.  Provided: `0.75` for 75% board power capability.
   - `power_max_custom_multi`: Controls power for the generated `custom` GPU profile.  Provided: `1.0` for 100% board power capability.
 - `card`: Sets the `card#` to use in the qualified `sysfs` path `/sys/class/drm/{{ card }}/device/pp_power_profile_mode`.  Default: `card0`
 - `base_profiles`: List of base tuned profiles to clone in the new AMDGPU profiles.  Defaults (based on `Fedora`):
   - `balanced`
   - `desktop`
   - `latency-performance`
   - `network-latency`
   - `network-throughput`
   - `powersave`
   - `virtual-host`
 - `amdgpu_profiles`: Mapping of AMDGPU power profiles (`name`/`value`) defined in the `sysfs` path above.  Varies, sample is with a 6900XT.  Defaults:
   - `{ name: 'default', value: 0 }`
   - `{ name: 'custom', value: 6 }`

## Example profiles/output
```
$ tuned-adm profile
Available profiles:
- accelerator-performance     - Throughput performance based tuning with disabled higher latency STOP states
- balanced                    - General non-specialized tuned profile
- balanced-amdgpu-custom      - balanced + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 6 (custom)
- balanced-amdgpu-default     - balanced + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 0 (default)
- desktop                     - Optimize for the desktop use-case
- desktop-amdgpu-custom       - desktop + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 6 (custom)
- desktop-amdgpu-default      - desktop + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 0 (default)
- hpc-compute                 - Optimize for HPC compute workloads
- intel-sst                   - Configure for Intel Speed Select Base Frequency
- latency-performance         - Optimize for deterministic performance at the cost of increased power consumption
- latency-performance-amdgpu-custom- latency-performance + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 6 (custom)
- latency-performance-amdgpu-default- latency-performance + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 0 (default)
- network-latency             - Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
- network-latency-amdgpu-custom- network-latency + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 6 (custom)
- network-latency-amdgpu-default- network-latency + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 0 (default)
- network-throughput          - Optimize for streaming network throughput, generally only necessary on older CPUs or 40G+ networks
- network-throughput-amdgpu-custom- network-throughput + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 6 (custom)
- network-throughput-amdgpu-default- network-throughput + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 0 (default)
- optimize-serial-console     - Optimize for serial console use.
- powersave                   - Optimize for low power consumption
- powersave-amdgpu-custom     - powersave + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 6 (custom)
- powersave-amdgpu-default    - powersave + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 0 (default)
- throughput-performance      - Broadly applicable tuning that provides excellent performance across a variety of common server workloads
- virtual-guest               - Optimize for running inside a virtual guest
- virtual-host                - Optimize for running KVM guests
- virtual-host-amdgpu-custom  - virtual-host + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 6 (custom)
- virtual-host-amdgpu-default - virtual-host + TCP/RAID tweaks + AMDGPU pp_power_profile_mode = 0 (default)
Current active profile: network-latency-amdgpu-default
```
