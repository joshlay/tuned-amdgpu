# tuned-amdgpu

Hacky solution to integrate AMDGPU power profile control in `tuned` with Ansible

Takes a list of existing `tuned` profiles and creates new ones based on them.  These new profiles include AMDGPU power/clock parameters

An attempt is made to discover the active GPU using the 'connected' state in the `DRM` subsystem, example:
```
$ grep -ls ^connected /sys/class/drm/*/status | grep -o card[0-9] | sort | uniq | sort -h | tail -1
card1
```

_Warning_: This is only tested with `RX6000` series GPUs, it is probable that older AMD GPUs will not work properly.  Use at your own risk!

## Profiles

An example of the output/provided profiles follow

| Output profile | Description |
|:---|---|
| `balanced-amdgpu-default` | Includes the (assumed) existing `balanced` tuned profile.<br/><br/>Only adjusts the GPU power limit (typically lower).  Clocks/voltage curve remain the default. |
| `desktop-amdgpu-VR` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Adjusts the GPU power limit, clocks, _and_ the voltage curve.<br/><br/>Uses the predefined `VR` profile in the driver.  See `/sys/class/drm/card*/device/pp_power_profile_mode` |
| `latency-performance-amdgpu-custom` | Includes the existing `latency-performance` tuned profile.<br/><br/>Like the existing GPU profiles (eg: _VR)), this also adjusts the GPU power limit, clocks, _and_ the voltage curve.<br/><br/>This differs by using the `custom` profile in the driver.  This opens up further tweaking of the power/clock heuristics through the driver (currently manual).  see: [pp-dpm](https://docs.kernel.org/gpu/amdgpu/thermal.html#pp-dpm) |

**Note**: This is non-exhaustive, see the variables `base_profiles` and `amdgpu_profiles` below for the (default) sources of the merged profile mapping

## Notable variables

These are the variables you're likely to want to change.  They are defined in [playbook.yml](playbook.yml)

| Variable               | Description                                                                                                                                                                                                                                                                                                                                | Default                                                                                                                                                                  |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| power_max_default_multi| Must be a float.<br/><br/>Sets the AMD GPU power limit for the newly-created `amdgpu-default` GPU profiles in `tuned`.<br/><br/>A multiplier against the board power _capability_                                                                                                                                                          | `0.928793` or ~`93%`, provides roughly 300W from my 323W board capability.                                                                                               |
| power_max_custom_multi | Same as above but for the non-default `amdgpu` profiles in `tuned`.  eg: `...-amdgpu-{VR,custom}`                                                                                                                                                                                                                                          | `0.82` or `82%`, my 6900XT defaults to ~87% -- allowing for slightly less power                                                                                          |
| gpu_clock_min          | Sets the minimum (dynamic) GPU clock for the non-default `amdgpu` profiles                                                                                                                                                                                                                                                                 | 2000, results in 2Ghz                                                                                                                                                    |
| gpu_clock_max          | Sets the maximum (dynamic) GPU clock for the non-default `amdgpu` profiles                                                                                                                                                                                                                                                                 | 2615, results in 2.62Ghz (rounded) -- mild overclock                                                                                                                     |
| gpumem_clock_max       | Sets the _static_ memory clock for the GPU.  This is *not* the _effective_ data rate.  That is a multiple of this depending on the type of VRAM.<br/><br/>To avoid flickering this does *not* change dynamically with load.                                                                                                                | 1075, results in 1.1Ghz (base, rounded)                                                                                                                                  |
| gpu_mv_offset          | GPU core voltage offset.  Takes +/- some integer in millivolts.  Can be used to both over _and_ under volt.                                                                                                                                                                                                                                | `-25` (undervolt `25mV` or `0.025V`)                                                                                                                                     |
| base_profiles          | List of base tuned profiles to clone in the new AMDGPU profiles.  Defaults based on `Fedora`                                                                                                                                                                                                                                               | <ul><li>`balanced`</li><li>`desktop`</li><li>`latency-performance`</li><li>`network-latency`</li><li>`network-throughput`</li><li>`powersave`</li><li>`virtual-host`</li>|
| amdgpu_profiles        | Dictionary mapping the AMDGPU power profiles found in `/sys/class/drm/card*/device/pp_power_profile_mode`.<br/><br>Allows adjustment to the automatic power/clock handling in the GPU using either predefined profiles or `custom`<br/><br/>More may be added, only three GPU power profiles are provided -- `default`, `VR`, and `custom`.| <pre>default:<br/>  pwrmode: 0<br/>VR:<br/>  pwrmode: 4<br/>custom:<br/>  pwrmode: 6</pre>|

