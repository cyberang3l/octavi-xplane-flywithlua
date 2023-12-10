# octavi-xplane-flywithlua
An X-PLANE FlyWithLua script for Octavi, with visual feedback that shows:

1. If Octavi is operated on primary (COM1, COM2, NAV1, NAV2, FMS1, FMS2, AP, XPDR) or secondary (HDG, BARO, CRS1, CRS2, FMS1, FMS2, AP, MODE) mode
2. Button presses highlight the corresponding buttons that are pressed on the device
3. Leds that are activated
4. Small/large knob rotation is shown with arrow
   
The visual feedback functionality is particularly useful when flying in VR

Note that the plugin only fully supports the Cessna 172 with the analog cockpit, as this is the plane I mainly fly with. 

## How to use on Linux (the only tested platform)

1. Make sure the Octavi device is recognised by your system. I use the `lsusb` command for this. Expect to find the following device (notice the ID `04d8:e6d6`) in the command's output:
   
       $ lsusb
       ...
       Bus 005 Device 008: ID 04d8:e6d6 Microchip Technology, Inc. IFR1
       ...
  
2. Ensure your user has read/write access to the device: read access is needed to read state from Octavi - button presses, and write access is needed to change which LEDs are turned on on the device - the script keeps the LEDs in sync when the Autopilot state changes. You can use the following udev rules script to fix the permissions:

       $ cat /etc/udev/rules.d/70-Octavi.rules  # your distro may be using a different path for udev rules scripts
       KERNEL=="*", ATTRS{idVendor}=="04d8", ATTRS{idProduct}=="e6d6", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1", TAG+="uaccess"

3. Once you create the udev rules script, reload the udev rules with the command `sudo udevadm control --reload-rules`, or reboot your computer.
4. Install the [FlyWithLua](https://github.com/X-Friese/FlyWithLua) X-Plane plugin
5. From [this](https://github.com/cyberang3l/octavi-xplane-flywithlua) repository, copy the files `Octavi.lua`, `OctaviVisualInfo.lua`, and the folder `octavilib`, in your `FlyWithLua/Scripts` directory. I use X-Plane via steam on Linux and the directory to copy the files to is located at `$HOME/.steam/debian-installation/steamapps/common/X-Plane 12/Resources/plugins/FlyWithLua/Scripts/`. After you copy these files, the contents should look like this:

       $ ls "$HOME/.steam/debian-installation/steamapps/common/X-Plane 12/Resources/plugins/FlyWithLua/Scripts/"
       octavilib   Octavi.lua   OctaviVisualInfo.lua
       $ ls "$HOME/.steam/debian-installation/steamapps/common/X-Plane 12/Resources/plugins/FlyWithLua/Scripts/octavilib"
       OctaviDatarefs.lua  OctaviDefinitions.lua  OctaviHelperFuncs.lua  OctaviMainFuncs.lua

6. Start X-Plane and enjoy your Octavi cockpit!
