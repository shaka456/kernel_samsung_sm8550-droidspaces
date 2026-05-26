# kernel_samsung_sm8550-droidspaces

Samsung SM8550 (Snapdragon 8 Gen 2 / Galaxy S23) kernel 5.15.185 with Droidspaces support and KernelSU-Next integration.

## What is Droidspaces?

Droidspaces is a containerization solution for Android that creates isolated Linux containers using kernel namespaces (PID, MNT, UTS, IPC, Cgroup, Network). Unlike simple chroot, Droidspaces provides true process isolation, allowing you to run full Linux distributions (Debian, Ubuntu, Arch, Fedora) with their own init system, hostname, IPC, and optional network stack — all natively on your Android device.

This enables use cases like:
- Running a full Linux desktop (XFCE, KDE) with GPU acceleration via Termux-X11
- Development environments on Android
- Isolated services and sandboxed applications
- Native Adreno GPU acceleration via Turnip/Mesa drivers

## Kernel Configuration

All Droidspaces-required configs enabled in `arch/arm64/configs/gki_defconfig`:

| Config | Purpose |
|--------|---------|
| `CONFIG_SYSVIPC=y` | System V IPC (required for IPC namespace) |
| `CONFIG_POSIX_MQUEUE=y` | POSIX message queues |
| `CONFIG_IPC_NS=y` | IPC namespace isolation |
| `CONFIG_PID_NS=y` | PID namespace isolation |
| `CONFIG_CGROUP_PIDS=y` | PIDs cgroup controller |
| `CONFIG_CGROUP_DEVICE=y` | Device cgroup controller |
| `CONFIG_DEVTMPFS=y` | Auto-mounted devtmpfs |
| `CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y` | Netfilter addrtype match |
| `CONFIG_NETFILTER_XT_TARGET_LOG=y` | Netfilter LOG target |
| `CONFIG_NETFILTER_XT_MATCH_RECENT=y` | Netfilter recent match |
| `CONFIG_IP_SET=y` | IP sets framework |
| `CONFIG_IP_SET_HASH_IP=y` | IP set hash:ip type |
| `CONFIG_IP_SET_HASH_NET=y` | IP set hash:net type |
| `CONFIG_NETFILTER_XT_SET=y` | Netfilter IP set match/target |
| `CONFIG_TMPFS_POSIX_ACL=y` | POSIX ACLs on tmpfs |
| `CONFIG_TMPFS_XATTR=y` | Extended attributes on tmpfs |
| `CONFIG_IP_NF_TARGET_REJECT=y` | IPv4 REJECT target |
| `CONFIG_IP6_NF_TARGET_REJECT=y` | IPv6 REJECT target |

Additional modifications:
- `CONFIG_MODVERSIONS` disabled — prevents CRC mismatch bootloop with vendor modules
- Vermagic hardcoded to vendor string: `5.15.178-android13-8-31998796-abS911BXXS8EYK2 SMP preempt mod_unload modversions aarch64`

## KABI Patch

Applied Droidspaces kABI patch for GKI kernels below 6.12:
- **ANDROID_KABI_USE(3)** → `struct sysv_sem sysvsem` in `task_struct`
- **_ANDROID_KABI_REPLACE(4, 5)** → `struct sysv_shm sysvshm` in `task_struct`

This fills the Android KABI reserve slots in `include/linux/sched.h` without changing `task_struct` size, preserving binary compatibility with vendor modules.

## KernelSU-Next

**KernelSU-Next v3.2.0** integrated with manual hooks (no kprobes):
- `CONFIG_KSU=y`
- `CONFIG_KSU_WITH_KPROBES=n`

KernelSU-Next source is cloned to `KernelSU-Next/` and symlinked at `drivers/kernelsu`.

## Building

### Prerequisites

- Clang builder (tested with `clang-r547379`)
- Place it at `../tools/google-clang/` relative to this kernel source

### Build

```bash
bash scripts/build.sh
```

The build script automatically copies `vendor-symvers/Module.symvers` to the source root before compilation. This file contains merged CRCs from Samsung vendor modules to ensure compatibility.

### Flash

Pack the resulting `out/arch/arm64/boot/Image.gz` into an AnyKernel3 zip and flash via TWRP.

## Device Info

- **Device**: Samsung Galaxy S23 (SM-S911B)
- **SoC**: Snapdragon 8 Gen 2 (SM8550)
- **GPU**: Adreno 740 (Turnip driver supported)
- **Kernel**: 5.15.185 (GKI)
- **Android**: 13
