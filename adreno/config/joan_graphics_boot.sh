#!/system/bin/sh
# Select the supplied Qualcomm stack before Android graphics services start.
set -eu
exec >> /dev/joan-graphics-boot.log 2>&1
echo "GPU bringup $(cat /proc/uptime)"
insmod /vendor/lib/modules/msm_kgsl.ko joan_trace=0
insmod /vendor/lib/modules/ion_legacy.ko
echo 5000000.gpu > /sys/bus/platform/drivers/adreno/unbind
echo 5000000.gpu > /sys/bus/platform/drivers/kgsl-3d/bind
chown system:graphics /dev/kgsl-3d0 /dev/ion
chmod 666 /dev/kgsl-3d0 /dev/ion
for card in /sys/class/drm/card[0-9]*; do
    case "$(readlink "$card/device/driver" 2>/dev/null)" in
        */msm_dpu)
            ln -sf "/dev/dri/${card##*/}" /dev/dri/joan-display
            echo "Display ${card##*/}; KGSL ready"
            exit 0
            ;;
    esac
done
echo 'No display-only DRM device found' >&2
exit 1
