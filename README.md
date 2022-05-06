# tuned-amdgpu

hacky solution to integrate AMDGPU power profile control in `tuned` with Ansible

## Notable variables
 - `power_max_multi`: Accepts a float from (presumably) 0.0 to 1.0.  Allows max GPU power consumption to be controlled.  Default: `0.90` for 90%, roughly stock 3D peak.
 - `card`: Sets the `card#` to use in the qualified sysfs path `/sys/class/drm/{{ card }}/device/pp_power_profile_mode`.  Default: `card0`
 - `base_profiles`: List of base tuned profiles to clone in the new AMDGPU profiles.  Defaults:
   - `desktop`
   - `network-latency`
   - `powersave`
 - `amdgpu_profiles`: Mapping of AMDGPU power profiles (`name`/`value`) defined in the `sysfs` path above.  Varies, sample is with a 6900XT.  Defaults:
   - `{ name: 'bootup_default', value: 0 }`
   - `{ name: '3D_fullscreen', value: 1 }`
   - `{ name: 'powersaving', value: 2 }`
   - `{ name: 'video', value: 3 }`
   - `{ name: 'VR', value: 4 }`
   - `{ name: 'compute', value: 5 }`
   - `{ name: 'custom', value: 6 }`

## Example profiles/output
```
 $ tuned-adm profile                           
Available profiles:
- accelerator-performance     - Throughput performance based tuning with disabled higher latency STOP states
- balanced                    - General non-specialized tuned profile
- desktop                     - Optimize for the desktop use-case
- desktop_amdgpu_3D_fullscreen- desktop based profile with AMDGPU pp_power_profile_mode = 1 (3D_fullscreen)
- desktop_amdgpu_VR           - desktop based profile with AMDGPU pp_power_profile_mode = 4 (VR)
- desktop_amdgpu_bootup_default- desktop based profile with AMDGPU pp_power_profile_mode = 0 (bootup_default)
- desktop_amdgpu_compute      - desktop based profile with AMDGPU pp_power_profile_mode = 5 (compute)
- desktop_amdgpu_custom       - desktop based profile with AMDGPU pp_power_profile_mode = 6 (custom)
- desktop_amdgpu_powersaving  - desktop based profile with AMDGPU pp_power_profile_mode = 2 (powersaving)
- desktop_amdgpu_video        - desktop based profile with AMDGPU pp_power_profile_mode = 3 (video)
- hpc-compute                 - Optimize for HPC compute workloads
- intel-sst                   - Configure for Intel Speed Select Base Frequency
- latency-performance         - Optimize for deterministic performance at the cost of increased power consumption
- network-latency             - Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
- network-latency_amdgpu_3D_fullscreen- network-latency based profile with AMDGPU pp_power_profile_mode = 1 (3D_fullscreen)
- network-latency_amdgpu_VR   - network-latency based profile with AMDGPU pp_power_profile_mode = 4 (VR)
- network-latency_amdgpu_bootup_default- network-latency based profile with AMDGPU pp_power_profile_mode = 0 (bootup_default)
- network-latency_amdgpu_compute- network-latency based profile with AMDGPU pp_power_profile_mode = 5 (compute)
- network-latency_amdgpu_custom- network-latency based profile with AMDGPU pp_power_profile_mode = 6 (custom)
- network-latency_amdgpu_powersaving- network-latency based profile with AMDGPU pp_power_profile_mode = 2 (powersaving)
- network-latency_amdgpu_video- network-latency based profile with AMDGPU pp_power_profile_mode = 3 (video)
- network-throughput          - Optimize for streaming network throughput, generally only necessary on older CPUs or 40G+ networks
- optimize-serial-console     - Optimize for serial console use.
- powersave                   - Optimize for low power consumption
- powersave_amdgpu_3D_fullscreen- powersave based profile with AMDGPU pp_power_profile_mode = 1 (3D_fullscreen)
- powersave_amdgpu_VR         - powersave based profile with AMDGPU pp_power_profile_mode = 4 (VR)
- powersave_amdgpu_bootup_default- powersave based profile with AMDGPU pp_power_profile_mode = 0 (bootup_default)
- powersave_amdgpu_compute    - powersave based profile with AMDGPU pp_power_profile_mode = 5 (compute)
- powersave_amdgpu_custom     - powersave based profile with AMDGPU pp_power_profile_mode = 6 (custom)
- powersave_amdgpu_powersaving- powersave based profile with AMDGPU pp_power_profile_mode = 2 (powersaving)
- powersave_amdgpu_video      - powersave based profile with AMDGPU pp_power_profile_mode = 3 (video)
- throughput-performance      - Broadly applicable tuning that provides excellent performance across a variety of common server workloads
- virtual-guest               - Optimize for running inside a virtual guest
- virtual-host                - Optimize for running KVM guests
```
