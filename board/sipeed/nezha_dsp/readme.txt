Sipeed Nezha (D1, 1 GB) - HiFi4 DSP bring-up
============================================

Second board for the DSP + hardware spinlock test, alongside
sipeed_lichee_rv_dock_dsp. Same SoC, so the same firmware and the same
kernel; only DRAM configuration and the device tree differ.

Targets the 1 GB Nezha. The 2 GB variant should also boot, but it has not
been tried and is not what this configuration is written for.

Sources
-------
All external sources are public GitHub tarballs pinned to a branch, so the
image builds from this tree alone:

    linux     github.com/ikruusa/linux    branch d1-hwspinlock-test
              3 sun6i hwspinlock patches + the d1-hwlock-test module
    u-boot    github.com/ikruusa/u-boot   branch sun20i-dsp-v1
              DSP remoteproc driver, Nezha defconfig, DSP carveout
    opensbi   github.com/ikruusa/opensbi  branch sun20i-changes-v5
              D1s compatible, reset via the reserved watchdog, UART page claim

Nezha support was dropped from U-Boot upstream. The defconfig here is
adapted from the last revision that existed; its DRAM parameters are
identical to the Lichee RV Dock's, which is the part that would otherwise
be board specific and hard to get right.

Build
-----
    make sipeed_nezha_dsp_defconfig
    make

    output/images/sdcard.img

post-image.sh copies the result to /mnt/c/tmp/sdcard-nezha.img. Override:

    COPY_DIR=/mnt/d/tmp make

The tarball locations are branch-level, and Buildroot caches the download
by file name, so after pushing new commits to any of those branches you
must delete the cached tarball or the old one is silently reused:

    rm -f dl/linux/linux-d1-hwspinlock-test.tar.gz   # and similarly for
                                                     # uboot/ and opensbi/

Kernel configuration
--------------------
The kernel config and the hwspinlock fragment are shared with the Lichee RV
Dock targets, since they describe the SoC rather than the board:

    board/sipeed/lichee_rv_dock/linux.config
    board/sipeed/lichee_rv_dock_dsp/linux-hwlock.fragment

The command line comes from this board's overlay and adds
clk_ignore_unused:

    board/sipeed/nezha_dsp/overlay/boot/extlinux/extlinux.conf

Without it mainline's ccu-sun20i-d1 gates CLK_DSP and CLK_BUS_DSP_CFG a few
seconds into boot, because nothing claims them, and the running DSP stops
silently with no fault flag.

DSP firmware
------------
The firmware is a prebuilt blob in the overlay. Buildroot does not build it
and nothing at build time refers to a FreeRTOS tree:

    board/sipeed/nezha_dsp/overlay/root/dsp/dsp.elf

It is installed verbatim as /root/dsp/dsp.elf. To use a different build,
copy the ELF over it and rerun make. Note that the same file also lives in
board/sipeed/lichee_rv_dock_dsp/overlay/root/dsp/ - update both if the
firmware changes.

The source is github.com/ikruusa/FreeRTOS-HIFI4-DSP, branch d1-hwlock-test.
Building it needs the Cadence Xtensa GCC toolchain described in that
project's README; it is a plain `make`.

Nothing autoloads the DSP. The remoteproc commands are run by hand from the
U-Boot prompt; /root/dsp/README.txt in the image has them.

Running
-------
The board boots automatically; U-Boot counts down for 2 seconds. Watch
UART0 (115200 8N1) and press any key during "Hit any key to stop autoboot"
to land at the => prompt. If you miss it, reset and retry.

    ext4load mmc 0:1 0x42000000 /root/dsp/dsp.elf
    rproc init
    rproc list
    rproc load 0 0x42000000 0x1fcf4
    rproc start 0

0x1fcf4 = 130292, the byte count ext4load prints. `boot` then continues to
Linux.

Then, in Linux:

    modprobe d1_hwlock_test              # positive control
    modprobe d1_hwlock_test use_lock=0   # negative control

Notes
-----
- Stage the ELF at 0x42000000. The DSP image itself loads at 0x00400000
  (IRAM) and 0x48000000 (DDR), so the staging address must stay clear.
- The DSP's DDR range 0x48000000-0x483fffff is a reserved-memory carveout
  with no-map in the U-Boot device tree. U-Boot honours /reserved-memory
  when allocating its own load addresses, so the carveout must stay clear
  of kernel_addr_r (0x40200000 plus the ~19 MB Image) - otherwise booti
  fails with "Failed to allocate memory for the image".
- The DSP firmware writes printf() to UART0 (0x02500000), the same console,
  so its output interleaves with U-Boot and Linux.
- Networking is not configured for this board. The Nezha's XR829 WiFi needs
  firmware and an SDIO setup that this image does not carry; the test only
  needs the serial console.
