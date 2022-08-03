# tuned-amdgpu

Hacky solution to integrate AMDGPU power profile control in `tuned` with Ansible

Takes a list of existing `tuned` profiles and creates new ones based on them.  These new profiles include AMDGPU power/clock parameters

## Profiles

An example of the output/provided profiles follow

| Output profile | Description |
|---|---|
| `balanced-amdgpu-default` | Includes the existing `balanced` tuned profile.  Only adjusts the GPU power limit (typically lower), clocks/voltage curve remain the default. |
| `desktop-amdgpu-VR` | Includes the existing `desktop` tuned profile.  Adjusts the GPU power limit, clocks, and the voltage curve -- using the predefined `VR` profile in the driver |
| `latency-performance-amdgpu-custom` | Includes the existing `latency-performance` tuned profile.  Adjusts the GPU power limit, clocks, and the voltage curve -- using the `custom` profile in the driver.  This opens up further tweaking through the driver (currently manual).  see: [pp-dpm](https://docs.kernel.org/gpu/amdgpu/thermal.html#pp-dpm) |

## Notable variables
 - Power control: (float) multipliers to determine power _limits_ from board power _capability_
   - `power_max_default_multi`: Controls power for the generated `default` GPU profile.  Provided: `0.75` for 75% board power capability.
   - `power_max_custom_multi`: Controls power for the generated `custom` GPU profile.  Provided: `1.0` for 100% board power capability.
 - `card`: Sets the `card#` to use in the qualified `sysfs` path `/sys/class/drm/{{ card }}/device/pp_power_profile_mode`.  Default: `card0`
 - `gpu_mv_offset`: optional, applies offset to GPU voltage, eg: `+100` = to boost GPU core voltage `100mV` or `0.1V`. Can undervolt.
 - `base_profiles`: List of base tuned profiles to clone in the new AMDGPU profiles.  Defaults (based on `Fedora`):
   - `balanced`
   - `desktop`
   - `latency-performance`
   - `network-latency`
   - `network-throughput`
   - `powersave`
   - `virtual-host`

`amdgpu_profiles`: Mapping of AMDGPU power profiles (`name`/`value`) defined in the `sysfs` path above.  Varies, sample is with a 6900XT.  Defaults below
```
amdgpu_profiles: # statically defined mapping of the contents in /sys/class/drm/card*/device/pp_power_profile_mode
  default:       # more may be added, but do not remove default/custom. new profiles require a script template, see 'templates'
    pwrmode: 0
  VR:
    pwrmode: 4
  custom:
    pwrmode: 6
```
