# tuned-amdgpu

Hacky solution to integrate AMDGPU power/clock control into `tuned` profiles
with Ansible.

Extends existing profiles, such as:

- `balanced`
- `desktop`
- `latency-performance`
- `network-latency`
- `powersave`, and so on

Creating three variations of each, using the [AMDGPU hwmon interfaces](https://docs.kernel.org/gpu/amdgpu/thermal.html):

- `default`: the out-of-the-box configuration
- `overclock`: the optimized card configuration. Includes all of the clock/voltage/power settings
- `peak`: the same as `overclock`, but with clock gating removed. May help profiling

Contrary to the name, `overclock` can be used to de-tune the card as well.

_Warning_: This is only tested with `RX6000` series GPUs, others may _not_ work properly. Use at your own risk!

## Profiles

Two _'profiles'_ are in each name:

- before `amdgpu` is the source profile provided with `tuned`
- after `amdgpu` tells the GPU clock profile offered, outlined below

| Output profile | Description |
|:---|---|
| `balanced-amdgpu-default` | Includes the (assumed) existing `balanced` tuned profile.<br/><br/>Only adjusts the GPU power limit (typically lower).  Clocks/voltage curve remain the default. |
| `desktop-amdgpu-overclock` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Adjusts the GPU power limit, clocks, _and_ the voltage curve. |
| `desktop-amdgpu-peak` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Same as the `overclock` profile, but locks clocks to their highest configured values |

## Config

The playbook will render/make effective this config file: `/etc/tuned/amdgpu-profile-vars.conf`

Here is a preview:

```ini
gpu_clock_min=500
gpu_clock_max=2715
gpumem_clock_static=1075
gpu_power_multi_def=0.869969040247678
gpu_power_multi_oc=1.0
gpu_mv_offset=+60
```

Changes outside of _Ansible_ are not immediately effective. Switching `tuned` profiles or restarting the service would be required.

One can use `gamemode` for dynamic switching. Sample `~/.config/gamemode.ini` below:

```ini
[custom]
start=tuned-adm profile latency-performance-amdgpu-overclock
end=tuned-adm profile latency-performance-amdgpu-default
```

See this [Arch Wiki](https://wiki.archlinux.org/title/Gamemode) link for more comprehensive information.

## Variables

These are the variables you'll want to change/consider.

| Variable               | Description                                                                           |  
|------------------------|---------------------------------------------------------------------------------------|  
| gpu_clock_min          | Sets the min (dynamic) GPU clock (in `Mhz`) for the non-default `amdgpu` profiles |  
| gpu_clock_max          | Sets the max (dynamic) GPU clock (in `MHz`) for the non-default `amdgpu` profiles |  
| gpumem_clock_static       | Sets the _static_ memory clock for the GPU (in `MHz`).  This is *not* the _effective_ data rate.  _That_ would be a multiple of _this_ depending on the type of VRAM.<br/><br/>To avoid flickering this is *not* allowed to change with load, only between `default` and `overclock`/`peak` profiles. |  
| gpu_mv_offset          | GPU core voltage offset.  Takes +/- some integer in millivolts.  Can be used to both over _and_ under volt. eg: `-50` _(undervolt `50mV` or `0.05V`)_ |  
| base_profiles          | List of base tuned profiles to clone in the new AMDGPU profiles.  Defaults based on `Fedora` |  
| gpu_power_multi_def    | Float between `0.0` and `1.0`; controls power limit relative to the board _capability_. For _'default'_-named power profiles. |  
| gpu_power_multi_oc     | Similar to `gpu_power_multi_def`, for _'overclock'_-named power profiles. |  
