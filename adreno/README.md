# Adreno 540 stack for the KGSL route (experimental)

Proprietary Qualcomm graphics libraries for running the LG V30 (joan) on
Qualcomm's own driver stack instead of Mesa freedreno. They need the
[kgsl_joan](https://codeberg.org/scada/kgsl_joan) kernel module (branch
`joan-6.18`) and the `msm.separate_gpu_kms=1` kernel argument, so that
drm/msm keeps the display and KGSL takes the GPU. The default ROM build
does not use any of this.

Status: SurfaceFlinger renders through the Adreno driver and drm_hwcomposer
scans its buffers out. Still under test; not for daily use.

## Contents

`vendor/` mirrors the paths under `/vendor`:

| Files | Source |
|---|---|
| `lib64/egl/*`, `libgsl.so`, `libllvm-*.so`, `libCB.so`, `libOpenCL.so`, `hw/vulkan.msm8998.so`, RenderScript, C2D, FastCV, ... | Adreno Team Graphics Drivers v5.5 (OpenGL ES V@0490.0, Vulkan 1.1.128) for SD835, by Arda Süzen / Adreno Modding Team |
| `hw/gralloc.msm8998.so`, `libgrallocutils.so`, `libqdMetaData.so` | official LineageOS 22.2 joan vendor image |
| `etc/vintf/manifest/joan-legacy-gralloc.xml` | this port (allocator 2.0 manifest) |

The symlinks are deliberate. `libEGL_mesa.so`, `libGLESv*_mesa.so`,
`vulkan.none.so` and `gralloc.minigbm.so` point at the Adreno and Qualcomm
libraries, so the paths the default build already loads pick up this stack.

`config/` holds what the test image changes on top of a normal build:

- `joan_graphics_boot.sh`: loads `msm_kgsl.ko` and `ion_legacy.ko`, hands
  the GPU from drm/msm to KGSL and links the display-only DRM node to
  `/dev/dri/joan-display`. It runs before the graphics services start.
- `etc_init_allocator.rc`, `etc_init_hwc3-joan.rc`: the gralloc 2.0
  allocator and the `drm_joan` composer (`graphics/` in the device tree).
  They still run with `seclabel u:r:su:s0` until there is real sepolicy.
- `etc_ueventd.rc`: device permissions for `/dev/kgsl-3d0` and `/dev/ion`.
- `build.prop.additions`: selects the Adreno EGL, Vulkan and gralloc, and
  enables multi-plane DPU hardware overlays and UBWC 1.0 scanout (requires the
  `kgsl_joan` Linux 7.3 `dma_fence->ops` NULL-safety fix).

These binaries are redistributed for interoperability. All rights belong to
their owners.
