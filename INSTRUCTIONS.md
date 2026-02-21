# Instructions for Updating Lenovo Legion Driver (2023 Models)

This guide helps you identify the necessary information from your Windows and Linux systems to update the `legion-laptop` driver for your specific model (e.g., Legion Y9000P 2023).

## Step 1: Gather Information from Windows

1.  Boot into **Windows 11**.
2.  Copy the script `windows_wmi_probe.ps1` to your Windows machine.
3.  Right-click the file and select **"Run with PowerShell"** (Run as Administrator if possible).
4.  The script will list all "Lenovo" related WMI classes and their methods.
5.  **Look for the following info in the output:**
    *   Classes named `Lenovo_Wmi_...`
    *   Their **GUID** (e.g., `887B54E3-DDDC-4B2C-8B88-68A26A8835D0`).
    *   The list of **Methods** supported by each class (e.g., `GetFanCurve`, `SetFanCurve`, `GetSmartFanMode`).
6.  Save this output; you will need to compare these GUIDs with the ones in `kernel_module/legion-laptop.c`.

## Step 2: Gather Information from Linux

1.  Boot into **Kubuntu 24**.
2.  Open a terminal in this repository folder.
3.  Run the Linux probe script:
    ```bash
    chmod +x linux_debug_info.sh
    sudo ./linux_debug_info.sh
    ```
4.  **Note the following output:**
    *   **BIOS Version:** (e.g., `KWCN32WW` or `LPCN...`)
    *   **Product Name:** (e.g., `Legion Y9000P IRX8`)
    *   **WMI Devices:** Check if GUIDs like `887B54E3...` are listed.

## Step 3: Enable Debug Mode & Test

The driver has been modified to support a "debug mode" that prints detailed DMI and WMI info.

1.  Build the driver:
    ```bash
    cd kernel_module
    make
    ```
2.  Load the driver with debug output enabled:
    ```bash
    sudo insmod legion-laptop.ko force=1 debug_output=1
    ```
3.  Check the kernel logs for the detected info:
    ```bash
    sudo dmesg | grep -i legion
    ```
    *Look for lines starting with "DEBUG:".*

## Step 4: Update the Driver Code

If the driver loads but features (like fan control) fail, you need to add your specific model to the allowlist.

1.  Open `kernel_module/legion-laptop.c`.
2.  Search for `optimistic_allowlist`.
3.  I have added a **template** at the beginning of the list (commented out):
    ```c
    /*
    {
        // Template for 2023 models (Gen 8) like Y9000P
        .ident = "Y9000P_2023_TEMPLATE",
        .matches = {
            DMI_MATCH(DMI_SYS_VENDOR, "LENOVO"),
            DMI_MATCH(DMI_BIOS_VERSION, "XXXX"), // <--- Replace XXXX with your BIOS prefix (e.g. KWCN)
        },
        .driver_data = (void *)&model_kwcn // <--- Try model_kwcn or model_lpcn
    },
    */
    ```
4.  Uncomment this block and replace `"XXXX"` with the first 4 letters of your **BIOS Version** (found in Step 2).
5.  Try changing `.driver_data` to `&model_kwcn` (Legion 7i Pro 2023) or `&model_lpcn` (Legion Pro 5 2023) or `&model_g8cn`. These models use different WMI access methods (`ACCESS_METHOD_WMI3` vs `ACCESS_METHOD_WMI`).
6.  Recompile and reload:
    ```bash
    make
    sudo make reloadmodule
    ```

## Step 5: Verify Fix

1.  Check if fan curves are readable:
    ```bash
    sudo cat /sys/kernel/debug/legion/fancurve
    ```
2.  Check sensors:
    ```bash
    sensors
    ```

If you still get errors, check `dmesg` again. The `debug_output=1` parameter will log exactly which WMI method was called and if it failed.
