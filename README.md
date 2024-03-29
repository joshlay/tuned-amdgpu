# tuned-amdgpu

Hacky solution to integrate AMDGPU power control and overclocking in
`tuned` with Ansible.

_TLDR:_ See [my host_vars](./host_vars/localhost.yml) for an overview.

A host will have a collection of `tuned` profiles.
For example: `desktop`, `balanced`, `virt-host`

*This* role extends *those* with AMD GPU power/clock/voltage control.
Each gets `default`, `overclock`, and `peak` variations.

An attempt is made to discover the active GPU using the 'connected' state
in the `DRM` subsystem, example:

```bash
~ $ grep -ls ^connected /sys/class/drm/*/status | grep -o card[0-9] | sort | uniq | sort -h | tail -1
card1
```

_Warning_: This is only tested with `RX6000` series GPUs, it is probable that other generations will *not* work properly.  Use at your own risk!

## Profiles

Two _'profiles'_ are in each name:

- before `amdgpu` is the source profile provided with `tuned`
- after `amdgpu` tells the GPU clock profile offered, outlined below

| Output profile | Description |
|:---|---|
| `balanced-amdgpu-default` | Includes the (assumed) existing `balanced` tuned profile.<br/><br/>Only adjusts the GPU power limit (typically lower).  Clocks/voltage curve remain the default. |
| `desktop-amdgpu-overclock` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Adjusts the GPU power limit, clocks, _and_ the voltage curve. |
| `desktop-amdgpu-peak` | Includes the (assumed) existing `desktop` tuned profile.<br/><br/>Same as the `overclock` profile, but locks clocks to their highest configured values |

## Notable variables

These are the variables you're likely to want to change.  They are defined in [playbook.yml](playbook.yml)

| Variable               | Description                                                                           |  
|------------------------|---------------------------------------------------------------------------------------|  
| gpu_clock_min          | Sets the minimum (dynamic) GPU clock (in `Mhz`) for the non-default `amdgpu` profiles |  
| gpu_clock_max          | Sets the maximum (dynamic) GPU clock (in `MHz`) for the non-default `amdgpu` profiles |  
| gpumem_clock_static       | Sets the _static_ memory clock for the GPU (in `MHz`).  This is *not* the _effective_ data rate.  That is a multiple of this depending on the type of VRAM.<br/><br/>To avoid flickering this does *not* change dynamically with load. |  
| gpu_mv_offset          | GPU core voltage offset.  Takes +/- some integer in millivolts.  Can be used to both over _and_ under volt. eg: `-50` _(undervolt `50mV` or `0.05V`)_ |  
| base_profiles          | List of base tuned profiles to clone in the new AMDGPU profiles.  Defaults based on `Fedora` |  
| gpu_power_multi        | Dictionary with two keys, `default` and `overclock`. Expects two floats to set a power limit relative to the board _capability_. Example: `1.0` is full board capability, `0.5` is 50%. |  
