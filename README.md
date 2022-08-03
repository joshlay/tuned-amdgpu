# tuned-amdgpu

Hacky solution to integrate AMDGPU power profile control in `tuned` with Ansible

Takes a list of existing `tuned` profiles and creates new ones based on them.  These new profiles include AMDGPU power/clock parameters

_Warning_: Only tested with RX6000 series GPUs, Navi or older may not work properly.

## Profiles

An example of the output/provided profiles follow

| Output profile | Description |
|:---|---|
| `balanced-amdgpu-default` | Includes the (assumed) existing `balanced` tuned profile.<br/><br/>Only adjusts the GPU power limit (typically lower).  Clocks/voltage curve remain the default. |
| `desktop-amdgpu-VR` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Adjusts the GPU power limit, clocks, _and_ the voltage curve.<br/><br/>Uses the predefined `VR` profile in the driver.  See `/sys/class/drm/card*/device/pp_power_profile_mode` |
| `latency-performance-amdgpu-custom` | Includes the existing `latency-performance` tuned profile.<br/><br/>Like the existing GPU profiles (eg: _VR)), this also adjusts the GPU power limit, clocks, _and_ the voltage curve.<br/><br/>This differs by using the `custom` profile in the driver.  This opens up further tweaking of the power/clock heuristics through the driver (currently manual).  see: [pp-dpm](https://docs.kernel.org/gpu/amdgpu/thermal.html#pp-dpm) |

**Note**: This is non-exhaustive, see the variables `base_profiles` and `amdgpu_profiles` below for the (default) sources of the merged profile mapping

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
   - `amdgpu_profiles`: Dictionary mapping the AMDGPU power profiles found in `/sys/class/drm/card*/device/pp_power_profile_mode`.
       - Allows adjustment to the automatic power/clock handling in the GPU using either predefined profiles or `custom`
       - More may be added, only three GPU power profiles are provided:
           - default
           - VR
           - custom
       - May vary by GPU/generation, sample (defaults, below) are from a 6900XT:
```
amdgpu_profiles:
  default:
    pwrmode: 0
  VR:
    pwrmode: 4
  custom:
    pwrmode: 6
```
