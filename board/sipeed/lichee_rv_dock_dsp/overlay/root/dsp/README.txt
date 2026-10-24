HiFi4 DSP quick reference
=========================

This image carries a FreeRTOS build for the D1's Cadence Tensilica HiFi4
as /root/dsp/dsp.elf. It is NOT loaded automatically: start it by hand
from the U-Boot prompt before booting Linux.

    ext4load mmc 0:1 0x42000000 /root/dsp/dsp.elf
    rproc init
    rproc list
    rproc load 0 0x42000000 0x1fcf4
    rproc start 0
    boot

0x1fcf4 = 130292 bytes. The size argument is parsed as hex and is only
checked against sizeof(Elf32_Ehdr); segments are copied using the ELF's
own offsets, so the exact value only affects the byte count printed by
`rproc load`.

Stop / reset:

    rproc stop 0
    rproc reset 0

Console
-------
This firmware prints to UART0 at 115200 8N1 - the same console as U-Boot
and Linux - so its output interleaves with the boot log. No second
USB-TTL adapter is needed.

Memory
------
The firmware runs from IRAM at 0x00400000 and DDR at 0x48000000. That DDR
range (0x48000000-0x483fffff) is reserved in the device tree, so Linux
does not allocate over the running firmware.

The hwspinlock test module shares a block at 0x483ff000 with the DSP. If
the DSP is not running, `modprobe d1_hwlock_test` reports
"NON-RESULT: DSP never ran" instead of a false pass.

`modprobe d1_hwlock_test bench=N` measures the lock instead of testing it:
with N=1..4 it prints progressively finer breakdowns (raw register access,
the hwspinlock API, the DSP's own take/free, and the pieces the API is built
from). The DSP stays idle during those, so they need it loaded but not busy.

Checks
------
- `rproc list` empty: device tree or driver binding problem, not hardware.
- `rproc start` returns -EIO: the DSP faulted. Check DSP_CFG + 0x10 for
  PFAULT (bit 1) / DOUBLE_EXCE (bit 2).
- Console output stops a few seconds after Linux boots: CLK_DSP is being
  gated, see clk_ignore_unused in /boot/extlinux/extlinux.conf.

