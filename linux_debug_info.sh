#!/bin/bash
# Probe Linux System Info for Lenovo Legion
# Run this as sudo

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit
fi

echo "--- DMI Information ---"
BIOS_VERSION=$(dmidecode -s bios-version)
PRODUCT_NAME=$(dmidecode -s system-product-name)
echo "BIOS Version: $BIOS_VERSION"
echo "Product Name: $PRODUCT_NAME"
echo ""

echo "--- WMI Devices (Linux Kernel) ---"
ls -l /sys/bus/wmi/devices/
echo ""

echo "--- Kernel Module Status ---"
lsmod | grep legion
if [ $? -eq 0 ]; then
    echo "Module 'legion-laptop' is loaded."
else
    echo "Module 'legion-laptop' is NOT loaded."
fi
echo ""

echo "--- Debug Suggestions ---"
echo "If the module is not loaded, try forcing it:"
echo "sudo insmod legion-laptop.ko force=1 debug_output=1"
echo "Then check dmesg:"
echo "dmesg | grep legion"
