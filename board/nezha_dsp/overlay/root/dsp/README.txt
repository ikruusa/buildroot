HiFi4 DSP quick reference — Sipeed Nezha (D1, 1 GB)
===================================================

The DSP is managed with U-Boot's remoteproc commands, not from Linux. U-Boot
builds the DSP's device tree node itself (arch/riscv/dts/sun20i-u-boot.dtsi),
so there is nothing to add on this board.

Stage the firmware in DRAM. 0x42000000 is clear of the DSP's own load
addresses (0x00400000 IRAM and 0x48000000 DDR):

    ext4load mmc 0:1 0x42000000 /root/dsp/dsp.elf

Then:

    rproc init
    rproc list
    rproc load 0 0x42000000 0x1fcf4
    rproc start 0

0x1fcf4 = 130292 bytes, the count ext4load prints. `rproc load` parses its
size argument as hex, so the decimal figure cannot be used directly.

Stop / reset:

    rproc stop 0
    rproc reset 0

The DSP firmware writes to UART0, which is also the U-Boot and Linux console,
so its output interleaves with the boot log. No second USB-TTL adapter is
needed.

If `rproc list` is empty, the device tree or driver binding is wrong rather
than the hardware. If `rproc start` returns -EIO, the DSP faulted: check the
SRAM remap bit first (SYS_CFG + 0x08 bit 0 must be 0 before RUN_STALL is
released).

Do not read 0x00400000 from Linux once the DSP owns the local SRAM — the
access hangs the bus with no oops.
