# tuned-amdgpu

Hacky solution to integrate AMDGPU power/clock control into `tuned` profiles
with Ansible.

Extends every `tuned` profile found in `/usr/lib/tuned`
with [AMDGPU hwmon interfaces](https://docs.kernel.org/gpu/amdgpu/thermal.html) in three variations:

- `default`: the out-of-the-box GPU clock/power configuration
- `overclock`: the _optimized_ card configuration. Includes [profile variables](#variables) with clock/voltage/power.
- `peak`: the same as `overclock` with gating removed. Intended for profiling.

Contrary to the name, the `overclock` profile may also be used to _under-{volt,clock}_.


## Assumptions / Limitations

Only tested with `RX6000` series GPUs and the _mainline_ `amdgpu` driver. Other permutations
_may not_ work properly. Please use at your own risk!

Multiple GPUs in a single system are not yet managed,
assumes a single GPU with displays attached.

Please report any issues or PRs, all will be considered.


## Config

```ini
; file: /etc/tuned/amdgpu-profile-vars.conf
tuned_amdgpu_clock_min=500
tuned_amdgpu_clock_max=2715
tuned_amdgpu_memclock_static=1075
tuned_amdgpu_power_multi_def=0.869969040247678
tuned_amdgpu_power_multi_oc=1.0
tuned_amdgpu_mv_offset=+60
```

These represent the [Variables below](#variables); changes outside of _Ansible_
are not immediately effective, requiring switching profiles or restarting the service.

The `gamemode` service offers dynamic switching. Please see this [Arch Wiki](https://wiki.archlinux.org/title/Gamemode) document
for more information. Example:

```ini
; ~/.config/gamemode.ini snippet
[custom]
start=tuned-adm profile latency-performance-amdgpu-overclock
end=tuned-adm profile latency-performance-amdgpu-default
```

## Profiles

Two _'profiles'_ are in each name:

- before `amdgpu` is the source profile provided with `tuned`
- after `amdgpu` tells the GPU clock profile offered, outlined below

| Output profile | Description |
|:---|---|
| `balanced-amdgpu-default` | Includes the (assumed) existing `balanced` tuned profile.<br/><br/>Only adjusts the GPU power limit (typically lower).  Clocks/voltage curve remain the default. |
| `desktop-amdgpu-overclock` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Adjusts the GPU power limit, clocks, _and_ the voltage curve. |
| `desktop-amdgpu-peak` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Same as the `overclock` profile, but locks clocks to their highest configured values |


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
