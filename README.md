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

| Variable               | Description                                                                                                                                                                                                                                                                                                                                | In-playbook                                                                                                                                                                  |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| gpu_clock_min          | Sets the minimum (dynamic) GPU clock (in `Mhz`) for the non-default `amdgpu` profiles                                                                                                                                                                                                                                                                 | `700`                                                                                                                                                    |
| gpu_clock_max          | Sets the maximum (dynamic) GPU clock (in `MHz`) for the non-default `amdgpu` profiles                                                                                                                                                                                                                                                                 | `2600`, results in `2.6GHz` (rounded); mild overclock                                                                                                                     |
| gpumem_clock_static       | Sets the _static_ memory clock for the GPU (in `MHz`).  This is *not* the _effective_ data rate.  That is a multiple of this depending on the type of VRAM.<br/><br/>To avoid flickering this does *not* change dynamically with load.                                                                                                                | `1050`, results in just over `1GHz`; mild overclock<br/><br/>Actual effective clock depends on this being multiplied against the data/pump rate of the `GDDR?` GPU memory                                                                                                                                  |
| gpu_mv_offset          | GPU core voltage offset.  Takes +/- some integer in millivolts.  Can be used to both over _and_ under volt.                                                                                                                                                                                                                                | `-50` (undervolt `50mV` or `0.05V`)                                                                                                                                     |
| base_profiles          | List of base tuned profiles to clone in the new AMDGPU profiles.  Defaults based on `Fedora`                                                                                                                                                                                                                                               | <ul><li>`balanced`</li><li>`desktop`</li><li>`latency-performance`</li><li>`network-latency`</li><li>`network-throughput`</li><li>`powersave`</li><li>`virtual-host`</li>|
| amdgpu_profiles        | Dictionary mapping the AMDGPU power profiles found in `/sys/class/drm/card*/device/pp_power_profile_mode` and custom power limits.<br/><br>For each item, two keys: `pwrmode` and `pwr_cap_multi`.<br/><br/>`pwrmode` maps to the number assigned in `/sys` above.<br/>`pwr_cap_multi` is a multiplier against board power capability. Must be a float, eg: `0.5` for *50%* | <pre>default:<br/>  pwrmode: 0<br/>  pwr_cap_multi: 0.75<br/>  # 75% relatively safe default<br/>VR:<br/>  pwrmode: 4<br/>  pwr_cap_multi: 0.8<br/>  # 80%, likely slight boost<br/>custom:<br/>  pwrmode: 6<br/>  pwr_cap_multi: 1.0<br/>  # 100%, full GPU board capability<br/>  # warning: significantly increased heat</pre>|

