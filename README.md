# tuned-amdgpu

Hacky solution to integrate AMDGPU power/clock control into `tuned` profiles
with Ansible.

Extends every `tuned` profile found in `/usr/lib/tuned`
using the [AMDGPU hwmon interfaces](https://docs.kernel.org/gpu/amdgpu/thermal.html):

- `default`: the out-of-the-box GPU clock/power configuration
- `overclock`: the _optimized_ card configuration. Includes the clock/voltage/power settings outlined below.
- `peak`: the same as `overclock`, but with clock gating removed. May help profiling.

Contrary to the name, the `overclock` profiles can be used to de-tune the card as well.

_Warning_: This is only tested with `RX6000` series GPUs, others may _not_ work properly. Use at your own risk!

## Assumptions / Limitations

Multiple GPUs in a single system are not yet supported.
This role assumes management over a single GPU with displays attached.

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
tuned_amdgpu_clock_min=500
tuned_amdgpu_clock_max=2715
tuned_amdgpu_memclock_static=1075
tuned_amdgpu_power_multi_def=0.869969040247678
tuned_amdgpu_power_multi_oc=1.0
tuned_amdgpu_mv_offset=+60
```
These are the result of [Variables](#Variables) below; changes outside of _Ansible_ are not immediately effective. Switching `tuned` profiles or restarting the service would be required.

One can use `gamemode` for dynamic switching. Sample `~/.config/gamemode.ini` below:

```ini
[custom]
start=tuned-adm profile latency-performance-amdgpu-overclock
end=tuned-adm profile latency-performance-amdgpu-default
```

See this [Arch Wiki](https://wiki.archlinux.org/title/Gamemode) link for more comprehensive information.

## Variables

These are the variables you'll want to change/consider.

| Variable               | Description |  
|------------------------|-------------|  
| `tuned_amdgpu_clock_min` | Mininum **GPU** clock _(in `Mhz`)_ for `overclock` and `peak` profiles |  
| `tuned_amdgpu_clock_max` | Maximum **GPU** clock _(in `MHz`)_ for `overclock` and `peak` profiles |  
| `tuned_amdgpu_mv_offset` | GPU voltage _offset_. Takes `+/-` some integer in _millivolts_ to raise or lower. eg: `-25` for `0.025V` undervolt. |  
| `tuned_amdgpu_power_multi_def` | Float between `0.0` _(none)_ and `1.0` _(full)_; effective power limit relative to _board capability_. For the `default` profiles |  
| `tuned_amdgpu_power_multi_oc` | Instance of `tuned_amdgpu_power_multi_def` for `overclock` and `peak` profiles |  
| `tuned_amdgpu_memclock_static` | _Static_ **memory** clock _(in `MHz`)_ for `overclock` and `peak` profiles.<br/><br/>Not the effective data rate _(multiplied by generation)_, but the actual clock. Static assignment avoids potential display flickering. |  
