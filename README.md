# octavi-xplane-flywithlua

An unofficial X-PLANE FlyWithLua script for Linux and the Octavi IFR pad. The plugin provides visual feedback (mostly useful when playing in VR) that shows:

1. If Octavi is operated on primary (COM1, COM2, NAV1, NAV2, FMS1, FMS2, AP, XPDR) or secondary (HDG, BARO, CRS1, CRS2, FMS1, FMS2, AP, MODE) mode
2. Button presses highlight the corresponding buttons that are pressed on the device
3. Leds that are activated
4. Small/large knob rotation is shown with arrow

The visual feedback functionality is particularly useful when flying in VR

Note that the plugin only fully supports the Cessna 172 with the analog cockpit, as this is the plane I mainly fly with.

Some screenshots and video demonstration follows:

[![3](https://img.youtube.com/vi/gTOLRPJOfcE/0.jpg)](https://www.youtube.com/watch?v=gTOLRPJOfcE)
![1](https://github.com/cyberang3l/octavi-xplane-flywithlua/assets/5658474/d685bc0a-825d-48bb-9901-2d1472cc8bc1)
![2](https://github.com/cyberang3l/octavi-xplane-flywithlua/assets/5658474/0c00669b-e192-4c00-888e-a9f13d2cbf89)
![0](https://github.com/cyberang3l/octavi-xplane-flywithlua/assets/5658474/2cea71b6-2d2b-4954-8f1c-473fee18b07f)

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

## How to further experiment and develop for the device

Octavi is a standard [USB HID device](https://en.wikipedia.org/wiki/USB_human_interface_device_class) and it doesn't require any special driver to be recognised by the OS. The moment you plug the device into a USB port it should be recognised immediately, and you should be able to use the device via the standard HID API.

The included `octavi_debug.py` script uses the `hidapi` python package to continuously read data from device in a loop, and report the data that are emitted by the device in a user-friendly way for debugging (remember that you need to perform step 1 and 2 described in the previous section to gain read/write access to the device first). If you start pressing buttons at this point, you'll see that the device emits signals and the script reports that emitted data.

In the following example, I rotated the small knob once to the left, and as you see the 6th byte reports the value 0xff. Then if you want to assign a specific X-Plane function when rotating the knob to the left, you know what to look for in the FlyWithLua script, and perform an action accordingly.

```
$ ./octavi_debug.py
Connected to device Octavi IFR1 HIDCF
base10: 792633534417272576
base16: 0b0000000000ff00
 base2: 0000101100000000000000000000000000000000000000001111111100000000
 ------------------------------------------------------------------------
 63
 |62
 ||61
 |||60
 ||||59
 |||||58
 ||||||57
 |||||||56
 |||||||| 55
 |||||||| |54
 |||||||| ||53
 |||||||| |||52
 |||||||| ||||51
 |||||||| |||||50
 |||||||| ||||||49
 |||||||| |||||||48
 |||||||| |||||||| 47
 |||||||| |||||||| |46
 |||||||| |||||||| ||45
 |||||||| |||||||| |||44
 |||||||| |||||||| ||||43
 |||||||| |||||||| |||||42
 |||||||| |||||||| ||||||41
 |||||||| |||||||| |||||||40
 |||||||| |||||||| |||||||| 39
 |||||||| |||||||| |||||||| |38
 |||||||| |||||||| |||||||| ||37
 |||||||| |||||||| |||||||| |||36
 |||||||| |||||||| |||||||| ||||35
 |||||||| |||||||| |||||||| |||||34
 |||||||| |||||||| |||||||| ||||||33
 |||||||| |||||||| |||||||| |||||||32
 |||||||| |||||||| |||||||| |||||||| 31
 |||||||| |||||||| |||||||| |||||||| |30
 |||||||| |||||||| |||||||| |||||||| ||29
 |||||||| |||||||| |||||||| |||||||| |||28
 |||||||| |||||||| |||||||| |||||||| ||||27
 |||||||| |||||||| |||||||| |||||||| |||||26
 |||||||| |||||||| |||||||| |||||||| ||||||25
 |||||||| |||||||| |||||||| |||||||| |||||||24
 |||||||| |||||||| |||||||| |||||||| |||||||| 23
 |||||||| |||||||| |||||||| |||||||| |||||||| |22
 |||||||| |||||||| |||||||| |||||||| |||||||| ||21
 |||||||| |||||||| |||||||| |||||||| |||||||| |||20
 |||||||| |||||||| |||||||| |||||||| |||||||| ||||19
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||18
 |||||||| |||||||| |||||||| |||||||| |||||||| ||||||17
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||16
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| 15
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |14
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| ||13
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||12
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| ||||11
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||10
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| ||||||9
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||8
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| 7
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |6
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| ||5
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||4
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| ||||3
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||2
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| ||||||1
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||0
 |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| |||||||| ||||||||
 7      0 7      0 7      0 7      0 7      0 7      0 7      0 7      0  <- bit index per split
 00001011 00000000 00000000 00000000 00000000 00000000 11111111 00000000  <- binary value
    0   b    0   0    0   0    0   0    0   0    0   0    f   f    0   0  <- hex value
```

Once you know what bits/bytes are emitted by each button press (or combination of buttons), you can even write scripts/code to use the device for stuff that are totally unrelated to flight simulation, as the device can technically be used as a "keyboard" with fewer buttons.
